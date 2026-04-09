module morse_encoder(
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

localparam 'd M = 10;
localparam 'd N = 20;

always_comb begin
    if (ascii_in >= 'A && ascii_in <= 'Z') begin
        case (ascii_in)
            0x41: morse_out = 10'b01;
            0x42: morse_out = 10'b1000;
            0x43: morse_out = 10'b1010;
            0x44: morse_out = 10'b100;
            0x45: morse_out = 10'b0;
            0x46: morse_out = 10'b0010;
            0x47: morse_out = 10'b110;
            0x48: morse_out = 10'b0000;
            0x49: morse_out = 10'b00000;
            0x4A: morse_out = 10'b0111;
            0x4B: morse_out = 10'b0100;
            default: morse_out = 10'b00000000;
        endcase
    end else if (ascii_in >= '0' && ascii_in <= '9') begin
        case (ascii_in)
            0x30: morse_out = 10'b01111;
            0x31: morse_out = 10'b01110;
            0x32: morse_out = 10'b00111;
            0x33: morse_out = 10'b00011;
            0x34: morse_out = 10'b00001;
            0x35: morse_out = 10'b00000;
            0x36: morse_out = 10'b10000;
            0x37: morse_out = 10'b11000;
            0x38: morse_out = 10'b11100;
            0x39: morse_out = 10'b11110;
            default: morse_out = 10'b00000000;
        endcase
    end else morse_out = 10'b00000000;
    morse_length = 0;
end

endmodule
