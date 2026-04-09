module fsm_sequence_detector (
    input clk_in,
    input rst_in,
    input seq_in,
    output reg seq_detected
);

    localparam num_states = 8;
    state_t cur_state = S0;
    reg seq_detected_flag = 0;

    always_ff @(posedge clk_in) begin
        if (!rst_in) begin
            cur_state <= S0;
            seq_detected_flag <= 0;
        end else begin
            case (cur_state)
                3'b000: // S0, expect '1'
                    if (seq_in == 1'b1) begin
                        cur_state <= 3'b001;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b001: // S1, expect '0'
                    if (seq_in == 1'b0) begin
                        cur_state <= 3'b010;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b010: // S2, expect '1'
                    if (seq_in == 1'b1) begin
                        cur_state <= 3'b011;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b011: // S3, expect '1'
                    if (seq_in == 1'b1) begin
                        cur_state <= 3'b100;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b100: // S4, expect '0'
                    if (seq_in == 1'b0) begin
                        cur_state <= 3'b101;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b101: // S5, expect '0'
                    if (seq_in == 1'b0) begin
                        cur_state <= 3'b110;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b110: // S6, expect '0'
                    if (seq_in == 1'b0) begin
                        cur_state <= 3'b111;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
                endcase
                3'b111: // S7, expect '1'
                    if (seq_in == 1'b1) begin
                        cur_state <= 3'b000;
                        seq_detected_flag <= 1;
                    end else begin
                        cur_state <= 3'b000;
                    end
                    seq_detected_flag <= 0;
            endcase
        end
    end

    always_comb begin
        seq_detected = seq_detected_flag;
    end

endmodule
