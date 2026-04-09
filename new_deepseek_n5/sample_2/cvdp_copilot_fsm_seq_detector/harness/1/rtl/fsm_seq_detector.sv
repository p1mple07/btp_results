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
 
reg state_t cur_state, next_state;
reg [7:0] seq_detected_w;
 
always_comb (
    input logic [2:0] cur_state,
    input logic seq_in
) {
    // State transitions
    if (cur_state == S0) {
        next_state = (seq_in == 1) ? S1 : S0;
    } else if (cur_state == S1) {
        next_state = (seq_in == 0) ? S2 : S1;
    } else if (cur_state == S2) {
        next_state = (seq_in == 1) ? S3 : S2;
    } else if (cur_state == S3) {
        next_state = (seq_in == 1) ? S4 : S3;
    } else if (cur_state == S4) {
        next_state = (seq_in == 0) ? S5 : S4;
    } else if (cur_state == S5) {
        next_state = (seq_in == 0) ? S6 : S5;
    } else if (cur_state == S6) {
        next_state = (seq_in == 0) ? S7 : S6;
    } else if (cur_state == S7) {
        next_state = (seq_in == 1) ? S0 : S7;
    } else {
        next_state = cur_state;
    }
}
 
always posedge (clk_in or rst_in) begin
    if (rst_in) begin
        cur_state = S0;
        seq_detected_w = 0;
    end else begin
        seq_detected_w = (cur_state == S7);
        next_state = next_state;
        seq_detected = seq_detected_w;
    end
end