module binary_to_bcd (
    input logic [7:0] binary_in,
    output logic [11:0] bcd_out
);

    logic [19:0] shift_reg;
    integer i;

    // Initialise the shift register with the binary input in the rightmost 8 bits
    assign shift_reg = {12'd0, binary_in};

    // Perform 8 shift‑and‑adjust cycles
    for (i = 0; i < 8; i++) begin : conv_loop
        shift_reg = {12'd0, ~shift_reg[7:0] << 1};   // Shift left by 1 bit

        // Apply BCD correction to each 4‑bit group
        if (shift_reg[19:16] >= 5) shift_reg[16] += 3;
        if (shift_reg[13:10] >= 5) shift_reg[10] += 3;
        if (shift_reg[7:4] >= 5) shift_reg[4] += 3;
        if (shift_reg[1:0] >= 5) shift_reg[0] += 3;
    end

    // Take the most significant 12 bits as the BCD result
    assign bcd_out = shift_reg[19:8];

endmodule
