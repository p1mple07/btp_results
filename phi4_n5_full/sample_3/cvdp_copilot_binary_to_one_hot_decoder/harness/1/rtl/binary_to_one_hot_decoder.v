module binary_to_one_hot_decoder #(
    parameter BINARY_WIDTH = 5,
    parameter OUTPUT_WIDTH = 32
)(
    input  logic [BINARY_WIDTH-1:0] binary_in,
    output logic [OUTPUT_WIDTH-1:0] one_hot_out
);

  // Generate one-hot output: For each bit position in one_hot_out,
  // if binary_in is within range and equal to the index, set that bit to 1.
  genvar i;
  generate
    for (i = 0; i < OUTPUT_WIDTH; i = i + 1) begin : one_hot_gen
      assign one_hot_out[i] = ((binary_in < OUTPUT_WIDTH) && (binary_in == i)) ? 1'b1 : 1'b0;
    end
  endgenerate

endmodule