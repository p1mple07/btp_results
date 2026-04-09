module binary_to_gray #(
    parameter WIDTH = 8
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  localparam GRAY_WIDTH = WIDTH - 1;

  wire [GRAY_WIDTH:0] gray_code_bus;

  always @(*) begin
    gray_code_bus = binary_in[GRAY_WIDTH] ^ binary_in[GRAY_WIDTH-1:1];
  end

  assign gray_out = gray_code_bus[WIDTH-1:0];

endmodule