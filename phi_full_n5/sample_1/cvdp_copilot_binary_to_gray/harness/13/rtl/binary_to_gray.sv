
module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  always_comb begin
    gray_out = {binary_in[WIDTH-1], binary_in[WIDTH-2] ^ binary_in[WIDTH-1], binary_in[WIDTH-3] ^ binary_in[WIDTH-2], ..., binary_in[0]};
  end

endmodule
