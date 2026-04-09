module caesar_cipher(
    input wire [7:0] input_char, // 8-bit ASCII character
    input wire [3:0] key,        // 4-bit shift key
    output reg [7:0] output_char // 8-bit shifted output character
);

// Bit-width mismatches
assign output_char = ((input_char - "A" + key) % 26) + "A";

// Potential truncation or expansion of intermediate expressions
assign output_char = ((input_char - "A" + key) % 26) + "A";

endmodule