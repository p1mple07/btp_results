module cvdp_copilot_perf_counters #(
    parameter CNT_W = 4 // Counter width
) (
    input wire clk,
    input wire reset,
    input wire sw_req_i,
    input wire cpu_trig_i,
    output logic[CNT_W-1:0] p_count_o
);

logic[CNT_W-1:0] count_q;

always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
        count_q <= 0;
    end else begin
        if(cpu_trig_i &&!p_count_o) begin
            count_q <= count_q + 1;
        end
    end
end

assign p_count_o = (sw_req_i)? count_q : 0;

endmodule