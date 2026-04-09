module binary_bcd_converter_twoway (
    input logic [INPUT_WIDTH-1:0] binary_in,
    input logic [BCD_DIGITS*4-1:0] bcd_in,
    input switch,
    output logic [BCD_DIGITS*4-1:0] binary_out,
    output logic [BCD_DIGITS*4-1:0] bcd_out
);

  parameter INPUT_WIDTH = 9;
  parameter BCD_DIGITS = 3;

  input switch;

  logic [19:0] shift_reg;
  logic [32:0] temp_reg;
  integer i;

  case (switch)
    1:  // binary-to-BCD
      shift_reg = {12'd0, binary_in};
      for (i = 0; i < 8; i = i + 1) begin
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
        shift_reg = shift_reg << 1;
      end
      bcd_out = shift_reg[19:8];
    0:  // BCD-to-binary
      binary_out = 0;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        digit = bcd_in[(i*4):((i*4)+4)];
        binary_out = (binary_out << 4) + digit;
      end
  endcase

endmodule