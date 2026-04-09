parameter CNT_W = 32;
parameter RESET_FREQ = 100000000;

module cvdp_copilot_perf_counters (
    input clock,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output [CNT_W-1:0] p_count_o
) {

    // Counter flip-flop
    flip-flop (positive edge) count_q [0:CNT_W-1];
    
    // Overflow flag
    output overflow_flag = (count_q[0] & (1 << (CNT_W-1))) ? 1 : 0;

    // Multiplexer for output
    wire select_mux_out = (sw_req_i ? 1 : 0);

    // Always block for initial reset
    always @* begin
        count_q = 0;
    end

    // Positive edge sensitivity
    always clock positive edge #RESET_FREQ (
        .begin()
            if (reset) count_q = 0;
            if (cpu_trig_i) count_q = count_q + 1;
        .end()
    ) #default;
    
    // Output the count or zero based on software request
    p_count_o = (select_mux_out ? count_q : 0) & ((1 << CNT_W) - 1);
    
    // Handle overflow
    if (overflow_flag) begin
        count_q = 0;
    end
}