module fsm_seq_detector(
    input clk_in,
    input rst_in,
    input [1:0] seq_in,
    output reg seq_detected
);

    logic [2:0] cur_state, next_state;
    logic seq_detected_w;

    enum state_t {S0, S1, S2, S3, S4, S5, S6, S7} state_t;

    // State transition logic
    always_comb begin
        case (cur_state)
            S0: next_state = seq_in == 1'b1 ? S1 : S0;
            S1: next_state = seq_in == 1'b1 ? S2 : S0;
            S2: next_state = seq_in == 1'b0 ? S3 : S0;
            S3: next_state = seq_in == 1'b1 ? S4 : S0;
            S4: next_state = seq_in == 1'b0 ? S5 : S0;
            S5: next_state = seq_in == 1'b1 ? S6 : S0;
            S6: next_state = seq_in == 1'b0 ? S7 : S0;
            S7: next_state = seq_in == 1'b1 ? S1 : S0;
            default: next_state = S0;
        endcase
    end

    // State register
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            cur_state <= S0;
            seq_detected <= 0;
        end else begin
            cur_state <= next_state;
        end
    end

    // Output logic
    always_comb begin
        case (cur_state)
            S7: seq_detected_w = 1'b1;
            default: seq_detected_w = 1'b0;
        endcase
    end

    // Register the output
    always_ff @(posedge clk_in) begin
        seq_detected <= seq_detected_w;
    end

endmodule
