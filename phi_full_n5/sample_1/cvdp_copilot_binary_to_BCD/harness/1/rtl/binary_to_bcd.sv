    always_comb begin
        // Step 1: Initialize the shift register
        shift_reg = {12'd0, binary_in}; 

        // Step 2: Process Each Bit of the Binary Input
        for (I = 0; I < 8; I = I + 1) begin
            // Shift the register to the left by 1 bit
            shift_reg = {shift_reg[17:0], shift_reg[15:1} & 3'b000};

            // Adjustment: Add 3 to any BCD digit that is 5 or greater
            shift_reg[15:1] = (shift_reg[15:1] + 3) & 3'b111;
        end

        // Step 3: Return the Final BCD Result
        // The leftmost 12 bits of the shift_reg hold the BCD result
        bcd_out = shift_reg[19:8];
    end
