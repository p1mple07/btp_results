module gf_multiplier(
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] result
);

  // Internal registers for the intermediate multiplicand and result.
  logic [3:0] mult;
  logic [3:0] res;

  // Combinational logic for GF(2^4) multiplication using the irreducible polynomial x^4 + x + 1.
  // Note: The reduction constant is taken as 4'b0011 (i.e. x + 1) after dropping the implicit x^4 term.
  always_comb begin
    res = 4'b0;       // Initialize result to 0.
    mult = A;          // Set multiplicand to input A.
    integer i;
    for (i = 0; i < 4; i = i + 1) begin
      // If the current bit of B is 1, XOR the multiplicand with the result.
      if (B[i])
        res = res ^ mult;
      
      // Shift multiplicand left by 1 bit.
      // Check if the MSB (bit3) of the current multiplicand is 1 (overflow).
      if (mult[3])
        mult = (mult << 1) ^ 4'b0011;  // Perform polynomial reduction.
      else
        mult = mult << 1;
    end
    result = res; // Drive the final output.
  end

endmodule