module dig_stopwatch (
  input  logic         clk,
  input  logic         reset,
  input  logic         start_stop,
  output logic [5:0]   seconds,
  output logic [5:0]   minutes,
  output logic         hour
);

  // Parameter: input clock frequency in Hz (default 50,000,000 Hz)
  parameter integer CLK_FREQ = 50_000_000;

  // Internal clock divider to generate a one-second pulse.
  // The divider counts from 0 to CLK_FREQ-1. When it reaches CLK_FREQ-1,
  // a single pulse (one_sec_pulse) is generated for one clock cycle.
  reg [31:0] clk_divider;
  reg        one_sec_pulse;

  // Clock divider and one-second pulse generation.
  // Asynchronous reset: when reset is high, all registers are cleared.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      clk_divider   <= 32'd0;
      one_sec_pulse <= 1'b0;
    end else begin
      clk_divider   <= clk_divider + 1;
      if (clk_divider == (CLK_FREQ - 1))
        one_sec_pulse <= 1'b1;
      else
        one_sec_pulse <= 1'b0;
    end
  end

  // Counters for seconds, minutes, and hour.
  // The counters update on the rising edge of one_sec_pulse.
  // - Seconds (6-bit): 0-59. When 59, resets to 0 and minutes increment.
  // - Minutes (6-bit): 0-59. When 59, resets to 0 and hour is set to 1.
  // - Hour (1-bit): Set to 1 after one hour is reached; then holds.
  // The stopwatch only updates when start_stop is high.
  always @(posedge one_sec_pulse or posedge reset) begin
    if (reset) begin
      seconds <= 6'd0;
      minutes <= 6'd0;
      hour    <= 1'b0;
    end else if (start_stop && (hour != 1'b1)) begin
      if (seconds == 6'd59) begin
        seconds <= 6'd0;
        if (minutes == 6'd59) begin
          minutes <= 6'd0;
          hour    <= 1'b1; // Stopwatch holds at 1 hour, 0 minutes, 0 seconds.
        end else begin
          minutes <= minutes + 1;
        end
      end else begin
        seconds <= seconds + 1;
      end
    end
  end

endmodule