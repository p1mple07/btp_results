module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    // Lookup table for valid ASCII characters
    localparam [7:0] ASCII_LOOKUP [0:63] = {
        // ASCII codes for 'A' to 'Z' and '0' to '9'
        8'h41: 6'b100, morse_length = 3,
        8'h42: 6'b1000, morse_length = 4,
        8'h43: 6'b1010, morse_length = 4,
        8'h44: 6'b100, morse_length = 3,
        8'h45: 6'b1, morse_length = 3,
        8'h46: 6'b0010, morse_length = 4,
        8'h47: 6'b110, morse_length = 3,
        8'h48: 6'b0000, morse_length = 4,
        8'h49: 6'b00, morse_length = 2,
        8'h4A: 6'b0111, morse_length = 4,
        8'h4B: 6'b101, morse_length = 3,
        8'h4C: 6'b01, morse_length = 2,
        8'h4D: 6'b11, morse_length = 2,
        8'h4E: 6'b10, morse_length = 2,
        8'h4F: 6'b111, morse_length = 3,
        8'h50: 6'b0110, morse_length = 4,
        8'h51: 6'b1101, morse_length = 4,
        8'h52: 6'b101, morse_length = 3,
        8'h53: 6'b000, morse_length = 3,
        8'h54: 6'b1, morse_length = 1,
        8'h55: 6'b001, morse_length = 3,
        8'h56: 6'b01, morse_length = 1,
        8'h57: 6'b011, morse_length = 3,
        8'h58: 6'b1011, morse_length = 4,
        8'h59: 6'b1111, morse_length = 4,
        8'h30: 6'b11111, morse_length = 5,
        8'h31: 6'b01111, morse_length = 5,
        8'h32: 6'b00111, morse_length = 5,
        8'h33: 6'b00011, morse_length = 5,
        8'h34: 6'b00001, morse_length = 5,
        8'h35: 6'b00000, morse_length = 5,
        8'h36: 6'b10000, morse_length = 5,
        8'h37: 6'b11000, morse_length = 5,
        8'h38: 6'b11100, morse_length = 5,
        8'h39: 6'b11110, morse_length = 5
    };

    always @(*) begin
        case (ascii_in)
            ASCII_LOOKUP[ascii_in] // Use the lookup table for valid inputs
        default: begin
            morse_out = 6'b0; // Invalid inputs
            morse_length = 4'b0;
        end
        endcase
    end

endmodule
