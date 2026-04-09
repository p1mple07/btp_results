module pkt_detector #(
    parameter PKT_CNT_WIDTH = 4
) (
    input  logic                       reset,
    input  logic                       clk,
    input  logic [7:0]                 data_in,
    input  logic                       data_k_flag,
    output logic [PKT_CNT_WIDTH - 1:0] pkt_count,
    output logic [159:0]               pkt_data,
    output logic                       mem_read_detected,
    output logic                       mem_write_detected,
    output logic                       io_read_detected,
    output logic                       io_write_detected,
    output logic                       cfg_read0_detected,
    output logic                       cfg_write0_detected,
    output logic                       cfg_read1_detected,
    output logic                       cfg_write1_detected,
    output logic                       completion_detected,
    output logic                       completion_data_detected,
    output logic                       error_detected
);

    // Packet symbols and packet length
    localparam [7:0] START_SYMBOL = 8'hFB;
    localparam [7:0] END_SYMBOL   = 8'hFD;
    localparam       PKT_BYTES    = 20;

    // State machine definition
    typedef enum logic [1:0] {
        S_IDLE     = 2'b00,
        S_ACTIVE   = 2'b01,
        S_WAIT_END = 2'b10,
        S_ERROR    = 2'b11
    } state_t;

    state_t curr_state, nxt_state;

    // Internal registers
    logic [7:0]    byte_cnt;
    logic [159:0]  pkt_reg;

    // State register: synchronous update on posedge clk, asynchronous reset
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            curr_state <= S_IDLE;
        else
            curr_state <= nxt_state;
    end

    // Next state logic
    always_comb begin
        case (curr_state)
            S_IDLE: 
                nxt_state = ((data_in == START_SYMBOL) && (data_k_flag == 1'b1)) ? S_ACTIVE : S_IDLE;
            S_ACTIVE: 
                nxt_state = (byte_cnt == PKT_BYTES) ? S_WAIT_END : S_ACTIVE;
            S_WAIT_END: 
                nxt_state = (pkt_reg[159:152] == END_SYMBOL) ? S_IDLE : S_ERROR;
            S_ERROR: 
                nxt_state = ((data_in == START_SYMBOL) && (data_k_flag == 1'b1)) ? S_ACTIVE : S_ERROR;
            default: nxt_state = S_IDLE;
        endcase
    end

    // Register update logic: accumulators, counters, output flags, etc.
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            byte_cnt         <= 8'd0;
            pkt_reg          <= 160'd0;
            pkt_count        <= {PKT_CNT_WIDTH{1'b0}};
            pkt_data         <= 160'd0;
            mem_read_detected       <= 1'b0;
            mem_write_detected      <= 1'b0;
            io_read_detected        <= 1'b0;
            io_write_detected       <= 1'b0;
            cfg_read0_detected      <= 1'b0;
            cfg_write0_detected     <= 1'b0;
            cfg_read1_detected      <= 1'b0;
            cfg_write1_detected     <= 1'b0;
            completion_detected     <= 1'b0;
            completion_data_detected<= 1'b0;
            error_detected          <= 1'b0;
        end
        else begin
            // Default assignments: clear flags and error signal each cycle
            mem_read_detected       <= 1'b0;
            mem_write_detected      <= 1'b0;
            io_read_detected        <= 1'b0;
            io_write_detected       <= 1'b0;
            cfg_read0_detected      <= 1'b0;
            cfg_write0_detected     <= 1'b0;
            cfg_read1_detected      <= 1'b0;
            cfg_write1_detected     <= 1'b0;
            completion_detected     <= 1'b0;
            completion_data_detected<= 1'b0;
            error_detected          <= 1'b0;
            // Default: hold pkt_data and pkt_count until updated in S_WAIT_END
            pkt_data         <= pkt_reg;
            pkt_count        <= pkt_count;

            case (curr_state)
                S_IDLE: begin
                    // On detecting START_SYMBOL in IDLE, reset accumulators
                    if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1)) begin
                        byte_cnt <= 8'd0;
                        pkt_reg  <= 160'd0;
                    end
                end
                S_ACTIVE: begin
                    // Accumulate packet data: shift in new byte at LSB
                    if (data_k_flag) begin
                        pkt_reg <= {pkt_reg[151:0], data_in};
                        if (byte_cnt < PKT_BYTES - 1)
                            byte_cnt <= byte_cnt + 1;
                    end
                end
                S_WAIT_END: begin
                    // Validate the packet by checking the END_SYMBOL
                    if (pkt_reg[159:152] == END_SYMBOL) begin
                        // Valid packet: update output packet data and packet counter
                        pkt_data   <= pkt_reg;
                        pkt_count  <= pkt_count + 1;
                        // Decode the packet header (second byte) to set detection flags
                        case (pkt_reg[31:24])
                            8'h01: mem_read_detected       <= 1'b1;
                            8'h02: mem_write_detected      <= 1'b1;
                            8'h03: io_read_detected        <= 1'b1;
                            8'h04: io_write_detected       <= 1'b1;
                            8'h05: cfg_read0_detected      <= 1'b1;
                            8'h06: cfg_write0_detected     <= 1'b1;
                            8'h07: cfg_read1_detected      <= 1'b1;
                            8'h08: cfg_write1_detected     <= 1'b1;
                            8'h09: completion_detected     <= 1'b1;
                            8'h0A: completion_data_detected<= 1'b1;
                            default: error_detected          <= 1'b1;
                        endcase
                    end
                    else begin
                        // Invalid packet sequence: flag error
                        error_detected <= 1'b1;
                    end
                end
                S_ERROR: begin
                    // In error state, clear the accumulators for recovery
                    pkt_reg <= 160'd0;
                    byte_cnt<= 8'd0;
                end
                default: ;
            endcase
        end
    end

endmodule