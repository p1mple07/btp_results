module fsm_seq_detector (
    input logic clk_in,
    input logic rst_in,
    input logic seq_in,
    output logic seq_detected
);

typedef enum logic[2:0] {
    S0, S1, S2, S3, S4, S5, S6, S7
} state_t;

state_t cur_state, next_state;
logic seq_detected_w;

// Next-state logic
always_comb begin
    case (cur_state)
        S0: begin
            if (seq_in == 1'b1) begin
                next_state = S1;
            end else begin
                next_state = S0;
            end
        end
        S1: begin
            if (seq_in == 1'b1) begin
                next_state = S2;
            end else begin
                next_state = S1;
            end
        end
        S2: begin
            if (seq_in == 1'b1) begin
                next_state = S3;
            end else begin
                next_state = S2;
            end
        end
        S3: begin
            if (seq_in == 1'b1) begin
                next_state = S4;
            end else begin
                next_state = S3;
            end
        end
        S4: begin
            if (seq_in == 1'b1) begin
                next_state = S5;
            end else begin
                next_state = S4;
            end
        end
        S5: begin
            if (seq_in == 1'b1) begin
                next_state = S6;
            end else begin
                next_state = S5;
            end
        end
        S6: begin
            if (seq_in == 1'b1) begin
                next_state = S7;
            end else begin
                next_state = S6;
            end
        end
        S7: begin
            if (seq_in == 1'b1) begin
                next_state = S0;
            end else begin
                next_state = S7;
            end
        end
    endcase
end

// Sequential always block for state register
always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in == 1'b1) begin
        cur_state <= S0;
        seq_detected_w <= 1'b0;
    end else begin
        cur_state <= next_state;
        seq_detected_w <= seq_detected;
    end
end

// Output logic
assign seq_detected = seq_detected_w & (seq_in == 1'b1);

endmodule