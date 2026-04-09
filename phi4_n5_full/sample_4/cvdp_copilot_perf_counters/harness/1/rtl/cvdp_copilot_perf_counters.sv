module cvdp_copilot_perf_counters #(parameter CNT_W = 8) (
  input  logic         clk,
  input  logic         reset,
  input  logic         sw_req_i,
  input  logic         cpu_trig_i,
  output logic [CNT_W-1:0] p_count_o
);

  // Internal counter and a flag to trigger a reset after a software read
  logic [CNT_W-1:0] counter;
  logic             clear_next;

  // Counter always block: asynchronous reset and delayed clear after a read
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      counter     <= '0;
      clear_next  <= 1'b0;
    end else begin
      if (clear_next) begin
        counter     <= '0;
        clear_next  <= 1'b0;
      end else begin
        // Increment counter on cpu trigger
        if (cpu_trig_i)
          counter <= counter + 1;
        // If a software read is requested, set the flag to clear the counter next cycle
        if (sw_req_i)
          clear_next <= 1'b1;
      end
    end
  end

  // Output always block: drive p_count_o only when sw_req_i is active;
  // otherwise, force the output to zero.
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      p_count_o <= '0;
    else if (sw_req_i)
      p_count_o <= counter;
    else
      p_count_o <= '0;
  end

endmodule