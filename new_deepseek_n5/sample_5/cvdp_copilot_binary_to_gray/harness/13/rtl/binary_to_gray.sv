module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  assign gray_out[WIDTH-1] = binary_in[WIDTH-1];

  generate
    genvar i;
    for (i = 0; i < WIDTH - 1; i = i + 1) begin
      assign gray_out[i] = binary_in[i+1] ^ binary_in[i];
    end
  endgenerate

  always_+ @(posedge binary_in[0]) begin
    gray_out = binary_in;
  end
endmodule