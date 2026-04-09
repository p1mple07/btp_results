
module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

always @(*) begin
    case (input_char)
        'A': output_char = (((input_char - 'A') + key) % 26) + 'A';
        'a': output_char = (((input_char - 'a') + key) % 26) + 'a';
        default: output_char = input_char;
    endcase
end

endmodule
