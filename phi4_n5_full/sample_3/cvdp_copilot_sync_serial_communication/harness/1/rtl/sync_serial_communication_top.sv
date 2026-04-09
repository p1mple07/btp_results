modules:
    • tx_block: Transmits parallel data (8, 16, 32, or 64 bits) by serializing it.
    • rx_block: Receives serialized data and reconstructs the parallel data.
    • sync_serial_communication_top: Top-level module that instantiates tx_block and rx_block.
  
  The design operates synchronously on clk with an asynchronous active-LOW reset (reset_n).
  The transmitter (tx_block) converts the selected portion of data_in into a serial bit stream.
  The receiver (rx_block) samples the serial data using serial_clk (provided by tx_block)
  and reconstructs the data into data_out according to the sel input.
  
  Valid sel values:
    3'b000 : No data transmission/reception.
    3'b001 : 8-bit transmission (data_in[7:0]).
    3'b010 : 16-bit transmission (data_in[15:0]).
    3'b011 : 32-bit transmission (data_in[31:0]).
    3'b100 : 64-bit transmission (data_in).
  
  The rx_block outputs data_out with the received bits placed in the lower bits:
    - For 8 bits: data_out = {56'h0, received[7:0]}
    - For 16 bits: data_out = {48'h0, received[15:0]}
    - For 32 bits: data_out = {32'h0, received[31:0]}
    - For 64 bits: data_out = received[63:0]
  
  The done signal in rx_block is asserted for one clock cycle when reception is complete.
*/

module tx_block (
    input  logic         clk,
    input  logic         reset_n,
    input  logic [63:0]  data_in,
    input  logic [2:0]   sel,
    output logic         serial_out,
    output logic         done,
    output logic         serial_clk
);
    // Define state machine types
    typedef enum logic {IDLE, TRANSMIT} state_t;
    state_t state, next_state;
    
    // Registers for shifting data
    logic [63:0] shift_reg;
    logic [5:0]  bit_cnt;   // Counter for bit index (0 to max bits-1)
    logic [5:0]  max_cnt;   // Maximum number of bits to transmit based on sel
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= IDLE;
            shift_reg     <= 64'd0;
            bit_cnt       <= 6'd0;
            max_cnt       <= 6'd0;
            serial_out    <= 1'b0;
            serial_clk    <= 1'b0;
            done          <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    serial_out <= 1'b0;
                    serial_clk <= 1'b0;  // Fixed state when idle
                    done       <= 1'b0;
                    if (sel != 3'b000) begin
                        // Determine transmission width and load corresponding data
                        case (sel)
                            3'b001: max_cnt <= 6'd8;
                            3'b010: max_cnt <= 6'd16;
                            3'b011: max_cnt <= 6'd32;
                            3'b100: max_cnt <= 6'd64;
                            default: max_cnt <= 6'd0;
                        endcase
                        case (sel)
                            3'b001: shift_reg <= data_in[7:0];
                            3'b010: shift_reg <= data_in[15:0];
                            3'b011: shift_reg <= data_in[31:0];
                            3'b100: shift_reg <= data_in;
                            default: shift_reg <= 64'd0;
                        endcase
                        bit_cnt <= 6'd0;
                        next_state = TRANSMIT;
                    end else begin
                        next_state = IDLE;
                    end
                end
                TRANSMIT: begin
                    bit_cnt <= bit_cnt + 1;
                    // Transmit LSB first
                    serial_out <= shift_reg[bit_cnt];
                    // Gated clock during transmission (equal to clk)
                    serial_clk <= clk;
                    if (bit_cnt == max_cnt - 1) begin
                        done <= 1'b1;
                        next_state = IDLE;
                    end else begin
                        done <= 1'b0;
                        next_state = TRANSMIT;
                    end
                end
            endcase
        end
    end
endmodule

module rx_block (
    input  logic         clk,
    input  logic         reset_n,
    input  logic         data_in,  // Serial input data
    input  logic [2:0]   sel,
    input  logic         serial_clk,
    output logic [63:0]  data_out,
    output logic         done
);
    // Define state machine types
    typedef enum logic {IDLE, RECEIVE} state_t;
    state_t state, next_state;
    
    // Registers for shifting in received bits
    logic [63:0] shift_reg;
    logic [5:0]  bit_cnt;   // Bit counter for received bits
    logic [5:0]  max_cnt;   // Maximum number of bits to receive based on sel
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= IDLE;
            shift_reg     <= 64'd0;
            bit_cnt       <= 6'd0;
            max_cnt       <= 6'd0;
            data_out      <= 64'd0;
            done          <= 1'b0;
        end else begin
            state <= next_state;
            case (state)
                IDLE: begin
                    data_out <= 64'd0;
                    done     <= 1'b0;
                    if (sel != 3'b000) begin
                        // Determine reception width
                        case (sel)
                            3'b001: max_cnt <= 6'd8;
                            3'b010: max_cnt <= 6'd16;
                            3'b011: max_cnt <= 6'd32;
                            3'b100: max_cnt <= 6'd64;
                            default: max_cnt <= 6'd0;
                        endcase
                        bit_cnt <= 6'd0;
                        next_state = RECEIVE;
                    end else begin
                        next_state = IDLE;
                    end
                end
                RECEIVE: begin
                    // Sample on the active serial_clk (assumed synchronous with clk during transmission)
                    if (serial_clk) begin
                        // Shift in the new bit; accumulating LSB first
                        shift_reg <= {shift_reg[62:0], data_in};
                        bit_cnt <= bit_cnt + 1;
                        if (bit_cnt == max_cnt - 1) begin
                            // Reception complete; construct data_out based on sel
                            case (sel)
                                3'b001: data_out <= {56'd0, shift_reg[7:0]};
                                3'b010: data_out <= {48'd0, shift_reg[15:0]};
                                3'b011: data_out <= {32'd0, shift_reg[31:0]};
                                3'b100: data_out <= shift_reg;
                                default: data_out <= 64'd0;
                            endcase
                            done <= 1'b1;
                            next_state = IDLE;
                        end else begin
                            done <= 1'b0;
                            next_state = RECEIVE;
                        end
                    end else begin
                        next_state = RECEIVE;
                    end
                end
            endcase
        end
    end
endmodule

module sync_serial_communication_top (
    input  logic         clk,
    input  logic         reset_n,
    input  logic [63:0]  data_in,
    input  logic [2:0]   sel,
    output logic [63:0]  data_out,
    output logic         done
);
    // Wires connecting the transmitter and receiver blocks
    wire serial_out;
    wire serial_clk;
    
    // Instantiate the transmitter block
    tx_block u_tx (
        .clk        (clk),
        .reset_n    (reset_n),
        .data_in    (data_in),
        .sel        (sel),
        .serial_out (serial_out),
        .done       (),  // tx_block done not used in top-level
        .serial_clk (serial_clk)
    );
    
    // Instantiate the receiver block
    rx_block u_rx (
        .clk         (clk),
        .reset_n     (reset_n),
        .data_in     (serial_out),
        .sel         (sel),
        .serial_clk  (serial_clk),
        .data_out    (data_out),
        .done        (done)
    );
endmodule