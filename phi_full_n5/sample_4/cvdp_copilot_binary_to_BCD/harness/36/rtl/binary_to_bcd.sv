
module binary_to_bcd (
    input  logic [ 7:0] binary_in,
    output logic [11:0] bcd_out
);
  logic [11:0] shift_reg;
  integer i;

  always @* begin
    shift_reg = {12'd0, binary_in};
    for (i = 0; i < 8; i = i + 1) begin
      shift_reg[11:8] = (shift_reg[11:8] + 3) < 15 ? shift_reg[11:8] + 3 : shift_reg[11:8];
      shift_reg[15:12] = (shift_reg[15:12] + 3) < 15 ? shift_reg[15:12] + 3 : shift_reg[15:12];
      shift_reg[19:16] = (shift_reg[19:16] + 3) < 15 ? shift_reg[19:16] + 3 : shift_reg[19:16];
      shift_reg = {shift_reg[19:16], shift_reg[15:8]};
    end
    bcd_out = shift_reg;
  end
endmodule
