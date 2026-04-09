module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out,  // 12-bit BCD output (3 digits)
    input logic switch  // Conversion switch (HIGH: binary-to-BCD, LOW: BCD-to-binary)
);

  // Parameters
  parameter BCD_DIGITS = 3;  // Number of BCD digits
  parameter INPUT_WIDTH = 9;  // Width of binary input

  // Intermediate shift register to hold binary and BCD values
  logic [19:0] shift_reg;    // 20-bit register: 12 for BCD and 8 for binary
  integer i;

  // Case statement to handle conversion modes
  case (switch)
    1:
      // Binary-to-BCD conversion
      shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary input

      for (i = 0; i < 8; i = i + 1) begin
        // Check if each BCD digit is 5 or greater; if so, add 3
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

        // Shift the entire register left by 1 bit
        shift_reg = shift_reg << 1;
      end

      // Assign the upper 12 bits of the shift register to BCD output
      bcd_out = shift_reg[19:8];
    0:
      // BCD-to-binary conversion
      input logic [4:0] digit;  // For extracting BCD digits
      integer j;

      // Initialize binary output
      binary_out = 0;

      // Process each BCD digit
      for (j = 0; j < BCD_DIGITS; j = j + 1) begin
        // Extract current BCD digit
        digit = bcd_in[(j*4):((j*4)+4)];
        
        // Multiply accumulated binary value by 10 and add the digit
        binary_out = (binary_out << 4) + (binary_out & 15);
        binary_out = (binary_out << 4) + digit;
      end
  endcase

endmodule