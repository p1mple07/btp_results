    module binary_to_bcd (
        input logic [7:0] binary_in,  // 8-bit binary input
        output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
        );

    // Intermediate shift register to hold binary and BCD values
    logic [19:0] shift_reg;  // 20-bit register: 12 for BCD and 8 for binary input
    integer I;

    always_comb begin
    // Step 1: Initialize the shift register
    shift_reg = {12'd0, binary_in}; 

    // Double Dabble algorithm
    for (I = 0; I < 8; I = I + 1) begin
        shift_reg = {shift_reg[17:0], shift_reg[15:1]} + (shift_reg[14] >= 5 ? 3'b001 : 'b0);
    end

    bcd_out = shift_reg[19:8];

    endmodule
