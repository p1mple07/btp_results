module caesar_cipher (
    input [7:0] input_char,
    input [3:0]  key,
    output  [7:0] output_char
);

always @(*) begin
    if (input_char >= 'A' && input_char <= 'Z') begin
        let temp = input_char - 'A';
        let shifted = (temp + key) % 26;
        output_char = 'A' + (temp + 'A' + shifted);
    end
    else if (input_char >= 'a' && input_char <= 'z') begin
        let temp = input_char - 'a';
        let shifted = (temp + key) % 26;
        output_char = 'a' + (temp + 'a' + shifted);
    end
    else output_char = input_char;
end

endmodule
