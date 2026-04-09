module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

always @(*) begin
    // Handling uppercase A-Z
    if (input_char >= 65 && input_char <= 90) begin
        // Convert to 0-based index (0-25)
        int index = input_char - 65;
        // Apply shift and wrap around
        index = (index + key) % 26;
        // Convert back to ASCII and assign
        output_char = index + 65;
    end
    
    // Handling lowercase a-z
    else if (input_char >= 97 && input_char <= 122) begin
        // Convert to 0-based index (0-25)
        int index = input_char - 97;
        // Apply shift and wrap around
        index = (index + key) % 26;
        // Convert back to ASCII and assign
        output_char = index + 97;
    end
    
    // Non-alphabetical characters remain unchanged
    else begin
        output_char = input_char;
    end
end

endmodule
