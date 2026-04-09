module moving_average(
  input clk,
  input reset,
  input [11:0] data_in,
  output reg [11:0] data_out
);

  reg [11:0] sum; // Internal sum register
  wire [7:0] num_samples; // Number of samples available for the moving average

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      sum <= 0; // Clear the sum register on reset
      num_samples <= 0; // Clear the number of samples counter on reset
    end else begin
      sum <= {data_in, sum[11:1]}; // Add the new sample to the sum register
      if (num_samples < 8) begin
        num_samples <= num_samples + 1; // Increment the number of samples counter
      end
    end
  end

  assign data_out = num_samples >= 8? sum / 8 : sum; // Calculate the moving average based on the number of samples

endmodule