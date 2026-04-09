module binary_to_bcd (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
    );

    // Intermediate shift register to hold binary and BCD values
    logic [19:0] shift_reg;
    integer I;

    always_comb begin
        // Initialize the shift register
        shift_reg = {12'd0, binary_in};

        // Double Dabble algorithm implementation
        for (I = 0; I < 8; I++) {
            // Shift left by 1
            shift_reg = shift_reg << 1;

            // Check and adjust each BCD digit
            if ((shift_reg[19:16] & 0xF) >= 5) {
                shift_reg[19:16] = (shift_reg[19:16] + 3) & 0xF;
            }
            if ((shift_reg[15:12] & 0xF) >= 5) {
                shift_reg[15:12] = (shift_reg[15:12] + 3) & 0xF;
            }
            if ((shift_reg[11:8] & 0xF) >= 5) {
                shift_reg[11:8] = (shift_reg[11:8] + 3) & 0xF;
            }
        }

        // The BCD output is the top 12 bits
        bcd_out = shift_reg[19:8];
    endmodule