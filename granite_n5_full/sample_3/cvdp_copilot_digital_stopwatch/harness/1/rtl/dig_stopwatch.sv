module dig_stopwatch #(
   parameter int CLK_FREQ = 50_000_000
)(
   input logic clk,
   input logic reset,
   input logic start_stop,

   output logic [5:0] seconds,
   output logic [5:0] minutes,
   output logic hour
);

timeunit 1ns;
timeprecision 1ps;

// Define local parameters
localparam int SEC_PER_ cycle = CLK_FREQ / 100000000;
localparam int MIN_PER_SEC = 60;
localparam int HOUR_PER_MIN = 60;

// Declare internal signals
logic [5:0] sec_cnt;
logic [5:0] min_cnt;
logic [5:0] hr_cnt;

// Generate one-second pulse
always_ff @(posedge clk) begin
   if (reset) begin
      // Reset all counters
      sec_cnt <= 0;
      min_cnt <= 0;
      hr_cnt <= 0;
   end else if (start_stop) begin
      // Run the stopwatch
      if (sec_cnt == SEC_PER_cycle - 1) begin
         // Increment seconds
         sec_cnt <= 0;
         if (min_cnt == MIN_PER_SEC - 1) begin
            // Increment minutes
            min_cnt <= 0;
            if (hr_cnt == HOUR_PER_MIN - 1) begin
               // Increment hours
               hr_cnt <= 0;
            end else begin
               hr_cnt <= hr_cnt + 1;
            end
         end else begin
            min_cnt <= min_cnt + 1;
         end
      end else begin
         // Update seconds
         sec_cnt <= sec_cnt + 1;
      end
   end
end

// Assign outputs based on internal signals
assign seconds = sec_cnt;
assign minutes = min_cnt;
assign hour = (hr_cnt == HOUR_PER_MIN - 1);

endmodule