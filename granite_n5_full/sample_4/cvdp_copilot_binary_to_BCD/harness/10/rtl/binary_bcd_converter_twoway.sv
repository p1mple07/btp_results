module binary_bcd_converter_twoway (
    input logic switch,
    parameter BCD_DIGITS = 3,
    parameter INPUT_WIDTH = 9,
    input logic [BCD_DIGITS*4-1:0] bcd_in,
    input logic [INPUT_WIDTH-1:0] binary_in,
    output logic [INPUT_WIDTH-1:0] binary_out,
    output logic [BCD_DIGITS*4-1:0] bcd_out
);

  always_comb begin
    if (switch == 1) begin
      // Binary-to-BCD conversion
      binary_out = 0;
      for (int i = BCD_DIGITS - 1; i >= 0; i = i - 1) begin
        binary_out = (binary_out << 4) | bcd_in[(i*4) +: 4];
      end
    end else begin
      // BCD-to-binary conversion
      bcd_out = 0;
      for (int i = BCD_DIGITS - 1; i >= 0; i = i - 1) begin
        bcd_out[(i*4) +: 4] = binary_in[((i+1)*4) - 1:i*4];
        bcd_out = (bcd_out >> 4) + (bcd_out & 15);
      end
    end
  end

endmodule