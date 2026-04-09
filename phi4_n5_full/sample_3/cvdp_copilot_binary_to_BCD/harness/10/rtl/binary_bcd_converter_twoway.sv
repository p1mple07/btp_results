module binary_bcd_converter_twoway #(
  parameter int BCD_DIGITS = 3,
  parameter int INPUT_WIDTH = 9
)(
  input  logic switch,
  input  logic bcd_in [(BCD_DIGITS*4)-1:0],
  input  logic binary_in [INPUT_WIDTH-1:0],
  output logic binary_out [INPUT_WIDTH-1:0],
  output logic bcd_out [(BCD_DIGITS*4)-1:0]
);

  // Local variable for binary-to-BCD conversion
  // The shift register holds BCD digits (top part) and binary input (bottom part)
  logic [((BCD_DIGITS*4) + INPUT_WIDTH)-1:0] shift_reg;
  integer i, j;
  int total_bits;

  always_comb begin
    if (switch) begin
      // --- Binary-to-BCD Conversion (Double Dabble Algorithm) ---
      // total_bits = width of shift register = BCD_DIGITS*4 + INPUT_WIDTH
      total_bits = (BCD_DIGITS*4) + INPUT_WIDTH;
      // Initialize: BCD part as zeros and binary part as binary_in
      shift_reg = { {BCD_DIGITS*4{1'b0}}, binary_in };

      // Process each bit of the binary input
      for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
        // For each BCD digit in the shift register, check if its value is >= 5.
        // If so, add 3 to that digit.
        for (j = 0; j < BCD_DIGITS; j = j + 1) begin
          int high = total_bits - 1 - j*4;
          int low  = high - 3;
          if (shift_reg[high:low] >= 5)
            shift_reg[high:low] = shift_reg[high:low] + 3;
        end
        // Shift the entire register left by 1 bit
        shift_reg = shift_reg << 1;
      end

      // After processing, the upper (BCD_DIGITS*4) bits form the BCD output.
      bcd_out = shift_reg[total_bits-1 -: (BCD_DIGITS*4)];
      // In binary-to-BCD mode, binary_out mirrors binary_in.
      binary_out = binary_in;
    end
    else begin
      // --- BCD-to-Binary Conversion ---
      // The conversion iteratively processes each 4-bit BCD digit from MSB to LSB.
      // For each digit: binary_out = (binary_out * 10) + digit.
      logic [INPUT_WIDTH-1:0] temp;
      temp = 0;

      // Loop over each BCD digit (MSB first)
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        int start = (BCD_DIGITS*4) - 1 - i*4;
        logic [3:0] digit;
        digit = bcd_in[start -: 4];
        temp = (temp * 4'd10) + digit;
      end

      // Truncate the result to INPUT_WIDTH bits and assign to binary_out.
      binary_out = temp[INPUT_WIDTH-1:0];
      // In BCD-to-binary mode, bcd_out mirrors bcd_in.
      bcd_out = bcd_in;
    end
  end

endmodule