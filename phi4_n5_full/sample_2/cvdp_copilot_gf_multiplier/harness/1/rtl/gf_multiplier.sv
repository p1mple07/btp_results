module gf_multiplier (
  input  logic [3:0] A,  // Multiplicand (4-bit)
  input  logic [3:0] B,  // Multiplier (4-bit)
  output logic [3:0] result  // Product (4-bit)
);

  // In this implementation, we use a 5-bit register for the multiplicand
  // during shifting so that we can check for overflow (MSB) and perform
  // polynomial reduction with the irreducible polynomial x^4 + x + 1 (5'b10011).
  // The final multiplicand is maintained as a 4-bit value.
  
  always_comb begin
    logic [3:0] res;       // Intermediate result (4-bit)
    logic [4:0] mult;      // Multiplicand as a 5-bit value
    integer i;
    
    res = 4'b0;
    // Initialize multiplicand with an extra leading zero to form a 5-bit value.
    mult = {1'b0, A};
    
    // Process each bit of multiplier B (LSB to MSB)
    for (i = 0; i < 4; i = i + 1) begin
      // If the current bit of B is 1, XOR the lower 4 bits of the multiplicand with result.
      if (B[i])
        res = res ^ mult[3:0];
        
      // Shift multiplicand left by 1 bit (5-bit shift to capture potential overflow)
      mult = mult << 1;
      
      // If overflow occurs (MSB is 1), perform polynomial reduction.
      if (mult[4])
        mult = mult ^ 5'b10011;
      
      // Retain only the lower 4 bits for the next iteration.
      mult = mult[3:0];
    end
    
    result = res;
  end

endmodule