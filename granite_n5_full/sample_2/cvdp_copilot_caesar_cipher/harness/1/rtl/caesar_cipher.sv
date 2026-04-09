module caesar_cipher(
    input [7:0] input_char,
    input [3:0] key,
    output reg [7:0] output_char
);

always @(*) begin
    case (input_char)
        [7:0]'b1000000: output_char = 'h';
        [7:0]'b1000001: output_char = 'i';
        [7:0]'b1000010: output_char = 'j';
        [7:0]'b1000011: output_char = 'k';
        [7:0]'b1000100: output_char = 'l';
        [7:0]'b1000101: output_char ='m';
        [7:0]'b1000110: output_char = 'n';
        [7:0]'b1000111: output_char = 'o';
        [7:0]'b1001000: output_char = 'p';
        [7:0]'b1001001: output_char = 'q';
        [7:0]'b1001010: output_char = 'r';
        [7:0]'b1001011: output_char ='s';
        [7:0]'b1001100: output_char = 't';
        [7:0]'b1001101: output_char = 'u';
        [7:0]'b1001110: output_char = 'v';
        [7:0]'b1001111: output_char = 'w';
        [7:0]'b1010000: output_char = 'x';
        [7:0]'b1010001: output_char = 'y';
        [7:0]'b1010010: output_char = 'z';
        [7:0]'b1010011: output_char = 'a';
        [7:0]'b1010100: output_char = 'b';
        [7:0]'b1010101: output_char = 'c';
        [7:0]'b1010110: output_char = 'd';
        [7:0]'b1010111: output_char = 'e';
        [7:0]'b1011000: output_char = 'f';
        [7:0]'b1011001: output_char = 'g';
        [7:0]'b1011010: output_char = 'h';
        [7:0]'b1011011: output_char = 'i';
        [7:0]'b1011100: output_char = 'j';
        [7:0]'b1011101: output_char = 'k';
        [7:0]'b1011110: output_char = 'l';
        [7:0]'b1011111: output_char ='m';
        [7:0]'b1100000: output_char = 'n';
        [7:0]'b1100001: output_char = 'o';
        [7:0]'b1100010: output_char = 'p';
        [7:0]'b1100011: output_char = 'q';
        [7:0]'b1100100: output_char = 'r';
        [7:0]'b1100101: output_char ='s';
        [7:0]'b1100110: output_char = 't';
        [7:0]'b1100111: output_char = 'u';
        [7:0]'b1101000: output_char = 'v';
        [7:0]'b1101001: output_char = 'w';
        [7:0]'b1101010: output_char = 'x';
        [7:0]'b1101011: output_char = 'y';
        [7:0]'b1101100: output_char = 'z';
        default: output_char = input_char; // Handle non-alphabetic characters
    endcase
end

endmodule