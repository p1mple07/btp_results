Module declaration with width parameter
module binary_to_gray #(
    parameter WIDTH = 6
);

  // Input binary word of WIDTH bits
  input [WIDTH-1:0] binary_in;

  // Output Gray code word of WIDTH bits
  output [WIDTH-1:0] gray_out;

  // Always combinatorial section for Gray code calculation
  always_comb begin
      // Create temporary output signal
      reg [WIDTH-1:0] gray_bits;

      // Compute Gray code using bitwise XOR
      gray_bits[0] = binary_in[0];
      gray_bits[1] = binary_in[1] ^ binary_in[0];
      gray_bits[2] = binary_in[2] ^ binary_in[1];
      gray_bits[3] = binary_in[3] ^ binary_in[2];
      gray_bits[4] = binary_in[4] ^ binary_in[3];
      gray_bits[5] = binary_in[5] ^ binary_in[4];

      // Assign final output
      gray_out = gray_bits;
  end

endmodule