module fsm_seq_detector
(
    input  bit     clk_in,       // Free Running Clock
    input  logic   rst_in,       // Active HIGH reset
    input  logic   seq_in,       // Continuous 1-bit Sequence Input
    output logic   seq_detected  // '0': Not Detected. '1': Detected for 1 Clock cycle
);

    typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} state_t;
    state_t cur_state, next_state;
    logic seq_detected_w;

    // State register
    always @ (posedge clk_in or posedge rst_in)
    begin
        if (rst_in)
            cur_state <= S0;
        else
            cur_state <= next_state;
    end

    // Next state and output logic
    // The intended sequence is: 0, 1, 0, 0, 1, 1, 1, 0
    // S0: expect 0
    // S1: expect 1
    // S2: expect 0
    // S3: expect 0
    // S4: expect 1
    // S5: expect 1
    // S6: expect 1
    // S7: expect 0 (assert detection and return to S0)
    always_comb begin
        seq_detected_w = 1'b0;
        case (cur_state)
            S0: begin
                if (seq_in == 1'b0)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                if (seq_in == 1'b1)
                    next_state = S2;
                else
                    next_state = S0;
            end
            S2: begin
                if (seq_in == 1'b0)
                    next_state = S3;
                else
                    next_state = S0;
            end
            S3: begin
                if (seq_in == 1'b0)
                    next_state = S4;
                else
                    next_state = S0;
            end
            S4: begin
                if (seq_in == 1'b1)
                    next_state = S5;
                else
                    next_state = S0;
            end
            S5: begin
                if (seq_in == 1'b1)
                    next_state = S6;
                else
                    next_state = S0;
            end
            S6: begin
                if (seq_in == 1'b1)
                    next_state = S7;
                else
                    next_state = S0;
            end
            S7: begin
                if (seq_in == 1'b0) begin
                    seq_detected_w = 1'b1;
                    next_state = S0;
                end
                else
                    next_state = S0;
            end
            default: next_state = S0;
        endcase
    end

    // Output register
    always @ (posedge clk_in or posedge rst_in)
    begin
        if (rst_in)
            seq_detected <= 1'b0;
        else
            seq_detected <= seq_detected_w;
    end

endmodule