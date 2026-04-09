module morse_encoder(
    input [7:0] ascii_in,
    output [9:0] morse_out,
    output [3:0] morse_length
);
    case ascii_in
        0x00: morse_out = 10'b1111111111, morse_length = 4'b1111;
        0x01: morse_out = 10'b1111101111, morse_length = 4'b1110;
        0x02: morse_out = 10'b1111100111, morse_length = 4'b1101;
        0x03: morse_out = 10'b1111100011, morse_length = 4'b1100;
        0x04: morse_out = 10'b1111100001, morse_length = 4'b1011;
        0x05: morse_out = 10'b1111100000, morse_length = 4'b1010;
        0x06: morse_out = 10'b1111011111, morse_length = 4'b1001;
        0x07: morse_out = 10'b1111011101, morse_length = 4'b1000;
        0x08: morse_out = 10'b1111011001, morse_length = 4'b0111;
        0x09: morse_out = 10'b1111011000, morse_length = 4'b0110;
        0x0A: morse_out = 10'b1110111111, morse_length = 4'b0101;
        0x0B: morse_out = 10'b1110111101, morse_length = 4'b0100;
        0x0C: morse_out = 10'b1110111000, morse_length = 4'b0011;
        0x0D: morse_out = 10'b1110110111, morse_length = 4'b0010;
        0x0E: morse_out = 10'b1110110110, morse_length = 4'b0001;
        0x0F: morse_out = 10'b1110110000, morse_length = 4'b0000;
        0x10: morse_out = 10'b1110011111, morse_length = 4'b0001;
        0x11: morse_out = 10'b1110011110, morse_length = 4'b0000;
        0x12: morse_out = 10'b1110011100, morse_length = 4'b0001;
        0x13: morse_out = 10'b1110011011, morse_length = 4'b0000;
        0x14: morse_out = 10'b1110011010, morse_length = 4'b0001;
        0x15: morse_out = 10'b1110011000, morse_length = 4'b0000;
        0x16: morse_out = 10'b1110000111, morse_length = 4'b0011;
        0x17: morse_out = 10'b1110000110, morse_length = 4'b0010;
        0x18: morse_out = 10'b1110000100, morse_length = 4'b0001;
        0x19: morse_out = 10'b1110000011, morse_length = 4'b0000;
        0x1A: morse_out = 10'b1110000010, morse_length = 4'b0001;
        0x1B: morse_out = 10'b1110000001, morse_length = 4'b0000;
        0x1C: morse_out = 10'b1110000000, morse_length = 4'b0001;
        0x1D: morse_out = 10'b1101111111, morse_length = 4'b0011;
        0x1E: morse_out = 10'b1101111110, morse_length = 4'b0010;
        0x1F: morse_out = 10'b1101111100, morse_length = 4'b0001;
        0x20: morse_out = 10'b1101111000, morse_length = 4'b0000;
        default: morse_out = 10'b0000000000, morse_length = 4'b0000;
    endcase
endmodule