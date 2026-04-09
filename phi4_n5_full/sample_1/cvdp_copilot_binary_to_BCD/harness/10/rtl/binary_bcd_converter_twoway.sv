module binary_bcd_converter_twoway #(
  parameter integer BCD_DIGITS = 3,      // Number of BCD digits (min 1, default 3)
  parameter integer INPUT_WIDTH = 9     // Width of binary input/output (default 9)
) (
  input  logic                      switch,                  // 1 = binary-to-BCD, 0 = BCD-to-binary
  input  logic [BCD_DIGITS*4-1:0]    bcd_in,                  // BCD input value
  input  logic [INPUT_WIDTH-1:0]     binary_in,               // Binary input value
  output logic [INPUT_WIDTH-1:0]     binary_out,              // Binary output value (result of BCD-to-binary conversion)
  output logic [BCD_DIGITS*4-1:0]     bcd_out                 // BCD output value (result of binary-to-BCD conversion)
);

  // Define local parameters for internal widths
  localparam integer BCD_WIDTH   = BCD_DIGITS * 4;
  localparam integer SHIFT_WIDTH = BCD_WIDTH + INPUT_WIDTH;

  always_comb begin
    if (switch) begin
      // -------------------------------
      // Binary-to-BCD Conversion using Double Dabble Algorithm
      // -------------------------------
      // Initialize a shift register with BCD digits (all zeros) in the upper bits
      // and the binary input in the lower bits.
      logic [SHIFT_WIDTH-1:0] shift_reg;
      integer i, j;
      shift_reg = {BCD_WIDTH{1'b0}, binary_in};

      // Process each bit of the binary input.
      // For each bit, check each BCD digit. In the original algorithm the check order
      // is from the least significant digit (which will end up in bcd_out[BCD_WIDTH-1:0])
      // to the most significant digit. To mimic that, we loop j from BCD_DIGITS-1 downto 0.
      for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
        for (j = BCD_DIGITS - 1; j >= 0; j = j - 1) begin
          // Extract the current 4-bit BCD digit using the - : operator.
          if (shift_reg[((j+1)*4)-1 -: 4] >= 5)
            shift_reg[((j+1)*4)-1 -: 4] = shift_reg[((j+1)*4)-1 -: 4] + 3;
        end
        // Shift the entire register left by 1 bit.
        shift_reg = shift_reg << 1;
      end

      // The upper BCD_WIDTH bits now hold the BCD representation.
      bcd_out = shift_reg[SHIFT_WIDTH-1 -: BCD_WIDTH];
      // In binary-to-BCD mode, binary_out is not used.
      binary_out = '0;
    end
    else begin
      // -------------------------------
      // BCD-to-Binary Conversion (Combinational Logic)
      // -------------------------------
      // The algorithm processes the BCD input from the most significant digit to the least.
      // For each digit, it multiplies the accumulated result by 10 and adds the digit.
      // Multiplication by 10 in binary can be implemented as: (result << 1) + (result << 3).
      logic [INPUT_WIDTH-1:0] temp;
      integer j;
      temp = '0;

      // Loop over each 4-bit BCD digit. The most significant digit is at the leftmost bits.
      for (j = 0; j < BCD_DIGITS; j = j + 1) begin
        // Multiply current result by 10 and add the current BCD digit.
        temp = (temp << 1) + (temp << 3) + bcd_in[(j+1)*4-1 -: 4];
      end

      binary_out = temp;
      // In BCD-to-binary mode, bcd_out is not used.
      bcd_out = '0;
    end
  end

endmodule