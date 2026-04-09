module cvdp_copilot_perf_counters #(parameter CNT_W = 8) // Counter width
(
    input logic clk,
    input logic reset,
    input logic sw_req_i,
    input logic cpu_trig_i,
    output logic [CNT_W-1:0] p_count_o
);

logic [CNT_W-1:0] count_q;

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        count_q <= '0;
    end else begin
        if (cpu_trig_i &&!sw_req_i) begin
            count_q <= count_q + 1;
        end
    end
end

assign p_count_o = count_q;

endmodule