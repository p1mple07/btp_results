module caesar_cipher(
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

    // Convert input character to ASCII code
    logic [7:0] char_code = input_char;
    
    // Separate logic for uppercase and lowercase
    logic is_upper;
    always_comb begin
        // Check if the character is uppercase
        if (char_code >= 65 && char_code <= 90) begin
            is_upper = 1'b1;
        end else begin
            is_upper = 1'b0;
        end
    end
    
    // Shift calculation
    logic [7:0] shifted_code;
    always_comb begin
        if (is_upper) begin
            // Shift within uppercase range A-Z
            shifted_code = (char_code - 65 + key) % 26 + 65;
        end else begin
            // Shift within lowercase range a-z
            shifted_code = (char_code - 97 + key) % 26 + 97;
        end
    end
    
    // Output character
    assign output_char = shifted_code;

endmodule
