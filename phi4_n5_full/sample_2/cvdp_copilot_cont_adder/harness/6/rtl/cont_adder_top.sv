module continuous_adder #(
  parameter DATA_WIDTH      = 32,
  parameter THRESHOLD_VALUE = 100,
  parameter SIGNED_INPUTS   = 1
) (
  input  logic                     clk,
  input  logic                     reset,
  input  logic [DATA_WIDTH-1:0]    data_in,
  input  logic                     data_valid,
  output logic [DATA_WIDTH-1:0]    sum_out,
  output logic                     sum_ready
);

  // Declare the internal accumulator with conditional signed/unsigned type.
  generate
    if (SIGNED_INPUTS) begin : gen_signed
      logic signed [DATA_WIDTH-1:0] sum_accum;
    end else begin : gen_unsigned
      logic [DATA_WIDTH-1:0] sum_accum;
    end
  endgenerate

  // Sequential logic for sum accumulation.
  always_ff @(posedge clk) begin
    if (reset) begin
      sum_accum <= '0;
      sum_ready <= 1'b0;
    end
    else if (data_valid) begin
      // Compute the new accumulated sum.
      // Use $signed conversion when SIGNED_INPUTS is enabled.
      logic [DATA_WIDTH-1:0] new_sum;
      if (SIGNED_INPUTS)
        new_sum = $signed(sum_accum) + $signed(data_in);
      else
        new_sum = sum_accum + data_in;

      // Check the threshold condition.
      // For signed inputs, trigger if new_sum is >= THRESHOLD_VALUE or <= -THRESHOLD_VALUE.
      // For unsigned inputs, trigger if new_sum is >= THRESHOLD_VALUE.
      if (SIGNED_INPUTS) begin
        if ((new_sum >= THRESHOLD_VALUE) || (new_sum <= -THRESHOLD_VALUE)) begin
          sum_out   <= new_sum;
          sum_ready <= 1'b1;
          sum_accum <= '0;
        end
        else begin
          sum_accum <= new_sum;
          sum_ready <= 1'b0;
        end
      end
      else begin
        if (new_sum >= THRESHOLD_VALUE) begin
          sum_out   <= new_sum;
          sum_ready <= 1'b1;
          sum_accum <= '0;
        end
        else begin
          sum_accum <= new_sum;
          sum_ready <= 1'b0;
        end
      end
    end
  end

endmodule