module fsm_seq_detector
(
    input  bit     clk_in,       // Free Running Clock
    input  logic   rst_in,       // Active HIGH reset
    input  logic   seq_in,       // Continuous 1-bit Sequence Input
    output logic   seq_detected  // '0': Not Detected. '1': Detected. Will be HIGH for 1 Clock cycle Only
);

typedef enum logic [2:0] {S0, S1, S2, S3, S4, S5, S6, S7} state_t;
state_t cur_state, next_state;

logic seq_detected_w;

always @ (posedge clk_in or posedge rst_in)
begin
    if (rst_in)
        cur_state <= S0;
    else
        cur_state <= next_state;
end

always_comb begin
    if (rst_in) begin
        seq_detected_w = 1'b0;
        next_state = S0;
    end
    else begin
        case (cur_state)
            S0: begin
                // Expecting 0 as the first bit of "01001110"
                if (seq_in == 0) begin
                    next_state = S1;
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end	
            end
            S1: begin
                // Expecting 1 as the second bit
                if (seq_in == 1) begin
                    next_state = S2;
                    seq_detected_w = 1'b0;
                end
                else begin
                    // On mismatch, if input is 0 it could be the start of a new sequence
                    next_state = S1;
                    seq_detected_w = 1'b0;
                end
            end
            S2: begin
                // Expecting 0 as the third bit
                if (seq_in == 0) begin
                    next_state = S3;
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end
            end
            S3: begin
                // Expecting 0 as the fourth bit
                if (seq_in == 0) begin
                    next_state = S4;
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S2;
                    seq_detected_w = 1'b0;
                end
            end
            S4: begin
                // Expecting 1 as the fifth bit
                if (seq_in == 1) begin
                    next_state = S5;
                    seq_detected_w = 1'b0;
                end
                else begin
                    // On mismatch, 0 can start a new sequence
                    next_state = S1;
                    seq_detected_w = 1'b0;
                end
            end
            S5: begin
                // Expecting 1 as the sixth bit
                if (seq_in == 1) begin
                    next_state = S6;
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S1;
                    seq_detected_w = 1'b0;
                end
            end
            S6: begin
                // Expecting 1 as the seventh bit
                if (seq_in == 1) begin
                    next_state = S7;
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S1;
                    seq_detected_w = 1'b0;
                end
            end
            S7: begin
                // Expecting 0 as the eighth bit; detection occurs here
                if (seq_in == 0) begin
                    seq_detected_w = 1'b1;
                    next_state = S1; // After detection, start over to allow overlapping detection
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end
            end
            default: begin
                next_state = S0;
                seq_detected_w = 1'b0;
            end
        endcase
    end
end

always @ (posedge clk_in or posedge rst_in)
begin
    if (rst_in)
        seq_detected <= 1'b0;
    else
        seq_detected <= seq_detected_w;
end

endmodule