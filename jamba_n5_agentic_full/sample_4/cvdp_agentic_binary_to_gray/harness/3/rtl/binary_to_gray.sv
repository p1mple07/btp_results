module binary_to_gray #(
    parameter WIDTH = 6
) (
    input logic [WIDTH-1:0] binary_in,
    output logic [WIDTH-1:0] gray_out
);

  logic [WIDTH-1:0] gray;

  assign gray = binary_in[0];
  for (integer i = 1; i < WIDTH; i++) begin
    gray = binary_in[i] ^ binary_in[i-1];
  end

  assign gray_out = gray;
endmodule
