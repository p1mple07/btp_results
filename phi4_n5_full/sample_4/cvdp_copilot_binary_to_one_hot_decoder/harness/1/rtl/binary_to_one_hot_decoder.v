module binary_to_one_hot_decoder #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
)(
  input  [BINARY_WIDTH-1:0] binary_in,
  output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

  // Parameter check: Ensure OUTPUT_WIDTH is large enough to represent all values up to 2^(BINARY_WIDTH)-1.
  // This check is for simulation purposes only.
  generate
    if (OUTPUT_WIDTH < (1 << BINARY_WIDTH)) begin
      initial begin
        $error("Parameter ERROR: OUTPUT_WIDTH (%0d) must be at least 2^(BINARY_WIDTH) (%0d)", OUTPUT_WIDTH, (1 << BINARY_WIDTH));
      end
    end
  endgenerate

  always_comb begin
    // Default: clear all bits
    one_hot_out = {OUTPUT_WIDTH{1'b0}};
    // If binary_in is within the valid range, set the corresponding bit to 1.
    if (binary_in < OUTPUT_WIDTH)
      one_hot_out[binary_in] = 1'b1;
  end

endmodule