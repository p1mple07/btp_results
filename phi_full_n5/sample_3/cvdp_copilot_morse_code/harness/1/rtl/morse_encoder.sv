module morse_encoder(
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

    always @ (ascii_in) begin
        case (ascii_in)
            8'h41: morse_out = 8'b01; morse_length = 2; // A
            8'h42: morse_out = 8'b1000; morse_length = 4; // B
            8'h43: morse_out = 8'b1010; morse_length = 4; // C
            8'h44: morse_out = 8'b100; morse_length = 3; // D
            8'h45: morse_out = 8'b0; morse_length = 1; // E
            8'h46: morse_out = 8'b0010; morse_length = 4; // F
            8'h47: morse_out = 8'b110; morse_length = 3; // G
            8'h48: morse_out = 8'b0000; morse_length = 4; // H
            8'h49: morse_out = 8'b00; morse_length = 2; // I
            8'h50: morse_out = 8'b0111; morse_length = 4; // J
            8'h51: morse_out = 8'b101; morse_length = 3; // K
            8'h52: morse_out = 8'b0100; morse_length = 4; // L
            8'h53: morse_out = 8'b11; morse_length = 2; // M
            8'h54: morse_out = 8'b10; morse_length = 2; // N
            8'h55: morse_out = 8'b111; morse_length = 3; // O
            8'h56: morse_out = 8'b0110; morse_length = 4; // P
            8'h57: morse_out = 8'b1101; morse_length = 4; // Q
            8'h58: morse_out = 8'b010; morse_length = 3; // R
            8'h59: morse_out = 8'b000; morse_length = 3; // S
            8'h60: morse_out = 8'b000; morse_length = 3; // T
            8'h61: morse_out = 8'b001; morse_length = 3; // U
            8'h62: morse_out = 8'b0001; morse_length = 4; // V
            8'h63: morse_out = 8'b1001; morse_length = 4; // X
            8'h64: morse_out = 8'b1011; morse_length = 4; // Y
            8'h65: morse_out = 8'b1100; morse_length = 4; // Z
            8'h30: morse_out = 8'b11111; morse_length = 5; // 0
            8'h31: morse_out = 8'b01111; morse_length = 5; // 1
            8'h32: morse_out = 8'b00111; morse_length = 5; // 2
            8'h33: morse_out = 8'b00011; morse_length = 5; // 3
            8'h34: morse_out = 8'b00001; morse_length = 5; // 4
            8'h35: morse_out = 8'b00000; morse_length = 5; // 5
            8'h36: morse_out = 8'b10000; morse_length = 5; // 6
            8'h37: morse_out = 8'b11000; morse_length = 5; // 7
            8'h38: morse_out = 8'b11100; morse_length = 5; // 8
            8'h39: morse_out = 8'b11110; morse_length = 5; // 9
            default: morse_out = 8'b0; morse_length = 0;
        endcase
    end

endmodule
