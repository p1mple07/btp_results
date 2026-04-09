module sync_serial_communication_top(
    input  logic         clk,
    input  logic         reset_n,
    input  logic [63:0]  data_in,
    input  logic [2:0]   sel,
    output logic [63:0]  data_out,
    output logic         done
);

    // Internal wires to connect tx and rx blocks
    wire serial_out;
    wire serial_clk;
    wire tx_done; // tx block done (not used at top level)

    // Instantiate the transmitter block
    tx_block u_tx (
        .clk        (clk),
        .reset_n    (reset_n),
        .data_in    (data_in),
        .sel        (sel),
        .serial_out (serial_out),
        .done       (tx_done),
        .serial_clk (serial_clk)
    );

    // Instantiate the receiver block
    rx_block u_rx (
        .clk        (clk),
        .reset_n    (reset_n),
        .data_in    (serial_out),
        .sel        (sel),
        .serial_clk (serial_clk),
        .data_out   (data_out),
        .done       (done)
    );

endmodule


// ----------------------------------------------------------------
// Module: tx_block
// Description:
//   Serializes the selected portion of the 64-bit data_in based on the sel signal.
//   If sel==3'h0 (or any invalid value), no transmission occurs.
//   The transmitter outputs a serial bit (serial_out) and a gated serial clock (serial_clk).
//   The done signal is asserted for one clock cycle when transmission completes.
// ----------------------------------------------------------------
module tx_block(
    input  logic         clk,
    input  logic         reset_n,
    input  logic [63:0]  data_in,
    input  logic [2:0]   sel,
    output logic         serial_out,
    output logic         done,
    output logic         serial_clk
);

    // FSM states
    localparam IDLE      = 1'b0;
    localparam TRANSMIT  = 1'b1;

    reg state;
    reg [5:0] bit_cnt;
    reg [63:0] data_reg;
    reg [5:0] expected_width;

    // Determine the number of bits to transmit based on sel.
    always_comb begin
        case (sel)
            3'h1: expected_width = 6'd8;
            3'h2: expected_width = 6'd16;
            3'h3: expected_width = 6'd32;
            3'h4: expected_width = 6'd64;
            default: expected_width = 6'd0;
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state         <= IDLE;
            bit_cnt       <= 0;
            data_reg      <= 64'd0;
            done          <= 0;
            serial_clk    <= 0; // In idle, serial_clk is low.
        end else begin
            case (state)
                IDLE: begin
                    // If a valid sel is provided (non-zero width), load data and start transmission.
                    if (expected_width > 0) begin
                        // Select the appropriate bits from data_in.
                        case (sel)
                            3'h1: data_reg <= data_in[7:0];
                            3'h2: data_reg <= data_in[15:0];
                            3'h3: data_reg <= data_in[31:0];
                            3'h4: data_reg <= data_in[63:0];
                            default: data_reg <= 64'd0;
                        endcase
                        bit_cnt <= 0;
                        state   <= TRANSMIT;
                    end
                    done      <= 0;
                    serial_clk<= 0; // Remain low when idle.
                end
                TRANSMIT: begin
                    // Output one bit per clock cycle (LSB first).
                    serial_out <= data_reg[bit_cnt];
                    serial_clk <= 1; // Assert serial_clk during transmission.
                    bit_cnt    <= bit_cnt + 1;
                    if (bit_cnt == expected_width - 1) begin
                        // Last bit transmitted; assert done for one cycle.
                        done <= 1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule