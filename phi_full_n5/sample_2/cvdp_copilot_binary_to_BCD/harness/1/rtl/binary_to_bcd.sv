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

        // Step 2: Process Each Bit of the Binary Input
        for (I = 0; I < 8; I = I + 1) begin
            // Left shift the entire register by 1 bit
            shift_reg = {shift_reg[18:0], shift_reg[17:0]};

            // Adjustment: Check each BCD digit and add 3 if necessary
            for (I = 11; I > 0; I = I - 1) begin
                if (shift_reg[I] >= 5) begin
                    shift_reg[I] = shift_reg[I] + 3;
                end
            end
        end

        // Step 3: Return the Final BCD Result
        bcd_out = shift_reg[19:8];
    end

    endmodule
