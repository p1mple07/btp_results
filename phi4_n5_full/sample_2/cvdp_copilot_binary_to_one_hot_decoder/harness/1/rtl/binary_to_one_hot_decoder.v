module binary_to_one_hot_decoder #(
  parameter BINARY_WIDTH = 5,
  parameter OUTPUT_WIDTH = 32
)(
  input  [BINARY_WIDTH-1:0] binary_in,
  output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

  // Combinational logic for one-hot decoding
  always @(*) begin
    // Default: all output bits are 0
    one_hot_out = {OUTPUT_WIDTH{1'b0}};
    // Check if binary_in is within range
    if (binary_in < OUTPUT_WIDTH) begin
      one_hot_out[binary_in] = 1'b1;
    end
  end

endmodule