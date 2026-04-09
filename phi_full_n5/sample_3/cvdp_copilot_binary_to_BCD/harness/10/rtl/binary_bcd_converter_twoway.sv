
module binary_bcd_converter_twoway (
    input logic [1:0] switch, // 2-bit switch to select conversion mode
    input logic [INPUT_WIDTH-1:0] binary_in, // Binary input value
    input logic [(BCD_DIGITS*4)-1:0] bcd_in, // BCD input value
    output logic [(BCD_DIGITS*4)-1:0] bcd_out, // BCD output value
    output logic [(INPUT_WIDTH)-1:0] binary_out // Binary output value
);

  parameter BCD_DIGITS = 3; // Default BCD digits
  parameter INPUT_WIDTH = 9; // Default input width

  always_comb begin
    // BCD-to-binary conversion logic
    if (switch == 1'b0) begin
      integer i;
      binary_out = 0;
      for (i = 0; i < BCD_DIGITS; i = i + 1) begin
        if (i == 0) begin
          binary_out = (binary_out << 4) | bcd_in[(i*4)-4:i*4];
        end else begin
          binary_out = (binary_out << 4) | (binary_out * 10'b1010);
        end
      end
    end
    // Binary-to-BCD conversion logic
    else begin
      logic [19:0] shift_reg; // 20-bit register
      integer i;
      shift_reg = {12'd0, binary_in}; // Initialize with zeros and binary input

      // Perform the Double Dabble process
      for (i = 0; i < 8; i = i + 1) begin
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

        shift_reg = shift_reg << 1;
      end

      // Assign the upper 12 bits of the shift register to BCD output
      bcd_out = shift_reg[19:8];
    end
  end

endmodule
