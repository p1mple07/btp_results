module cvdp_copilot_perf_counters(
    input clock,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output [CNT_W-1:0] p_count_o
);

    // Counter value
    reg [CNT_W-1:0] count_q;

    // Output signal
    reg [CNT_W-1:0] p_count_o_reg;

    always clocked+edge #+1 (
        if (reset) (
            count_q = 0;
        ) else if (cpu_trig_i) (
            count_q = count_q + 1;
        )
    );

    // Software request handling
    always clocked #+1 (
        if (sw_req_i) (
            p_count_o = p_count_o_reg;
            p_count_o_reg = 0;
        )
    );

    // Wrap around on overflow
    always @* begin
        p_count_o_reg = count_q;
    end

    // Counter initialization
    initial begin
        count_q = 0;
    end

endmodule