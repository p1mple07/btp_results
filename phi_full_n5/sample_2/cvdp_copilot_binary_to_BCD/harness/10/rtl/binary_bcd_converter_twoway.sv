
module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,  // 8-bit binary input
    input logic [11:0] bcd_in,    // 12-bit BCD input
    input logic switch,          // 1-bit switch for conversion mode
    output logic [INPUT_WIDTH-1:0] binary_out, // Binary output
    output logic [(BCD_DIGITS*4)-1:0] bcd_out     // BCD output
);

  parameter INPUT_WIDTH = 9;
  parameter BCD_DIGITS = 3;

  // Intermediate shift register to hold binary and BCD values
  logic [20:0] shift_reg;  // 21-bit register: 12 for BCD and 9 for binary input
  integer i;

  always_comb begin
    if (switch == 1) begin
      // Binary to BCD conversion
      shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary input

      // Perform the Double Dabble process
      for (i = 0; i < 8; i = i + 1) begin
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

        shift_reg = shift_reg << 1;
      end

      // Assign the upper 12 bits of the shift register to BCD output
      bcd_out = shift_reg[19:8];
    end
    else begin
      // BCD to Binary conversion
      bcd_out = {binary_out};

      // Initialize binary_out as 0
      binary_out = 0;

      // Iterate Over BCD Digits
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        // Extract 4-bit BCD digit
        logic [3:0] bcd_digit = bcd_in[(i*4):(i*4+3)];

        // Convert BCD to Binary
        binary_out = (binary_out * 1010'b11) + bcd_digit;
      end
    end
  end

endmodule
