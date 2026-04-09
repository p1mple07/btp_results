module gf_multiplier(input  logic [3:0] A,
                     input  logic [3:0] B,
                     output logic [3:0] result);
  
  // This combinational module implements GF(2^4) multiplication using
  // the irreducible polynomial x^4 + x + 1 (represented as 5'b10011).
  // The algorithm processes each bit of B (LSB to MSB). For each bit:
  //   - If the current bit of B is 1, XOR the current multiplicand into the result.
  //   - Shift the multiplicand left by one bit (appending a 0).
  //   - If the shifted multiplicand overflows (MSB == 1), perform polynomial
  //     reduction by XORing with 5'b10011 and then dropping the MSB.
  
  always_comb begin
    // Use a 5-bit register for the multiplicand (extra MSB for overflow)
    logic [4:0] mult;
    // 4-bit register for the accumulating result
    logic [3:0] res;
    
    res  = 4'b0;
    // Initialize multiplicand with MSB = 0 followed by A
    mult = {1'b0, A};
    
    // Process each bit of the 4-bit multiplier B (from LSB to MSB)
    for (int i = 0; i < 4; i++) begin
      if (B[i])
        res = res ^ mult[3:0];
      
      // Shift the multiplicand left by 1 bit (append 0)
      logic [4:0] new_mult;
      new_mult = {mult[3:0], 1'b0};
      
      // Check for overflow (MSB of new_mult is 1)
      if (new_mult[4])
        // Perform polynomial reduction: XOR with 5'b10011 then drop the MSB
        mult = {1'b0, (new_mult ^ 5'b10011)[3:0]};
      else
        mult = new_mult;
    end
    
    result = res;
  end
  
endmodule