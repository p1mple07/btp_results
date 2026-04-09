module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Properly initialized continuous assignment for the output
  assign gray_out = binary_in ^ (binary_in >> 1);

endmodule
