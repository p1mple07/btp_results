module binary_to_bcd (
    input logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
    );

    // Intermediate shift register to hold binary and BCD values
    logic [19:0] shift_reg;  // 20-bit register: 12 for BCD and 8 for binary input
    integer I;

    always_comb begin
        // Initialise the shift register with zero BCD and the binary input
        shift_reg = {12'd0, binary_in};

        // Shift left 8 times (processing each of the 8 bits)
        for (int i = 0; i < 8; i++) begin
            shift_reg <= shift_reg << 1;
            // Check each 4‑bit BCD nibble and apply correction if needed
            if (shift_reg[11:8] >= 5'd5) begin
                shift_reg[11:8] <= shift_reg[11:8] + 3;
            end
        end

        // Take the top 12 bits as the final BCD output
        bcd_out = shift_reg[11:0];
    end

endmodule
