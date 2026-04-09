module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

    // Use a local variable to hold the intermediate result
    reg [7:0] intermediate_result;

    always @(*) begin
        // Shift uppercase characters
        if (input_char >= 'A' && input_char <= 'Z') begin
            intermediate_result = ('A' + ((input_char - 'A') + key) % 26);
        end
        // Shift lowercase characters
        else if (input_char >= 'a' && input_char <= 'z') begin
            intermediate_result = ('a' + ((input_char - 'a') + key) % 26);
        end
        // Non-alphabet characters remain unchanged
        else begin
            intermediate_result = input_char;
        end
        // Assign the result to the output
        output_char = intermediate_result;
    end

endmodule
