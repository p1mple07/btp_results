// State definitions
enum state_t = {
    S0,
    S1,
    S2,
    S3,
    S4,
    S5,
    S6,
    S7
};

// State type
type state_t = logic[2:0];

// State register
reg state_t cur_state, next_state;

// State transition logic
always_comb begin
    case (cur_state)
        S0: next_state = (seq_in & 1 ? S1 : S0);
        S1: next_state = (seq_in & 1 ? S2 : S0);
        S2: next_state = (seq_in & 1 ? S3 : S0);
        S3: next_state = (seq_in & 1 ? S4 : S0);
        S4: next_state = (seq_in & 1 ? S5 : S0);
        S5: next_state = (seq_in & 1 ? S6 : S0);
        S6: next_state = (seq_in & 1 ? S7 : S0);
        S7: next_state = S7;
    endcase
end

// Output logic
reg logic seq_detected_w;
always_comb begin
    seq_detected_w = 1;
end

// Synchronous output assignment
always posedge (clk_in or rst_in) begin
    if (rst_in) begin
        seq_detected = 0;
        cur_state = S0;
    else if (cur_state == S7) begin
        seq_detected = 1;
    end
end