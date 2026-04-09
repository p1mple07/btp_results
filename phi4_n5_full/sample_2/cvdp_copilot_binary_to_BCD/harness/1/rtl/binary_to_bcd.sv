module binary_to_bcd (
    input  logic [7:0] binary_in,  // 8-bit binary input
    output logic [11:0] bcd_out   // 12-bit BCD output (3 digits)
);

    // Intermediate shift register: 12 bits for BCD, 8 bits for binary input
    logic [19:0] shift_reg;
    integer i;

    always_comb begin
        // Step 1: Initialize the shift register
        shift_reg = {12'd0, binary_in};

        // Step 2: Process each binary bit using the Double Dabble algorithm
        // Perform 8 iterations (one per bit of binary_in)
        for (i = 0; i < 8; i = i + 1) begin
            // Left shift the entire register by 1 bit
            shift_reg = shift_reg << 1;

            // Check each non-overlapping 4-bit BCD digit in the top 12 bits
            // Group 1: bits [19:16]
            if (shift_reg[19:16] >= 5'd5)
                shift_reg[19:16] = shift_reg[19:16] + 3;
            // Group 2: bits [15:12]
            if (shift_reg[15:12] >= 5'd5)
                shift_reg[15:12] = shift_reg[15:12] + 3;
            // Group 3: bits [11:8]
            if (shift_reg[11:8]  >= 5'd5)
                shift_reg[11:8]  = shift_reg[11:8]  + 3;
        end

        // Step 3: The leftmost 12 bits now hold the BCD result
        bcd_out = shift_reg[19:8];
    end

endmodule