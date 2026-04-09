
module binary_bcd_converter_twoway (
    input logic [7:0] binary_in,
    input logic [11:0] bcd_in,
    input logic switch,
    output logic [INPUT_WIDTH-1:0] binary_out,
    output logic [(BCD_DIGITS*4)-1:0] bcd_out
);

    // Constants
    parameter INPUT_WIDTH = 9;
    parameter BCD_DIGITS = 3;

    // Intermediate shift register to hold binary and BCD values
    logic [INPUT_WIDTH*2-1:0] shift_reg;  // 2*INPUT_WIDTH-1 bits for concatenation
    integer i;

    always_comb begin
        if (switch == 1'b1) begin
            // Binary-to-BCD conversion
            if (binary_in != 0) begin
                // Step 1: Initialize the shift register
                shift_reg = {12'd0, binary_in};  // Concatenate 12 zeros and binary input

                // Step 2: Perform the Double Dabble process
                for (i = 0; i < 8; i = i + 1) begin
                    if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;
                    if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;
                    if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;

                    shift_reg = shift_reg << 1;
                end

                // Step 3: Assign the upper 12 bits of the shift register to BCD output
                bcd_out = shift_reg[19:8];
            end else begin
                bcd_out = 12'd0;
            end
        end else begin
            // BCD-to-Binary conversion
            binary_out = 0;
            shift_reg = 0;

            // Iterate Over BCD Digits
            for (i = 0; i < BCD_DIGITS; i = i + 1) begin
                bcd_out[i*4+:4] = bcd_in[i*4+:4];
                if (i == BCD_DIGITS-1) begin
                    // Final Result: Multiply current `binary_out` by 1010<sub>2</sub> and add current BCD digit
                    binary_out = (binary_out * 1010) + bcd_out[i*4+:4];
                end else begin
                    // Intermediate Result: Multiply current `binary_out` by 1010<sub>2</sub> and add current BCD digit
                    shift_reg = (binary_out * 1010) + bcd_out[i*4+:4];
                end
            end
        end
    end

endmodule
