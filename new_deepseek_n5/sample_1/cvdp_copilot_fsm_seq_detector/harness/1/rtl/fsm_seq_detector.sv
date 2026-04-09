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

// State vector
logic state_t cur_state, next_state;

// State transition logic
always_comb (
    input logic seq_in,
    input logic cur_state
) begin
    case (cur_state)
        S0:
            next_state = (seq_in == 1) ? S1 : S0;
        S1:
            next_state = (seq_in == 0) ? S2 : S0;
        S2:
            next_state = (seq_in == 1) ? S3 : S0;
        S3:
            next_state = (seq_in == 1) ? S4 : S0;
        S4:
            next_state = (seq_in == 0) ? S5 : S0;
        S5:
            next_state = (seq_in == 0) ? S6 : S0;
        S6:
            next_state = (seq_in == 0) ? S7 : S0;
        S7:
            next_state = (seq_in == 1) ? S0 : S0;
    endcase
end

// Output logic
logic logic_d q;
always sequential (posedge clk_in or posedge rst_in) begin
    case (cur_state)
        S7 & seq_in == 1:
            q = 1;
    default:
        q = 0;
    endcase
    q <= q;
end

// Reset behavior
always_comb logicrst_in:
    cur_state = S0;
    next_state = S0;
    q = 0;
end

// State register
always posedge clk_in or posedge rst_in begin
    if (rst_in) 
        cur_state = S0;
    else 
        cur_state = next_state;
end