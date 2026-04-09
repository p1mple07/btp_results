module binary_bcd_converter_twoway (
    input logic sw,
    input logic [INPUT_WIDTH-1:0] binary_in,
    input logic [BCD_DIGITS*4-1:0] bcd_in,
    output logic [INPUT_WIDTH-1:0] binary_out,
    output logic [BCD_DIGITS*4-1:0] bcd_out
);

  // Switch to determine conversion direction
  localparam logic CONVERT_FROM_BINARY = sw == 1;

  // Local variables
  logic [19:0] shift_reg;
  integer i;

  // For binary to BCD
  always_comb begin
    if (CONVERT_FROM_BINARY) begin
      // Step 1: Initialize shift register
      shift_reg = {12'd0, binary_in};

      // Step 2: Double dabble
      for (i = 0; i < 8; i = i + 1) begin
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

        // Shift left
        shift_reg = shift_reg << 1;
      end

      // Take upper 12 bits
      bcd_out = shift_reg[19:8];
    end
  end

  // For BCD to binary
  else begin
    // Initialize binary output
    binary_out = 0;

    // Process each BCD digit
    for (i = 0; i < 4; i = i + 1) begin
      // Extract 4-bit BCD digit
      logic [3:0] bcd_digit = bcd_in[i*4 : (i*4)+3];

      // Multiply by 1010 and add bcd_in[i*4]
      logic [7:0] temp = {binary_out[7:0], bcd_in[i*4]};
      temp = temp << 1;
      temp = temp + bcd_digit;

      // Update binary_out
      binary_out = temp;
    end
  end

endmodule
