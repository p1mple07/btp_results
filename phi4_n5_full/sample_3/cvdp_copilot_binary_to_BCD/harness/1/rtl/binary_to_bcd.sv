module binary_to_bcd (
    input  logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
);

    // Intermediate shift register: 20 bits total (12 for BCD, 8 for binary input)
    logic [19:0] shift_reg;
    integer I;

    always_comb begin
        // Use a temporary register to perform iterative processing
        logic [19:0] temp;
        // Step 1: Initialize the shift register with 12 leading zeros and the binary input in the lower 8 bits
        temp = {12'd0, binary_in};

        // Process each bit of the binary input (8 iterations)
        for (I = 0; I < 8; I = I + 1) begin
            // Left shift the register by 1 bit
            temp = temp << 1;

            // For each non-overlapping 4-bit BCD digit, add 3 if the digit is 5 or greater
            if (temp[19:16] >= 4'd5)
                temp[19:16] = temp[19:16] + 4'd3;
            if (temp[15:12] >= 4'd5)
                temp[15:12] = temp[15:12] + 4'd3;
            if (temp[11:8]  >= 4'd5)
                temp[11:8]  = temp[11:8]  + 4'd3;
        end

        // After all iterations, the upper 12 bits of the shift register hold the BCD result
        shift_reg = temp;
        bcd_out = shift_reg[19:8];
    end

endmodule