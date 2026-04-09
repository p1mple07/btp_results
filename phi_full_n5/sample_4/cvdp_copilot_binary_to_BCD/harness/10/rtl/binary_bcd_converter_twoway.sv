
module binary_bcd_converter_twoway (
    input logic [1:0] switch, // 2-bit switch to select conversion mode
    input logic [INPUT_WIDTH-1:0] binary_in,
    input logic [(BCD_DIGITS*4)-1:0] bcd_in,
    output logic [(BCD_DIGITS*4)-1:0] bcd_out,
    output logic [(INPUT_WIDTH-1):0] binary_out
);

  // Initialization
  logic [INPUT_WIDTH-1:0] temp_binary_out = 0;

  // Conversion Logic
  always_comb begin
    if (switch == 2'b00) begin // Binary-to-BCD
      // Step 1: Initialize the shift register
      logic [19:0] shift_reg = {12'd0, binary_in};

      // Step 2: Perform the Double Dabble process
      for (integer i = 0; i < 8; i = i + 1) begin
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

        shift_reg = shift_reg << 1;
      end

      // Step 3: Assign the upper 12 bits of the shift register to BCD output
      bcd_out = shift_reg[19:8];
    end
    else if (switch == 2'b01) begin // BCD-to-Binary
      // Initialization:
      temp_binary_out = 0;

      // Iterate Over BCD Digits
      integer i;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        if (bcd_in[(i*4)-1:0] >= 10'd10) begin
          temp_binary_out = (temp_binary_out << 4) | (bcd_in[(i*4)-1:0] - 10'd10);
        end
      end

      // Final Result
      binary_out = temp_binary_out;
    end
  end

endmodule
