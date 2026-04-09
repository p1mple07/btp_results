module cvdp_copilot_perf_counters (
    input clock,
    input reset,
    input sw_req_i,
    input cpu_trig_i,
    output [CNT_W-1:0] p_count_o
) {
    parameter CNT_W = 32;
    reg count_reg;
    reg [CNT_W-1:0] count_q;
    reg [CNT_W-1:0] p_count_o_reg;
    reg flag_reg;
    
    alwaysposededge clock begin
        if (reset) {
            count_reg = 0;
            count_q = 0;
            p_count_o_reg = 0;
            flag_reg = 0;
        } else if (cpu_trig_i) {
            count_reg = count_reg + 1;
            count_q = count_reg;
        }
        
        if (sw_req_i) {
            p_count_o_reg = 0;
            flag_reg = 1;
        }
        
        if (flag_reg) {
            count_reg = 0;
            count_q = 0;
            p_count_o_reg = 0;
            flag_reg = 0;
        }
        
        p_count_o = p_count_o_reg;
    end
}