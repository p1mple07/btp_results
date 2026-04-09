
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
                if (seq_in) begin
                    next_state = S1; // Correct transition to S1 on detecting the first bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    seq_detected_w = 1'b0;
                    next_state = S0;
                end
            end
            S1: begin
                if (seq_in) begin
                    next_state = S2; // Correct transition to S2 on detecting the second bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    seq_detected_w = 1'b0;
                    next_state = S3; // Correct transition to S3 to start a new sequence detection
                end
            end
            S2: begin
                if (seq_in) begin
                    next_state = S4; // Correct transition to S4 on detecting the fourth bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    seq_detected_w = 1'b0;
                    next_state = S5; // Correct transition to S5 to start a new sequence detection
                end
            end
            S3: begin
                if (seq_in) begin
                    next_state = S6; // Correct transition to S6 on detecting the sixth bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    seq_detected_w = 1'b0;
                    next_state = S7; // Correct transition to S7 to start a new sequence detection
                end
            end
            S4: begin
                if (seq_in) begin
                    next_state = S7; // Correct transition to S7 on detecting the seventh bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end
            end
            S5: begin
                if (seq_in) begin
                    next_state = S7; // Correct transition to S7 on detecting the eighth bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end
            end
            S6: begin
                if (seq_in) begin
                    next_state = S7; // Correct transition to S7 on detecting the ninth bit of sequence
                    seq_detected_w = 1'b0;
                end
                else begin
                    next_state = S0;
                    seq_detected_w = 1'b0;
                end
            end
            S7: begin
                if (seq_in) begin
                    next_state = S0; // Correct transition to S0 after detecting the sequence
                    seq_detected_w = 1'b1; // Assert seq_detected HIGH for one clock cycle
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
