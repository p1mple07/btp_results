module fsm_seq_detector (
    input bit clk_in,
    input bit rst_in,
    input bit seq_in,
    output reg seq_detected
);

    typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} state_t;
    logic [2:0] cur_state, next_state;

    // State transition logic
    always_comb begin
        case (cur_state)
            S0: next_state = seq_in ? S1 : S0;
            S1: next_state = seq_in ? S2 : S0;
            S2: next_state = seq_in ? S3 : S0;
            S3: next_state = seq_in ? S4 : S0;
            S4: next_state = seq_in ? S5 : S0;
            S5: next_state = seq_in ? S6 : S0;
            S6: next_state = seq_in ? S7 : S0;
            S7: next_state = seq_in ? S0 : S0;
        endcase
    end

    // Output logic
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            cur_state <= S0;
            seq_detected <= 0;
        end else begin
            cur_state <= next_state;
            if (cur_state == S7) begin
                seq_detected <= ~seq_detected; // Toggle the output
            end
        end
    end

endmodule
