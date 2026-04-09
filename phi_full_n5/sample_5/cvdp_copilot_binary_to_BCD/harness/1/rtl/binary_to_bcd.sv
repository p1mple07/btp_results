    always_comb begin
    // Step 1: Initialize the shift register
    shift_reg = {12'd0, binary_in}; 

    // Iterate 8 times for each bit in the binary input
    for (I = 0; I < 8; I = I + 1) begin
        // Shift the entire register by 1 bit to the left
        shift_reg = {shift_reg[17:0], shift_reg[15:16]};

        // Adjust BCD digits that are greater than 5
        if (shift_reg[15] > 1'b1) begin
            shift_reg[15] = shift_reg[15] + 3'b001;
        end
        if (shift_reg[14] > 1'b1) begin
            shift_reg[14] = shift_reg[14] + 3'b001;
        end
        if (shift_reg[13] > 1'b1) begin
            shift_reg[13] = shift_reg[13] + 3'b001;
        end
        if (shift_reg[12] > 1'b1) begin
            shift_reg[12] = shift_reg[12] + 3'b001;
        end
    end

    // Step 3: Return the Final BCD Result
    bcd_out = shift_reg[19:8];

    end
