module dig_stopwatch #(parameter int CLK_FREQ = 50_000_000)(
  input logic clk,
  input logic reset,
  input logic start_stop,
  output logic [5:0] seconds,
  output logic [5:0] minutes,
  output logic hour
);

  // Define internal signals
  logic [31:0] cnt;
  logic [31:0] next_cnt;
  logic [5:0] s_minutes;
  logic [5:0] s_hours;

  // Calculate next_cnt based on internal clock divider
  always_comb begin
    next_cnt = cnt + 1;
  end

  // Update seconds, minutes, and hour counters
  always_ff @(posedge clk) begin
    if (reset) begin
      cnt <= 0;
      s_minutes <= 0;
      s_hours <= 0;
    end else if (start_stop) begin
      cnt <= next_cnt;
      if (cnt >= CLK_FREQ) begin
        cnt <= 0;
        if (s_minutes == 59) begin
          s_minutes <= 0;
          if (s_hours == 23) begin
            s_hours <= 0;
          end else begin
            s_hours <= s_hours + 1;
          end
        end else begin
          s_minutes <= s_minutes + 1;
        end
      end
    end
  end

  // Assign outputs based on internal signals
  assign seconds = cnt[5:0];
  assign minutes = s_minutes;
  assign hour = (s_hours!= 0);

endmodule