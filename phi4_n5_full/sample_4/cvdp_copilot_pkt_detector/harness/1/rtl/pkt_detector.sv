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

    localparam [7:0] START_SYMBOL = 8'hFB;
    localparam [7:0] END_SYMBOL   = 8'hFD;
    localparam       PKT_BYTES    = 20;

    typedef enum logic [1:0] {
        S_IDLE     = 2'b00,
        S_ACTIVE   = 2'b01,
        S_WAIT_END = 2'b10,
        S_ERROR    = 2'b11
    } state_t;

    state_t curr_state, nxt_state;

    logic [7:0]    byte_cnt;
    logic [159:0]  pkt_reg;

    // State Register
    always_ff @(posedge clk or negedge reset) begin
        if (!reset)
            curr_state <= S_IDLE;
        else
            curr_state <= nxt_state;
    end

    // Next State Logic
    always_comb begin
        case (curr_state)
            S_IDLE: 
                if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                    nxt_state = S_ACTIVE;
                else
                    nxt_state = S_IDLE;

            S_ACTIVE: 
                if (byte_cnt == PKT_BYTES)
                    nxt_state = S_WAIT_END;
                else
                    nxt_state = S_ACTIVE;

            S_WAIT_END: 
                if (pkt_reg[159:152] == END_SYMBOL)
                    nxt_state = S_IDLE;
                else
                    nxt_state = S_ERROR;

            S_ERROR: 
                if ((data_in == START_SYMBOL) && (data_k_flag == 1'b1))
                    nxt_state = S_ACTIVE;
                else
                    nxt_state = S_ERROR;

            default: nxt_state = S_IDLE;
        endcase
    end

    // Sequential logic: update registers, accumulate packet data, update counters and flags
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            byte_cnt            <= 0;
            pkt_reg             <= 0;
            pkt_count           <= 0;
            pkt_data            <= 0;
            mem_read_detected   <= 0;
            mem_write_detected  <= 0;
            io_read_detected    <= 0;
            io_write_detected   <= 0;
            cfg_read0_detected  <= 0;
            cfg_write0_detected <= 0;
            cfg_read1_detected  <= 0;
            cfg_write1_detected <= 0;
            completion_detected <= 0;
            completion_data_detected <= 0;
            error_detected      <= 0;
        end
        else begin
            case (curr_state)
                S_IDLE: begin
                    // Wait for start symbol; reset accumulation registers
                    byte_cnt    <= 0;
                    pkt_reg     <= 0;
                end

                S_ACTIVE: begin
                    if (data_k_flag) begin
                        // Shift in new byte into packet register
                        pkt_reg <= {pkt_reg[151:0], data_in};
                        // Increment byte counter; reset when reaching PKT_BYTES
                        if (byte_cnt == PKT_BYTES - 1)
                            byte_cnt <= 0;
                        else
                            byte_cnt <= byte_cnt + 1;
                    end
                end

                S_WAIT_END: begin
                    if (pkt_reg[159:152] == END_SYMBOL) begin
                        // Valid packet: update packet counter and data
                        pkt_count  <= pkt_count + 1;
                        pkt_data   <= pkt_reg;
                        // Decode the packet header (first byte) to set detection flags
                        case (pkt_reg[31:24])
                            8'h01: mem_read_detected   <= 1;
                            8'h02: mem_write_detected  <= 1;
                            8'h03: io_read_detected    <= 1;
                            8'h04: io_write_detected   <= 1;
                            8'h05: cfg_read0_detected  <= 1;
                            8'h06: cfg_write0_detected <= 1;
                            8'h07: cfg_read1_detected  <= 1;
                            8'h08: cfg_write1_detected <= 1;
                            8'h09: completion_detected <= 1;
                            8'h0A: completion_data_detected <= 1;
                            default: begin
                                // No specific flag set for unrecognized header
                            end
                        endcase
                    end
                    else begin
                        // Invalid packet sequence detected
                        error_detected <= 1;
                    end
                    // Reset accumulation registers for next packet
                    pkt_reg    <= 0;
                    byte_cnt   <= 0;
                end

                S_ERROR: begin
                    // Remain in error state until recovery; assert error flag
                    error_detected <= 1;
                    // Clear detection flags and reset accumulation registers
                    mem_read_detected   <= 0;
                    mem_write_detected  <= 0;
                    io_read_detected    <= 0;
                    io_write_detected   <= 0;
                    cfg_read0_detected  <= 0;
                    cfg_write0_detected <= 0;
                    cfg_read1_detected  <= 0;
                    cfg_write1_detected <= 0;
                    completion_detected <= 0;
                    completion_data_detected <= 0;
                    pkt_reg    <= 0;
                    byte_cnt   <= 0;
                end

                default: begin
                    // Default case: do nothing
                end
            endcase
        end
    end

endmodule