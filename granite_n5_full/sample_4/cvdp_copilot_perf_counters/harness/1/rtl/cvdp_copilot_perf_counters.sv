module cvdp_copilot_perf_counters #(
  parameter int CNT_W = 8
) (
  input logic clk,
  input logic reset,
  input logic sw_req_i,
  input logic cpu_trig_i,
  output logic [CNT_W-1:0] p_count_o
);

  logic [CNT_W-1:0] count_d;
  logic [CNT_W-1:0] count_q;

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      count_q <= '0;
    end else begin
      count_q <= count_d;
    end
  end

  always_comb begin
    count_d = count_q;
    if (cpu_trig_i) begin
      count_d = count_q + 1;
    end
  end

  always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
      p_count_o <= '0;
    end else if (sw_req_i) begin
      p_count_o <= count_q;
    end
  end

endmodule