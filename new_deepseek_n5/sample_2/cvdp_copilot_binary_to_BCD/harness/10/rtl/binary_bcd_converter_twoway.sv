module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out,  // 12-bit BCD output
    output logic [INPUT_WIDTH-1:0] binary_out,  // BCD-to-binary output
    input switch switch
);

  // Parameters
  parameter BCD_DIGITS = 3;
  parameter INPUT_WIDTH = 9;

  // Internal signals
  logic [19:0] shift_reg;
  integer i;

  always_comb begin
    // Case 1: Binary-to-BCD Conversion
    if (switch == 1) begin
      // Step 1: Initialize the shift register
      shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary_in

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
    end

    // Case 2: BCD-to-Binary Conversion
    else begin
      // Step 1: Initialize binary_out to 0
      binary_out = 0;

      // Step 2: Iterate over each BCD digit
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        // Extract the current 4-bit BCD digit
        logic [3:0] digit = bcd_in[(4*i + 3): (4*i)];
        
        // Multiply binary_out by 10 (equivalent to shifting left by 4 bits) and add the digit
        binary_out = (binary_out << 4) + digit;
      end
    end
  end
endmodule