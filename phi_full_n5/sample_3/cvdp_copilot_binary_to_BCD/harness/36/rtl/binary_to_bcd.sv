module binary_to_bcd (
    input  logic [7:0] binary_in,
    output logic [11:0] bcd_out
);
  // Removed unused signal 'shift_reg'
  // Removed unused signal 'shift_reg_temp'

  integer i;

  always @* begin
    // No width mismatch issue since we are not using shift_reg
    for (i = 0; i < 8; i = i + 1) begin
      if (binary_in[7] >= 5) binary_in[7] = binary_in[7] + 3;
      binary_in = binary_in << 1;
      // Corrected the shift by excluding the overflow bits
      if (binary_in[7:5] >= 5) binary_in[7:5] = binary_in[7:5] + 3;
      if (binary_in[5:3] >= 5) binary_in[5:3] = binary_in[5:3] + 3;
      if (binary_in[1:0] >= 5) binary_in[1:0] = binary_in[1:0] + 3;
    end
    bcd_out = binary_in;
  end
endmodule
