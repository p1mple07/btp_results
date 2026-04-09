module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    // Lookup table for valid ASCII characters
    localparam [7:0] ASCII_LOOKUP [127:0] = {
        // A
        8'h41: {morse_out, morse_length},
        // B
        8'h42: {6'h100, morse_length},
        // C
        8'h43: {6'h1010, morse_length},
        // D
        8'h44: {6'h100, morse_length},
        // E
        8'h45: {6'h1, morse_length},
        // F
        8'h46: {6'h1000, morse_length},
        // G
        8'h47: {6'h110, morse_length},
        // H
        8'h48: {6'h10000, morse_length},
        // I
        8'h49: {6'h1, morse_length},
        // J
        8'h4A: {6'h1110, morse_length},
        // K
        8'h4B: {6'h101, morse_length},
        // L
        8'h4C: {6'h10, morse_length},
        // M
        8'h4D: {6'h11, morse_length},
        // N
        8'h4E: {6'h10, morse_length},
        // O
        8'h4F: {6'h111, morse_length},
        // P
        8'h50: {6'h10001, morse_length},
        // Q
        8'h51: {6'h1101, morse_length},
        // R
        8'h52: {6'h101, morse_length},
        // S
        8'h53: {6'h11, morse_length},
        // T
        8'h54: {6'h1, morse_length},
        // U
        8'h55: {6'h10, morse_length},
        // V
        8'h56: {6'h1001, morse_length},
        // W
        8'h57: {6'h101, morse_length},
        // X
        8'h58: {6'h1101, morse_length},
        // Y
        8'h59: {6'h1011, morse_length},
        // Z
        8'h5A: {6'h1100, morse_length},
        // 0
        8'h30: {6'h11111, morse_length},
        // 1
        8'h31: {6'h01111, morse_length},
        // 2
        8'h32: {6'h00111, morse_length},
        // 3
        8'h33: {6'h00011, morse_length},
        // 4
        8'h34: {6'h00001, morse_length},
        // 5
        8'h35: {6'h00000, morse_length},
        // 6
        8'h36: {6'h10000, morse_length},
        // 7
        8'h37: {6'h11000, morse_length},
        // 8
        8'h38: {6'h11100, morse_length},
        // 9
        8'h39: {6'h11110, morse_length},
        // Default case
        default: {morse_out, morse_length}
    };

    always @(*) begin
        case (ascii_in)
            ASCII_LOOKUP[ascii_in] // Use the lookup table for valid inputs
        endcase
    end

endmodule
