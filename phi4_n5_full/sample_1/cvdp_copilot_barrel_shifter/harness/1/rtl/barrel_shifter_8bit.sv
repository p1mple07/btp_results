module barrel_shifter_8bit (
    input  logic [7:0]  data_in,    // 8-bit input data
    input  logic [2:0]  shift_bits, // Number of bits to shift (0 to 7)
    input  logic        left_right, // Shift direction: 1 = left, 0 = right
    output logic [7:0]  data_out    // 8-bit output data
);

  // Combinational logic implementation of the barrel shifter.
  // For left shifts, zeros are inserted into the LSB positions.
  // For right shifts, zeros are inserted into the MSB positions.
  //
  // The barrel shifter uses a case statement to select the appropriate shift amount.
  //
  // Example:
  //   If data_in = 8'b11001100, shift_bits = 3'b100 (4), and left_right = 1,
  //   then data_out = 8'b11000000.
  //
  //   If data_in = 8'b11001100, shift_bits = 3'b100 (4), and left_right = 0,
  //   then data_out = 8'b00001100.

  always_comb begin
    unique case (shift_bits)
      3'b000: data_out = data_in;
      3'b001: data_out = left_right ? (data_in << 1) : (data_in >> 1);
      3'b010: data_out = left_right ? (data_in << 2) : (data_in >> 2);
      3'b011: data_out = left_right ? (data_in << 3) : (data_in >> 3);
      3'b100: data_out = left_right ? (data_in << 4) : (data_in >> 4);
      3'b101: data_out = left_right ? (data_in << 5) : (data_in >> 5);
      3'b110: data_out = left_right ? (data_in << 6) : (data_in >> 6);
      3'b111: data_out = left_right ? (data_in << 7) : (data_in >> 7);
      default: data_out = data_in;
    endcase
  end

endmodule