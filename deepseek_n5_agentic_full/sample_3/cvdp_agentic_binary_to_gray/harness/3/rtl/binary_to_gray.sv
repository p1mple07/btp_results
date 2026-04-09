module binary_to_gray
  parameter WIDTH = 6;

  reg [WIDTH-1:0] binary_in;  // Binary input
  wire [WIDTH-1:0] gray_out;  // Gray code output

  binary_to_gray #(
      .WIDTH(WIDTH)
  ) uut (
      .binary_in(binary_in),
      .gray_out(gray_out)
  );
endmodule