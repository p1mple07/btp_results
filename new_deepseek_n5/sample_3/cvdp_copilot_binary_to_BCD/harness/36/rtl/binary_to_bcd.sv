module binary_to_bcd (
    input  logic [ 7:0] binary_in,
    output logic [11:0] bcd_out
);
  logic [23:0] shift_reg;
  integer i;

  always @* begin
    shift_reg = {16'd0, binary_in};
    for (i = 0; i < 8; i = i + 1) begin
      if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
      if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
      if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
      shift_reg = shift_reg << 1;
    end
    bcd_out = shift_reg[19:8];
  end
endmodule