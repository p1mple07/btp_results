module morse_encoder (
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

always @(*) begin
    case (ascii_in)
        'A': morse_out = "10'b01";
        'B': morse_out = "10'b1000";
        'C': morse_out = "10'b1010";
        'D': morse_out = "10'b100";
        'E': morse_out = "10'b0";
        'F': morse_out = "10'b0010";
        'G': morse_out = "10'b110";
        'H': morse_out = "10'b0000";
        'I': morse_out = "10'b00";
        'J': morse_out = "10'b0111";
        'K': morse_out = "10'b101";
        'L': morse_out = "10'b0100";
        'M': morse_out = "10'b11";
        'N': morse_out = "10'b10";
        'O': morse_out = "10'b111";
        'P': morse_out = "10'b0110";
        'Q': morse_out = "10'b1101";
        'R': morse_out = "10'b010";
        'S': morse_out = "10'b000";
        'T': morse_out = "10'b1";
        'U': morse_out = "10'b001";
        'V': morse_out = "10'b0001";
        'W': morse_out = "10'b011";
        'X': morse_out = "10'b1001";
        'Y': morse_out = "10'b1011";
        'Z': morse_out = "10'b1100";
        '0': morse_out = "10'b11111";
        '1': morse_out = ".----";
        '2': morse_out = "..---";
        '3': morse_out = "...--";
        '4': morse_out = "....-";
        '5': morse_out = ".....";
        '6': morse_out = "-....";
        '7': morse_out = "--...";
        '8': morse_out = "---..";
        '9': morse_out = "----.";
        default:
            morse_out = "0";
            morse_length = 0;
    endcase
end

endmodule
