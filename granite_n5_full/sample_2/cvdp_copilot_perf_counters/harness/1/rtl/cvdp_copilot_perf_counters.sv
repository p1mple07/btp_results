module cvdp_copilot_perf_counters #(
  parameter CNT_W = 8 // Counter width
) (
  input  logic         clk,     // Clock
  input  logic         reset,   // Reset (active high)
  input  logic         sw_req_i, // Software request signal
  input  logic         cpu_trig_i, // CPU trigger signal
  output logic [CNT_W-1:0] p_count_o // Performance counter output
);

  logic [CNT_W-1:0] count_d;
  logic [CNT_W-1:0] count_q;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      count_d <= '0;
    end else begin
      if (cpu_trig_i) begin
        count_d <= count_d + 1;
      end
    end
  end

  assign count_q = count_d;

  always_ff @(posedge clk) begin
    if (sw_req_i) begin
      p_count_o <= count_q;
    end
  end

endmodule