module binary_bcd_converter_twoway #(
    parameter INPUT_WIDTH = 8,  // Width of the binary input
    parameter BCD_DIGITS  = 3   // Number of BCD digits (each digit is 4 bits)
) (
    input logic [INPUT_WIDTH-1:0] binary_in,  // Binary input
    input logic [(BCD_DIGITS*4)-1:0] bcd_in,  // BCD input
    input logic switch,  // Mode selection switch
    output logic [INPUT_WIDTH-1:0] binary_out,  // Output in binary (for BCD-to-binary conversion)
    output logic [(BCD_DIGITS*4)-1:0] bcd_out  // Output in BCD (for binary-to-BCD conversion)
);

  localparam SHIFT_REG_WIDTH = INPUT_WIDTH + (BCD_DIGITS * 4);
  logic [SHIFT_REG_WIDTH-1:0] shift_reg;
  integer i, j;

  always_comb begin
    shift_reg = {SHIFT_REG_WIDTH{1'b0}};
    binary_out = 0;
    bcd_out = 0;

    if (switch) begin

      shift_reg = {{(BCD_DIGITS * 4) {1'b0}}, binary_in};

      for (i = 0; i < INPUT_WIDTH; i = i + 1) begin

        if (shift_reg[3:0] >= 5) shift_reg[3:0] = shift_reg[3:0] + 3;
        if (shift_reg[7:4] >= 5) shift_reg[7:4] = shift_reg[7:4] + 3;
        if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
        if (BCD_DIGITS > 3 && shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
        if (BCD_DIGITS > 4 && shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;
        if (BCD_DIGITS > 5 && shift_reg[22:19] >= 5) shift_reg[22:19] = shift_reg[22:19] + 3;
        if (BCD_DIGITS > 6 && shift_reg[25:22] >= 5) shift_reg[25:22] = shift_reg[25:22] + 3;

        shift_reg = shift_reg << 1;
      end

      bcd_out = shift_reg[SHIFT_REG_WIDTH-1-:(BCD_DIGITS*4)];

    end else begin
      for (i = BCD_DIGITS - 1; i >= 0; i = i - 1) begin
        binary_out = (binary_out * 10) + bcd_in[(i*4)+:4];
      end
    end
  end
endmodule