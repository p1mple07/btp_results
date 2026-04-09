module cvdp_copilot_perf_counters #(
  parameter CNT_W = 8
) (
  input wire clk,
  input wire reset,
  input wire sw_req_i,
  input wire cpu_trig_i,
  output reg [CNT_W-1:0] p_count_o
);

  reg [CNT_W-1:0] count_q;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      count_q <= '0;
    end else begin
      if (cpu_trig_i &&!sw_req_i) begin
        count_q <= count_q + 1;
      end
    end
  end

  always @(*) begin
    if (sw_req_i) begin
      p_count_o <= count_q;
    end
  end

endmodule