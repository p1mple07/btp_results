parameter CNT_W = 32;
module cvdp_copilot_perf_counters (
    input clock,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output [CNT_W-1:0] p_count_o
) {
    flip_flop DFF (
        input     cpu_trig_i,
        output    count_q,
        input     reset,
        clock     clock
    );
    multiplexer MUX (
        input     sw_req_i,
        input     count_q,
        input     1,
        output    p_count_o
    );
    always @* begin
        if (sw_req_i) begin
            p_count_o = count_q;
        end else begin
            p_count_o = 0;
        end
    end
    always @posedge clock begin
        if (reset) begin
            count_q = 0;
        end else if (cpu_trig_i) begin
            count_q = count_q + 1;
            // Check for overflow
            if (count_q >= (1 << CNT_W)) begin
                count_q = 0;
            end
        end
    end
}