
module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

// Ensure key is within the acceptable range (0-15)
localparam key_range = 16'h000F;

always @(*) begin
    if (key < key_range) begin
        // Calculate the shifted character for uppercase letters
        if (input_char >= "A" && input_char <= "Z") begin
            output_char = {input_char[7:4] - 'A', (input_char[3:0] + key) % 26 + 'A'};
        end
        // Calculate the shifted character for lowercase letters
        else if (input_char >= "a" && input_char <= "z") begin
            output_char = {input_char[7:4] - 'a', (input_char[3:0] + key) % 26 + 'a'};
        end
        // Non-alphabetical characters remain unchanged
        else begin
            output_char = input_char;
        end
    end
end

endmodule
