module dig_stopwatch #(
    parameter integer CLK_FREQ = 50000000
) (
    input  logic clk,
    input  logic reset,
    input  logic start_stop,
    output logic [5:0] seconds,
    output logic [5:0] minutes,
    output logic hour
);

  // Internal registers for clock division
  // clk_div_counter counts clock cycles to generate a one-second pulse.
  logic [31:0] clk_div_counter;
  logic sec_pulse;

  // Synchronous process with asynchronous reset
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      clk_div_counter <= 32'd0;
      sec_pulse       <= 1'd0;
      seconds         <= 6'd0;
      minutes         <= 6'd0;
      hour            <= 1'd0;
    end
    else begin
      // Clock divider: generate a one-cycle pulse every CLK_FREQ cycles.
      if (clk_div_counter == CLK_FREQ - 1) begin
        clk_div_counter <= 32'd0;
        sec_pulse       <= 1'd1;
      end
      else begin
        clk_div_counter <= clk_div_counter + 1;
        sec_pulse       <= 1'd0;
      end

      // Update stopwatch counters on the rising edge of the one-second pulse,
      // but only if the stopwatch is running and not already at one hour.
      if (sec_pulse && start_stop && (hour != 1)) begin
        seconds <= seconds + 1;
        if (seconds == 6'd60) begin
          seconds <= 6'd0;
          minutes <= minutes + 1;
          if (minutes == 6'd60) begin
            minutes <= 6'd0;
            hour    <= 1'd1;
          end
        end
      end
    end
  end

endmodule