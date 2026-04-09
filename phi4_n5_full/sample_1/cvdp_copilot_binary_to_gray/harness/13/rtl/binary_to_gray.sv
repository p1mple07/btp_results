module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Convert MSB directly.
  assign gray_out[WIDTH-1] = binary_in[WIDTH-1];

  // Generate Gray code bits using XOR for remaining bits.
  genvar i;
  generate
    for (i = 0; i < WIDTH - 1; i = i + 1) begin
      assign gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
  endgenerate

endmodule