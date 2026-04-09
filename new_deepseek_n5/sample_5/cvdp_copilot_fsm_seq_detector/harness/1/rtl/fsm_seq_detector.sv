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

// State transition table
localparam [
    state_t next_state[ state_t, logic ];
] = {
    { S0, seq_in ? S1 : S0 }, // 0
    { S1, seq_in ? S2 : S0 }, // 1
    { S2, seq_in ? S3 : S0 }, // 0
    { S3, seq_in ? S4 : S0 }, // 1
    { S4, seq_in ? S5 : S0 }, // 0
    { S5, seq_in ? S6 : S0 }, // 0
    { S6, seq_in ? S7 : S0 }, // 0
    { S7, seq_in ? S0 : S0 }, // 1
};

// FSM implementation
always_comb begin
    logic next_state = next_state[ cur_state, seq_in ];
    logic seq_detected_w = (cur_state == S7) ? 1 : 0;
end

always posedge clk_in or rst_in begin
    if (rst_in) begin
        state = S0;
        seq_detected = 0;
    else
        state = next_state;
        seq_detected = seq_detected_w;
    end
end