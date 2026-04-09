module binary_to_bcd (
    input  logic [ 7:0] binary_in,
    output logic [11:0] bcd_out
);
  // Initialize the shift register with the binary input
  logic [11:0] shift_reg;

  // Shift and add logic to convert binary to BCD
  always @* begin
    if (binary_in[7]) begin
      shift_reg = {12'd0, binary_in};
      shift_reg = shift_reg >> 1;
      shift_reg[11] = shift_reg[11] + 3; // Correct shift and add for the MSB
      shift_reg[10] = shift_reg[10] + shift_reg[11] + (shift_reg[10] >= 5); // Correct shift and add for the next digit
      shift_reg[9] = shift_reg[9] + shift_reg[10] + (shift_reg[9] >= 5); // Correct shift and add for the next digit
      shift_reg[8] = shift_reg[8] + shift_reg[9] + (shift_reg[8] >= 5); // Correct shift and add for the next digit
    end
    bcd_out = shift_reg;
  end
endmodule
