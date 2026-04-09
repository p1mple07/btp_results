module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,  // 8-bit binary input
    input logic switch,  // 1-bit switch: HIGH=bin_to_bcd, LOW=bcd_to_bin
    output logic [11:0] bcd_out,  // 12-bit BCD output (3 digits)
    output logic [INPUT_WIDTH-1:0] binary_out  // Binary output based on conversion mode
);

  // Parameters
  parameter BCD_DIGITS = 3;  // Number of BCD digits
  parameter INPUT_WIDTH = 9;  // Width of binary input

  // Intermediate shift register to hold binary and BCD values
  logic [19:0] shift_reg;  // 20-bit register: 12 for BCD and 8 for binary input
  integer i;

  // BCD-to-binary conversion logic
  logic [4*BCD_DIGITS-1:0] bcd_in;  // BCD input

  always_comb begin
    // Step 1: Initialize the shift register
    shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary input

    // Step 2: Perform the Double Dabble process
    if (switch == 1) begin
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
    else begin
      // BCD-to-binary conversion logic
      binary_out = 0;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        // Process each 4-bit BCD digit
        binary_out = (binary_out * 1010) + bcd_in[(i*4):((i*4)+4)];
      end
    end
  end

endmodule