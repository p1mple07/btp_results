module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

// Perform bounds checking and handle potential overflows
always @(*) begin
    integer shft;
    byte uc;
    
    // Check if input is within ASCII range
    if (input_char < 8'h20 || input_char > 8'h7e) begin
        output_char = input_char;
    end
    else begin
        // Shift the character by the specified number of positions
        uc = input_char - 8'h20;
        shft = key[3:0];
        
        // Wrap around the alphabet when shifting beyond the range
        while (shft > 0) begin
            if (uc == 25) begin
                uc = 0;
            }
            else begin
                uc++;
            end
            shft--;
        end
        
        // Add the letter A to the shifted value and wrap around the alphabet
        uc += 26 * (key[3:0] >> 1);
        uc = uc % 26;
        
        // Convert back to ASCII
        output_char = uc + 8'h20;
    end
end

endmodule