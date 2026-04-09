module morse_encoder(
    input [7:0] ascii_in,
    output [9:0] morse_out,
    output [3:0] morse_length
);
    case ascii_in
        0x41: morse_out = 0b01; morse_length = 2;
        0x42: morse_out = 0b1000; morse_length = 4;
        0x43: morse_out = 0b1010; morse_length = 4;
        0x44: morse_out = 0b100; morse_length = 3;
        0x45: morse_out = 0b0; morse_length = 1;
        0x46: morse_out = 0b0010; morse_length = 4;
        0x47: morse_out = 0b110; morse_length = 3;
        0x48: morse_out = 0b0000; morse_length = 4;
        0x49: morse_out = 0b00; morse_length = 2;
        0x4A: morse_out = 0b0111; morse_length = 4;
        0x4B: morse_out = 0b101; morse_length = 3;
        0x4C: morse_out = 0b0100; morse_length = 4;
        0x4D: morse_out = 0b11; morse_length = 2;
        0x4E: morse_out = 0b10; morse_length = 2;
        0x4F: morse_out = 0b111; morse_length = 3;
        0x50: morse_out = 0b0110; morse_length = 4;
        0x51: morse_out = 0b1101; morse_length = 4;
        0x52: morse_out = 0b010; morse_length = 3;
        0x53: morse_out = 0b000; morse_length = 3;
        0x54: morse_out = 0b1; morse_length = 1;
        0x55: morse_out = 0b001; morse_length = 3;
        0x56: morse_out = 0b0001; morse_length = 4;
        0x57: morse_out = 0b011; morse_length = 3;
        0x58: morse_out = 0b1001; morse_length = 4;
        0x59: morse_out = 0b1011; morse_length = 4;
        0x5A: morse_out = 0b1100; morse_length = 4;
        0x30: morse_out = 0b11111; morse_length = 5;
        0x31: morse_out = 0b01111; morse_length = 5;
        0x32: morse_out = 0b00111; morse_length = 5;
        0x33: morse_out = 0b00011; morse_length = 5;
        0x34: morse_out = 0b00001; morse_length = 5;
        0x35: morse_out = 0b00000; morse_length = 5;
        0x36: morse_out = 0b10000; morse_length = 5;
        0x37: morse_out = 0b11000; morse_length = 5;
        0x38: morse_out = 0b11100; morse_length = 5;
        0x39: morse_out = 0b11110; morse_length = 5;
        default: morse_out = 0; morse_length = 0;
    endcase
endmodule