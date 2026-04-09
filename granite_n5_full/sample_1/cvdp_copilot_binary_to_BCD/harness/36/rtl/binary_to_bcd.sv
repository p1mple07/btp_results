module binary_to_bcd (
    input  logic [ 7:0] binary_in,
    output logic [11:0] bcd_out
);
  // Signal assignments and operations involving mismatched bit-widths
  logic [31:0] shift_reg;
  logic [27:0] shift_reg_temp;
  integer i;

  // Unused signals removal
  assign unused_signal = shift_reg[31:28];

  always @* begin
    shift_reg = {12'd0, binary_in};
    for (i = 0; i < 8; i = i + 1) begin
      if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 3;
      if (shift_reg[31:28] >= 5) shift_reg[31:28] = shift_reg[31:28] + 3;
      shift_reg = shift_reg << 1;
    end
    bcd_out = shift_reg[31:16];
  end
endmodule