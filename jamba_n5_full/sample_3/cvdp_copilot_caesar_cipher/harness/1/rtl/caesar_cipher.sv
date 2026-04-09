module caesar_cipher (
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

always @(*) begin
    if (input_char >= 'A' && input_char <= 'Z') begin
        localvar unsigned int offset = input_char - 'A';
        localvar unsigned int new_offset = (offset + key) % 26;
        output_char = 'A' + new_offset;
    end else if (input_char >= 'a' && input_char <= 'z') begin
        localvar unsigned int offset = input_char - 'a';
        localvar unsigned int new_offset = (offset + key) % 26;
        output_char = 'a' + new_offset;
    end else output_char = input_char;
end

endmodule
