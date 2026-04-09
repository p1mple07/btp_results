module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

always @(*) begin
    if (input_char >= "A" && input_char <= "Z") begin
        output_char = ((input_char - 65 + key) % 26) + 65;
    end
    else if (input_char >= "a" && input_char <= "z") begin
        output_char = ((input_char - 97 + key) % 26) + 97;
    end
    else begin
        output_char = input_char;
    end
end

endmodule
