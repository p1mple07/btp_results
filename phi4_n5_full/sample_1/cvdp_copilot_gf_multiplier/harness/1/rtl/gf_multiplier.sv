module gf_multiplier(
    input  logic [3:0] A,    // Multiplicand (4-bit)
    input  logic [3:0] B,    // Multiplier (4-bit)
    output logic [3:0] result // GF(2^4) product (4-bit)
);

  // This combinational block implements GF(2^4) multiplication using the
  // irreducible polynomial x^4 + x + 1 (represented as 5'b10011).
  // The algorithm iterates over each bit of B (from LSB to MSB), conditionally
  // XORs the current multiplicand into the result, shifts the multiplicand left,
  // and performs polynomial reduction if an overflow (MSB=1) occurs.
  //
  // A 5-bit temporary variable (tmp) is used to hold the multiplicand during
  // shifting so that any overflow can be detected and reduced.
  //
  // Polynomial reduction:
  //   If after shifting, the MSB of tmp (bit[4]) is 1, then:
  //     tmp = {1'b0, (tmp XOR 5'b10011)[3:0]}
  //   This ensures that only the lower 4 bits are retained.
  //
  // The multiplication result is accumulated in result_reg.

  always_comb begin
    reg [3:0] result_reg;  // Intermediate 4-bit result
    reg [4:0] tmp;          // 5-bit temporary variable for multiplicand
    integer i;
    
    result_reg = 4'b0;
    // Initialize tmp with A in the lower 4 bits and MSB = 0.
    tmp = {1'b0, A};

    // Iterate over each bit of multiplier B (4 iterations for 4-bit values)
    for (i = 0; i < 4; i = i + 1) begin
      // If the current bit of B is 1, XOR the current multiplicand (lower 4 bits)
      // into the result.
      if (B[i])
        result_reg = result_reg ^ tmp[3:0];

      // Shift the multiplicand left by 1 bit.
      tmp = tmp << 1;

      // If an overflow occurs (MSB of tmp is 1), perform polynomial reduction.
      if (tmp[4])
        tmp = {1'b0, (tmp ^ 5'b10011)[3:0]};
    end

    result = result_reg;
  end

endmodule