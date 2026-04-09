module caesar_cipher(
    input wire [7:0] input_char,
    input wire [3:0] key,
    output reg [7:0] output_char
);

always @(*) begin
    if (input_char >= 65 && input_char <= 90) begin
        output_char = ((input_char - 65 + key) % 26) + 65;
    else if (input_char >= 97 && input_char <= 122) begin
        output_char = ((input_char - 97 + key) % 26) + 97;
    else begin
        output_char = input_char;
    end
end

endmodule