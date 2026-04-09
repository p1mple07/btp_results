enum state_t {
    S0,
    S1,
    S2,
    S3,
    S4,
    S5,
    S6,
    S7
};

reg state_t cur_state;
reg [7:0] next_state;
reg seq_detected_w;

always_comb begin
    case (cur_state)
        S0: next_state = (seq_in ? S1 : S0);
        S1: next_state = (seq_in & 1 ? S2 : S1);
        S2: next_state = (seq_in & 0 ? S3 : S2);
        S3: next_state = (seq_in & 1 ? S4 : S3);
        S4: next_state = (seq_in & 0 ? S5 : S4);
        S5: next_state = (seq_in & 0 ? S6 : S5);
        S6: next_state = (seq_in & 0 ? S7 : S6);
        S7: next_state = (seq_in & 1 ? S0 : S7);
    endcase
end

always_comb begin
    seq_detected_w = (cur_state == S7) ? 1 : 0;
end

always posedge (clk_in or rst_in) begin
    if (rst_in) begin
        cur_state = S0;
        seq_detected_w = 0;
    else
        cur_state = next_state;
    end
end

// Test bench code here