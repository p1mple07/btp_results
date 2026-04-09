module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,
    output logic [11:0] binary_out,
    input logic bcd_in [(BCD_DIGITS*4)-1:0],
    output logic [BCD_DIGITS*4-1:0] bcd_out,
    input logic switch
);

  assign binary_out = switch ? BINARY_TO_BCD(binary_in, BCD_DIGITS, INPUT_WIDTH) : BCDFORWARD(bcd_in, BCD_DIGITS, INPUT_WIDTH, switch);
  assign bcd_out = switch ? BCD_TO_BINARY(binary_in, BCD_DIGITS, INPUT_WIDTH) : BCDFORWARD(bcd_in, BCD_DIGITS, INPUT_WIDTH, switch);

endmodule

function logic [11:0] BINARY_TO_BCD(logic [11:0] binary_in, int BCD_DIGITS, int INPUT_WIDTH, bool switch);
  logic [11:0] shift_reg;
  integer i;
  if (switch == 1'b1) begin
    shift_reg = {binary_in};
    for (i = 7; i >= 0; i = i - 1) begin
      if (shift_reg[11 + i] >= 5)
        shift_reg[11 + i] = shift_reg[11 + i] + 3;
      else
        shift_reg[11 + i] = shift_reg[11 + i];
    end
    bcd_out = shift_reg[11:8];
  end else begin
    for (i = 0; i < BCD_DIGITS*4; i++) begin
      logic temp = bcd_in[i*4 + 3] + bcd_in[i*4 + 2] * 2 + bcd_in[i*4 + 1] * 4 + bcd_in[i*4];
      logic prod = temp * 10;
      if (prod >= 10)
        bcd_out[i] = 1;
      else
        bcd_out[i] = 0;
    end
  end
end function

function logic [BCD_DIGITS*4-1:0] BCDFORWARD(logic [11:0] bcd_in, int BCD_DIGITS, int INPUT_WIDTH, bool switch);
  logic [BCD_DIGITS*4-1:0] output;
  if (switch == 1'b1) begin
    output = {bcd_in};
  end else begin
    for (i = 0; i < BCD_DIGITS*4; i++) begin
      logic temp = bcd_in[i*4 + 3] + bcd_in[i*4 + 2] * 2 + bcd_in[i*4 + 1] * 4 + bcd_in[i*4];
      logic prod = temp * 10;
      if (prod >= 10)
        bcd_out[i] = 1;
      else
        bcd_out[i] = 0;
    end
  end
end function
