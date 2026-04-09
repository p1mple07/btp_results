module binary_to_bcd (
    input  logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
);

  // Intermediate 20-bit shift register: 12 bits for BCD result, 8 bits for binary input
  logic [19:0] shift_reg;
  integer i;

  always_comb begin
    // Step 1: Initialize the shift register with 12 leading zeros and the binary input in the rightmost 8 bits
    shift_reg = {12'd0, binary_in};

    // Double Dabble Algorithm: Process each bit of the binary input (8 iterations)
    for (i = 0; i < 8; i = i + 1) begin
      // Left shift the entire register by 1 bit
      shift_reg = {shift_reg[18:0], 1'b0};

      // Check each non-overlapping 4-bit BCD digit and add 3 if the value is 5 or greater
      if (shift_reg[19:16] >= 5'd5)
        shift_reg[19:16] = shift_reg[19:16] + 3;
      if (shift_reg[15:12] >= 5'd5)
        shift_reg[15:12] = shift_reg[15:12] + 3;
      if (shift_reg[11:8]  >= 5'd5)
        shift_reg[11:8]  = shift_reg[11:8]  + 3;
    end

    // After processing all bits, the upper 12 bits of the shift register hold the BCD result.
    bcd_out = shift_reg[19:8];
  end

endmodule