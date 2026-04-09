module binary_to_bcd (
    input  logic [7:0] binary_in,
    output logic [11:0] bcd_out
);
  logic [11:0] shift_reg;
  integer i;

  always @* begin
    shift_reg = {12'b0, binary_in}; // Corrected width for concatenation
    for (i = 0; i < 8; i = i + 1) begin
      // Increment digits by 3, wrapping around if over 5
      shift_reg[11:8] = (shift_reg[11:8] + 3) < 5'b11000 ? shift_reg[11:8] + 3 : shift_reg[11:8] << 1;
      shift_reg[15:12] = (shift_reg[15:12] + 3) < 5'b11000 ? shift_reg[15:12] + 3 : shift_reg[15:12] << 1;
      shift_reg[19:16] = (shift_reg[19:16] + 3) < 5'b11000 ? shift_reg[19:16] + 3 : shift_reg[19:16] << 1;
      shift_reg = {shift_reg[19:16], shift_reg[15:12], shift_reg[11:8]}; // Correcting concatenation order
    end
    bcd_out = shift_reg;
  end
endmodule
