module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out,  // 12-bit BCD output (3 digits)
    input logic switch,  // Conversion switch (HIGH: binary-to-BCD, LOW: BCD-to-binary)
    input parameter BCD_DIGITS = 3,  // Number of BCD digits
    input parameter INPUT_WIDTH = 9  // Width of binary input
);

  // Intermediate shift register to hold binary and BCD values
  logic [19:0] shift_reg;
  logic [INPUT_WIDTH-1:0] binary_out;
  integer i;

  // Parameters for BCD-to-binary conversion
  parameter num_digits = BCD_DIGITS;

  always_comb begin
    case (switch)
      1:
        // Step 1: Initialize the shift register
        shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary input

        // Step 2: Perform the Double Dabble process
        for (i = 0; i < 8; i = i + 1) begin
          // Check if each BCD digit is 5 or greater; if so, add 3
          if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
          if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
          if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

          // Shift the entire register left by 1 bit
          shift_reg = shift_reg << 1;
        end

        // Step 3: Assign the upper 12 bits of the shift register to BCD output
        bcd_out = shift_reg[19:8];
      0:
        // BCD-to-binary conversion logic
        binary_out = 0;
        for (i = 0; i < num_digits; i = i + 1) begin
          // Extract the current BCD digit
          logic [3:0] digit = bcd_in[(4*i + 3):4*i];
          
          // Update binary_out
          binary_out = (binary_out * 1010) + digit;
        end
    end
  end

endmodule