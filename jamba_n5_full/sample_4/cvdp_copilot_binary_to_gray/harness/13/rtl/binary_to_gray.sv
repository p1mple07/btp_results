module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  logic gray_out_d1; // Removed unused signal

  assign gray_out[WIDTH-1] = binary_in[WIDTH-1];

  assign gray_out[i] = binary_in[i+1] ^ binary_in[i] for i = 0 to WIDTH - 2;

  always_ff @(posedge binary_in[0]) begin
    gray_out = binary_in;
  end

endmodule
