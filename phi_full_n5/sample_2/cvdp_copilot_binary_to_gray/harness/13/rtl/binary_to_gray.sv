module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Removed unused signal

  // Correctly use continuous assignment instead of procedural block
  assign gray_out = binary_in;

  // Eliminate multi-driven signal by ensuring all assignments are continuous
  genvar i;
  generate
    for (i = 0; i < WIDTH - 1; i = i + 1) begin
      assign gray_out[i] = binary_in[(i+1) +: WIDTH] ^ binary_in[i +: WIDTH];
    end
  endgenerate

endmodule
