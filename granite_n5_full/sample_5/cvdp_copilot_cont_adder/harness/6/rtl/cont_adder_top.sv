module continuous_adder #(
  parameter int DATA_WIDTH = 32,
  parameter int THRESHOLD_VALUE = 100,
  parameter bit SIGNED_INPUTS = 1
) (
  input logic clk,
  input logic rst,
  input logic [DATA_WIDTH-1:0] data_in,
  input logic data_valid,
  output logic [DATA_WIDTH-1:0] sum_out,
  output logic sum_ready
);

  logic [DATA_WIDTH-1:0] sum_accum;

  // Sequential logic for sum accumulation
  always_ff @(posedge clk) begin
    if (rst) begin
      // On reset, clear the accumulator, reset sum_out and sum_ready
      sum_accum <= '0;
      sum_ready <= 1'b0;
    end else begin
      if (data_valid && ~sum_ready) begin
        // Add input data to the accumulator
        sum_accum <= sum_accum + data_in;

        // Check if the accumulated sum is >= threshold value
        if (SUM_ACCM < THRESHOLD_VALUE) begin
          // Output the current sum and reset the accumulator
          sum_out <= sum_accum + data_in;
          sum_ready <= 1'b1;
        } else begin
          // Continue accumulating, but no output until the sum reaches threshold value
          sum_ready <= 1'b0;
        end
      end
    end
  end

endmodule