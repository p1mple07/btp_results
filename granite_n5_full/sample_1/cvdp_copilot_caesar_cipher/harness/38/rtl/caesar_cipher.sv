module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

// Check if input_char is an ASCII character within the valid range
generate
    if (`INCLUDE_UPPERCASE) begin : UPPERCASE_CHECK
        if (input_char >= 65 && input_char <= 90) begin
            // Shift uppercase letters by key
            output_char = ((input_char - 65 + key) % 26) + 65;
        end
        else if (input_char >= 97 && input_char <= 122) begin
            // Shift lowercase letters by key
            output_char = ((input_char - 97 + key) % 26) + 97;
        end
        else begin
            // Pass through non-alphabetic characters unchanged
            output_char = input_char;
        end
    end
    else begin : LOWERCASE_CHECK
        if (input_char >= 97 && input_char <= 122) begin
            // Shift lowercase letters by key
            output_char = ((input_char - 97 + key) % 26) + 97;
        end
        else if (input_char >= 65 && input_char <= 90) begin
            // Shift uppercase letters by key
            output_char = ((input_char - 65 + key) % 26) + 65;
        end
        else begin
            // Pass through non-alphabetic characters unchanged
            output_char = input_char;
        end
    end
endgenerate

endmodule