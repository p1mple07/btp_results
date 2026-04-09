module cvdp_copilot_perf_counters(
    input clock,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output p_count_o
) parameterizable(
    parameter CNT_W = 32
) {
    // Parameterized flip-flop for counter
    flip_flop clock_edge;
    wire (clock_edgeclk) = clock;
    
    // Counter value
    integer count = 0;
    
    // Asynchronous reset
    always_comb when (reset) begin
        count = 0;
    end
    
    // Counter increment on CPU trigger
    always_posedge cpu_trig_i begin
        if (sw_req_i) begin
            // Update counter and reset on next clock cycle
            count = count + 1;
        end
    end
    
    // Output the counter value on software request
    always_comb when (sw_req_i) begin
        p_count_o = count;
        // Reset counter for next read
        count = 0;
    end
}