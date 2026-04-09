module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    always @(*) begin
        case (ascii_in)
            8'h41: begin morse_out = 6'b1;      // A: .-  (dot then dash: 0 then 1 → 01 = 1)
                 morse_length = 2;
            end
            8'h42: begin morse_out = 6'b1000;     // B: -...  (dash, dot, dot, dot: 1 0 0 0 = 8)
                 morse_length = 4;
            end
            8'h43: begin morse_out = 6'b1010;     // C: -.-.  (dash, dot, dash, dot: 1 0 1 0 = 10)
                 morse_length = 4;
            end
            8'h44: begin morse_out = 6'b100;      // D: -..  (dash, dot, dot: 1 0 0 = 4)
                 morse_length = 3;
            end
            8'h45: begin morse_out = 6'b0;        // E: .  (dot only: 0)
                 morse_length = 1;
            end
            8'h46: begin morse_out = 6'b0010;     // F: ..-.  (dot, dot, dash, dot: 0 0 1 0 = 2)
                 morse_length = 4;
            end
            8'h47: begin morse_out = 6'b110;      // G: --.  (dash, dash, dot: 1 1 0 = 6)
                 morse_length = 3;
            end
            8'h48: begin morse_out = 6'b0000;     // H: ....  (dot, dot, dot, dot: 0 0 0 0 = 0)
                 morse_length = 4;
            end
            8'h49: begin morse_out = 6'b00;       // I: ..  (dot, dot: 0 0 = 0)
                 morse_length = 2;
            end
            8'h4A: begin morse_out = 6'b0111;     // J: .---  (dot, dash, dash, dash: 0 1 1 1 = 7)
                 morse_length = 4;
            end
            8'h4B: begin morse_out = 6'b101;      // K: -.-  (dash, dot, dash: 1 0 1 = 5)
                 morse_length = 3;
            end
            8'h4C: begin morse_out = 6'b0100;     // L: .-..  (dot, dash, dot, dot: 0 1 0 0 = 4)
                 morse_length = 4;
            end
            8'h4D: begin morse_out = 6'b11;       // M: --  (dash, dash: 1 1 = 3)
                 morse_length = 2;
            end
            8'h4E: begin morse_out = 6'b10;       // N: -.  (dash, dot: 1 0 = 2)
                 morse_length = 2;
            end
            8'h4F: begin morse_out = 6'b111;      // O: ---  (dash, dash, dash: 1 1 1 = 7)
                 morse_length = 3;
            end
            8'h50: begin morse_out = 6'b0110;     // P: .--.  (dot, dash, dash, dot: 0 1 1 0 = 6)
                 morse_length = 4;
            end
            8'h51: begin morse_out = 6'b1101;     // Q: --.-  (dash, dash, dot, dash: 1 1 0 1 = 13)
                 morse_length = 4;
            end
            8'h52: begin morse_out = 6'b010;      // R: .-.  (dot, dash, dot: 0 1 0 = 2)
                 morse_length = 3;
            end
            8'h53: begin morse_out = 6'b000;      // S: ...  (dot, dot, dot: 0 0 0 = 0)
                 morse_length = 3;
            end
            8'h54: begin morse_out = 6'b1;        // T: -  (dash only: 1)
                 morse_length = 1;
            end
            8'h55: begin morse_out = 6'b001;      // U: ..-  (dot, dot, dash: 0 0 1 = 1)
                 morse_length = 3;
            end
            8'h56: begin morse_out = 6'b0001;     // V: ...-  (dot, dot, dot, dash: 0 0 0 1 = 1)
                 morse_length = 4;
            end
            8'h57: begin morse_out = 6'b011;      // W: .--  (dot, dash, dash: 0 1 1 = 3)
                 morse_length = 3;
            end
            8'h58: begin morse_out = 6'b1001;     // X: -..-  (dash, dot, dot, dash: 1 0 0 1 = 9)
                 morse_length = 4;
            end
            8'h59: begin morse_out = 6'b1011;     // Y: -.--  (dash, dot, dash, dash: 1 0 1 1 = 11)
                 morse_length = 4;
            end
            8'h5A: begin morse_out = 6'b1100;     // Z: --..  (dash, dash, dot, dot: 1 1 0 0 = 12)
                 morse_length = 4;
            end
            8'h30: begin morse_out = 6'b11111;    // 0: -----  (dash, dash, dash, dash, dash: 1 1 1 1 1 = 31)
                 morse_length = 5;
            end
            8'h31: begin morse_out = 6'b01111;    // 1: .----  (dot, dash, dash, dash, dash: 0 1 1 1 1 = 15)
                 morse_length = 5;
            end
            8'h32: begin morse_out = 6'b00111;    // 2: ..---  (dot, dot, dash, dash, dash: 0 0 1 1 1 = 7)
                 morse_length = 5;
            end
            8'h33: begin morse_out = 6'b00011;    // 3: ...--  (dot, dot, dot, dash, dash: 0 0 0 1 1 = 3)
                 morse_length = 5;
            end
            8'h34: begin morse_out = 6'b00001;    // 4: ....-  (dot, dot, dot, dot, dash: 0 0 0 0 1 = 1)
                 morse_length = 5;
            end
            8'h35: begin morse_out = 6'b00000;    // 5: .....  (dot, dot, dot, dot, dot: 0 0 0 0 0 = 0)
                 morse_length = 5;
            end
            8'h36: begin morse_out = 6'b10000;    // 6: -....  (dash, dot, dot, dot, dot: 1 0 0 0 0 = 16)
                 morse_length = 5;
            end
            8'h37: begin morse_out = 6'b11000;    // 7: --...  (dash, dash, dot, dot, dot: 1 1 0 0 0 = 24)
                 morse_length = 5;
            end
            8'h38: begin morse_out = 6'b11100;    // 8: ---..  (dash, dash, dash, dot, dot: 1 1 1 0 0 = 28)
                 morse_length = 5;
            end
            8'h39: begin morse_out = 6'b11110;    // 9: ----.  (dash, dash, dash, dash, dot: 1 1 1 1 0 = 30)
                 morse_length = 5;
            end
            default: begin
                morse_out = 6'b0;
                morse_length = 4'd0;
            end
        endcase
    end

endmodule