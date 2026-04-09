module binary_bcd_converter_twoway #(
  parameter int BCD_DIGITS = 3,         // Number of BCD digits (minimum 1, default 3)
  parameter int INPUT_WIDTH = 9         // Width of the binary input/output (default 9)
)(
  input  logic                      switch,              // 1-bit mode select: HIGH = binary-to-BCD, LOW = BCD-to-binary
  input  logic [INPUT_WIDTH-1:0]    binary_in,           // Binary input for binary-to-BCD conversion
  input  logic [(BCD_DIGITS*4)-1:0]  bcd_in,              // BCD input for BCD-to-binary conversion
  output logic [INPUT_WIDTH-1:0]    binary_out,          // Binary output (result of BCD-to-binary conversion)
  output logic [(BCD_DIGITS*4)-1:0]  bcd_out              // BCD output (result of binary-to-BCD conversion)
);

  always_comb begin
    // Default assignments for unused outputs.
    // In binary-to-BCD mode (switch HIGH), only bcd_out is computed.
    // In BCD-to-binary mode (switch LOW), only binary_out is computed.
    binary_out = '0;
    bcd_out    = '0;

    if (switch) begin
      // ---------- Binary-to-BCD Conversion (Double Dabble Algorithm) ----------
      // Create a shift register with (4*BCD_DIGITS) bits for BCD and INPUT_WIDTH bits for binary input.
      logic [(4*BCD_DIGITS + INPUT_WIDTH)-1:0] shift_reg;
      integer i, j;

      // Step 1: Initialize the shift register.
      // Upper (4*BCD_DIGITS) bits are 0; lower INPUT_WIDTH bits are binary_in.
      shift_reg = { {(4*BCD_DIGITS){1'b0}}, binary_in };

      // Step 2: Perform the Double Dabble process for each bit of the binary input.
      for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
        // For each BCD digit group (each group is 4 bits), add 3 if the digit is 5 or greater.
        for (j = 0; j < BCD_DIGITS; j = j + 1) begin
          // Extract the j-th BCD digit (group) from the shift register.
          // Group 0 is the most significant (bits [(4*BCD_DIGITS)-1 -: 4]),
          // Group j is located at bits [((j+1)*4 - 1) -: 4].
          if (shift_reg[((j+1)*4 - 1) -: 4] >= 5)
            shift_reg[((j+1)*4 - 1) -: 4] = shift_reg[((j+1)*4 - 1) -: 4] + 3;
        end
        // Shift the entire register left by 1 bit.
        shift_reg = shift_reg << 1;
      end

      // Step 3: The upper (4*BCD_DIGITS) bits of the shift register now contain the BCD result.
      // Extract those bits. For a total register width of (4*BCD_DIGITS + INPUT_WIDTH),
      // the BCD output is from bit index [(4*BCD_DIGITS + INPUT_WIDTH - 1) -: (4*BCD_DIGITS)].
      bcd_out = shift_reg[(4*BCD_DIGITS + INPUT_WIDTH - 1) -: (4*BCD_DIGITS)];
    end
    else begin
      // ---------- BCD-to-Binary Conversion ----------
      // The algorithm processes each 4-bit BCD digit from the most significant digit (MSD)
      // to the least significant digit (LSD) and computes:
      //    binary_out = (binary_out * 10) + digit_value
      integer binary_temp;
      integer j;
      logic [3:0] digit;

      binary_temp = 0;
      // Loop over each BCD digit.
      // The most significant digit is at the left end of bcd_in.
      for (j = 0; j < BCD_DIGITS; j = j + 1) begin
        // Extract the j-th BCD digit.
        // For j = 0, this extracts the MSB group:
        //    bcd_in[(BCD_DIGITS*4 - 1) -: 4]
        // For subsequent digits, the slice shifts right.
        digit = bcd_in[(BCD_DIGITS*4 - 1 - j*4) -: 4];
        binary_temp = (binary_temp * 10) + digit;
      end
      // Drive the binary output with the computed value.
      binary_out = binary_temp;
    end
  end

endmodule