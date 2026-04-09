module binary_bcd_converter_twoway #(
  parameter integer BCD_DIGITS = 3,
  parameter integer INPUT_WIDTH = 9
) (
  input  logic [INPUT_WIDTH-1:0] binary_in,
  input  logic [BCD_DIGITS*4-1:0] bcd_in,
  input  logic                   switch,
  output logic [INPUT_WIDTH-1:0] binary_out,
  output logic [BCD_DIGITS*4-1:0] bcd_out
);

  always_comb begin
    if (switch == 1) begin
      // Binary-to-BCD conversion using the Double Dabble algorithm
      integer i, j;
      // The shift register holds BCD digits in the upper portion and the binary input in the lower portion.
      // Total width = (BCD_DIGITS*4) + INPUT_WIDTH.
      logic [BCD_DIGITS*4 + INPUT_WIDTH - 1:0] shift_reg;
      
      // Initialize: place BCD portion as zeros and binary input in the lower bits.
      shift_reg = {BCD_DIGITS*4{1'b0}, binary_in};
      
      // For each bit of the binary input, perform nibble adjustments then shift left.
      for (i = 0; i < INPUT_WIDTH; i = i + 1) begin
        // For each BCD digit (nibble) in the shift register:
        for (j = 0; j < BCD_DIGITS; j = j + 1) begin
          // The nibble for digit j is located in bits:
          //   starting index = (j+1)*4 + INPUT_WIDTH - 1, width = 4.
          if (shift_reg[((j+1)*4 + INPUT_WIDTH - 1) -: 4] >= 5)
            shift_reg[((j+1)*4 + INPUT_WIDTH - 1) -: 4] = 
                  shift_reg[((j+1)*4 + INPUT_WIDTH - 1) -: 4] + 3;
        end
        // Shift the entire register left by 1 bit.
        shift_reg = shift_reg << 1;
      end
      
      // The BCD output is the upper (BCD_DIGITS*4) bits of the shift register.
      bcd_out = shift_reg[BCD_DIGITS*4 + INPUT_WIDTH - 1 -: BCD_DIGITS*4];
      
      // When performing binary-to-BCD conversion, binary_out is not used.
      // (Assigning it to binary_in to avoid latching issues.)
      binary_out = binary_in;
      
    end else begin
      // BCD-to-binary conversion using combinational logic.
      // The algorithm processes the BCD input from the most significant digit to the least significant digit.
      // For each nibble: binary_out = (binary_out * 10) + nibble.
      integer i;
      // Use a temporary variable for the accumulated binary value.
      logic [INPUT_WIDTH-1:0] temp;
      temp = 0;
      
      // Loop over each BCD digit.
      // The most significant nibble is extracted starting at bit index: (BCD_DIGITS-1)*4 + 3.
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        // Extract nibble: starting index = ((BCD_DIGITS-1 - i)*4 + 3)
        temp = (temp * 10) + bcd_in[((BCD_DIGITS - 1 - i)*4 + 3) -: 4];
      end
      
      // The computed binary value is assigned to binary_out.
      binary_out = temp;
      
      // When performing BCD-to-binary conversion, bcd_out is not used.
      // (Assigning it to bcd_in to avoid latching issues.)
      bcd_out = bcd_in;
    end
  end

endmodule