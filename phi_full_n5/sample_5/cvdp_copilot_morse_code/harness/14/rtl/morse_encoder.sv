module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    always @(ascii_in) begin
        case (ascii_in)
            8'h41: morse_out = 6'b100; morse_length = 3;
            8'h42: morse_out = 6'b1000; morse_length = 4;
            8'h43: morse_out = 6'b1010; morse_length = 4;
            8'h44: morse_out = 6'b100; morse_length = 3;
            8'h45: morse_out = 6'b1; morse_length = 3;
            8'h46: morse_out = 6'b0010; morse_length = 4;
            8'h47: morse_out = 6'b110; morse_length = 3;
            8'h48: morse_out = 6'b0000; morse_length = 4;
            8'h49: morse_out = 6'b00; morse_length = 2;
            8'h4A: morse_out = 6'b0111; morse_length = 4;
            8'h4B: morse_out = 6'b101; morse_length = 3;
            8'h4C: morse_out = 6'b01; morse_length = 2;
            8'h4D: morse_out = 6'b11; morse_length = 2;
            8'h4E: morse_out = 6'b10; morse_length = 2;
            8'h4F: morse_out = 6'b111; morse_length = 3;
            8'h50: morse_out = 6'b0110; morse_length = 4;
            8'h51: morse_out = 6'b1101; morse_length = 4;
            8'h52: morse_out = 6'b101; morse_length = 3;
            8'h53: morse_out = 6'b000; morse_length = 3;
            8'h54: morse_out = 6'b1; morse_length = 1;
            8'h55: morse_out = 6'b001; morse_length = 3;
            8'h56: morse_out = 6'b0001; morse_length = 4;
            8'h57: morse_out = 6'b011; morse_length = 3;
            8'h58: morse_out = 6'b1001; morse_length = 4;
            8'h59: morse_out = 6'b1011; morse_length = 4;
            8'h30: morse_out = 6'b11111; morse_length = 5;
            8'h31: morse_out = 6'b01111; morse_length = 5;
            8'h32: morse_out = 6'b00111; morse_length = 5;
            8'h33: morse_out = 6'b00011; morse_length = 5;
            8'h34: morse_out = 6'b00001; morse_length = 5;
            8'h35: morse_out = 6'b00000; morse_length = 5;
            8'h36: morse_out = 6'b10000; morse_length = 5;
            8'h37: morse_out = 6'b11000; morse_length = 5;
            8'h38: morse_out = 6'b11100; morse_length = 5;
            8'h39: morse_out = 6'b11110; morse_length = 5;
            8'h0x00: begin morse_out = 6'b0; morse_length = 0; end
            default: begin
                morse_out = 6'b0; morse_length = 0;
            end
        endcase
    end

endmodule
