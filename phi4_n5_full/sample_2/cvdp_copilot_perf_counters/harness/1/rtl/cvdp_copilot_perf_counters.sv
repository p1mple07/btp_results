module cvdp_copilot_perf_counters #(parameter CNT_W = 8) (
    input  logic         clk,
    input  logic         reset,
    input  logic         sw_req_i,
    input  logic         cpu_trig_i,
    output logic [CNT_W-1:0] p_count_o
);

  // Internal registers for the counter and output latching.
  logic [CNT_W-1:0] count;
  logic [CNT_W-1:0] out_reg;
  // A flag to schedule a counter reset in the next cycle after a software read.
  logic reset_next;

  // Counter logic: increment on cpu_trig_i, asynchronously reset on global reset,
  // and schedule a reset (on the next cycle) when a software read is requested.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      count       <= '0;
      reset_next  <= 1'b0;
    end else begin
      // If a reset was scheduled in the previous cycle, clear the counter.
      if (reset_next) begin
        count       <= '0;
        reset_next  <= 1'b0;
      end else if (cpu_trig_i) begin
        count <= count + 1;
      end

      // When a software read is requested, latch the current count and schedule a reset.
      if (sw_req_i)
        reset_next <= 1'b1;
    end
  end

  // Output register: capture the counter value on a software read and clear it otherwise.
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      out_reg <= '0;
    else begin
      if (sw_req_i)
        out_reg <= count;
      else
        out_reg <= '0;
    end
  end

  // Drive the performance counter output only when a software read occurs.
  assign p_count_o = sw_req_i ? out_reg : '0;

endmodule