module fsm_seq_detector (
    input wire clk_in,
    input wire rst_in,
    input wire seq_in,
    output reg seq_detected
);

    // State encoding (3‑bit state machine: S0 … S7)
    enum class x { S0, S1, S2, S3, S4, S5, S6, S7 };
    localparam state_t cur_state = x::S0;

    // Sequence pattern (8‑bit) in binary
    localparam seq_pattern = 8'b10110001;

    // Always block driven by the clock
    always @(posedge clk_in or negedge rst_in) begin
        if (!rst_in) begin
            cur_state <= x::S0;
            seq_detected <= 0;
        end else begin
            case (cur_state)
                3'b000: // S0 – expecting first bit ‘1’
                    case (seq_in == 1'b1) : cur_state <= 3'b001;
                    default                     : cur_state <= 3'b100;
                // Continue with the remaining 7 states – omitted for brevity
                3'b001: case (seq_in == 1'b0) : cur_state <= 3'b010;
                3'b010: case (seq_in == 1'b1) : cur_state <= 3'b011;
                3'b011: case (seq_in == 1'b1) : cur_state <= 3'b100;
                3'b100: case (seq_in == 1'b0) : cur_state <= 3'b000;
                3'b101: case (seq_in == 1'b1) : cur_state <= 3'b110;
                3'b110: case (seq_in == 1'b0) : cur_state <= 3'b000;
                3'b111: case (seq_in == 1'b1) : cur_state <= 3'b000;
                default: cur_state <= 3'b111;
            endcase
        endcase
    end

    // Detect the complete sequence only after the 8th bit
    assign seq_detected = seq_pattern[7] && cur_state == x::S7;

endmodule
