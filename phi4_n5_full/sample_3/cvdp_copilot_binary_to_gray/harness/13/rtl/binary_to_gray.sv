module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Use a generate block to drive all bits of gray_out from binary_in in a combinational manner.
  // The MSB is directly assigned, and the remaining bits are generated using XOR of adjacent bits.
  genvar i;
  generate
    // MSB: same as binary_in MSB
    assign gray_out[WIDTH-1] = binary_in[WIDTH-1];

    // For each remaining bit, generate Gray code by XORing adjacent bits.
    for (i = 0; i < WIDTH - 1; i = i + 1) begin
      assign gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
  endgenerate

endmodule