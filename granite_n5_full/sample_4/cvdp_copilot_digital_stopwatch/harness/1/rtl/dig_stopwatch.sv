module dig_stopwatch #(
  parameter CLK_FREQ = 50_000_000
) (
  input logic clk,
  input logic reset,
  input logic start_stop,

  output [5:0] seconds,
  output [5:0] minutes,
  output logic hour
);

  // Counters for seconds, minutes, and hours
  logic [5:0] seconds_count;
  logic [5:0] minutes_count;
  logic [5:0] hours_count;

  always_ff @(posedge clk) begin
    if (reset) begin
      seconds_count <= 6'd0;
      minutes_count <= 6'd0;
      hours_count <= 6'd0;
    end else begin
      // Update seconds counter
      if (seconds_count == 6'd59) begin
        seconds_count <= 6'd0;
        if (minutes_count == 6'd59) begin
          minutes_count <= 6'd0;
          if (hours_count == 6'd23) begin
            hours_count <= 6'd0;
          end else begin
            hours_count <= hours_count + 1;
          end
        } else begin
          minutes_count <= minutes_count + 1;
        end
      end else begin
        seconds_count <= seconds_count + 1;
      end

      // Update outputs based on start_stop input
      if (start_stop == 1) begin
        if (hour == 1 && hours_count!= 6'd24) begin
          hour <= 0;
        end else begin
          hour <= 1;
        end
      end
    end
  end

endmodule