module dig_stopwatch #(
  parameter int CLK_FREQ = 50_000_000 // Hz
) (
  input  logic clk,              // input clock for 1Hz pulse generation
  input  logic reset,            // asynchronous active-high reset
  input  logic start_stop,      // start/stop control
  output [5:0] seconds,          // 6-bit counter for seconds (0-59)
  output [5:0] minutes,          // 6-bit counter for minutes (0-59)
  output logic hour               // represents a one-bit signal that updates to 1 when one hour has passed
);

  localparam int NUM_SECONDS_PER_MIN = 60;
  localparam int NUM_MINS_PER_HOUR   = 60;
  
  // Counters for seconds, minutes, and hours
  reg [5:0] sec_cnt;
  reg [5:0] min_cnt;
  reg [5:0] hour_cnt;
  
  // Internal clock divider
  always @(posedge clk) begin
    if (reset) begin
      sec_cnt <= 0;
      min_cnt <= 0;
      hour_cnt <= 0;
    end else begin
      if (sec_cnt == NUM_SECONDS_PER_MIN - 1) begin
        sec_cnt <= 0;
        if (min_cnt == NUM_MINS_PER_HOUR - 1) begin
          min_cnt <= 0;
          hour_cnt <= hour_cnt + 1;
        end else begin
          min_cnt <= min_cnt + 1;
        end
      end else begin
        sec_cnt <= sec_cnt + 1;
      end
    end
  end
  
  // Update outputs based on the internal counts
  assign seconds = sec_cnt;
  assign minutes = min_cnt;
  assign hour    = (hour_cnt == NUM_MINS_PER_HOUR - 1);
  
  // Control signals
  always @(posedge start_stop or posedge reset) begin
    if (reset) begin
      // Reset all counters to zero
      sec_cnt <= 0;
      min_cnt <= 0;
      hour_cnt <= 0;
    end else begin
      if (start_stop) begin
        // Start the stopwatch
        // Reset all counters to zero
        sec_cnt <= 0;
        min_cnt <= 0;
        hour_cnt <= 0;
      end
    end
  end
  
endmodule