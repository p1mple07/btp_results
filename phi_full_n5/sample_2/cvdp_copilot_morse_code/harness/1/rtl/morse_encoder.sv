module morse_encoder(
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

    // Define a lookup table for ASCII to Morse code mapping
    // Each entry in the table corresponds to an ASCII character
    // and contains the Morse code binary sequence and its length
    localparam [15:0] ASCII_TO_MORSE_TABLE [15:0] = {
        {10'b01, 2},      // A
        {10'b1000, 4},    // B
        {10'b1010, 4},    // C
        {10'b100, 3},     // D
        {10'b0, 1},       // E
        {10'b0010, 4},    // F
        {10'b110, 3},     // G
        {10'b0000, 4},    // H
        {10'b00, 2},      // I
        {10'b0111, 4},    // J
        {10'b101, 3},     // K
        {10'b0100, 4},    // L
        {10'b11, 2},      // M
        {10'b10, 2},      // N
        {10'b111, 3},     // O
        {10'b0110, 4},    // P
        {10'b1101, 4},    // Q
        {10'b010, 3},     // R
        {10'b000, 3},     // S
        {10'b001, 3},     // T
        {10'b00111, 5},   // 2
        {10'b01111, 5},   // 3
        {10'b00111, 5},   // 4
        {10'b00001, 5},   // 5
        {10'b10000, 5},   // 6
        {10'b11000, 5},   // 7
        {10'b11100, 5},   // 8
        {10'b11110, 5}    // 9
    };

    // Immediate update combinational logic for real-time encoding
    always @ (ascii_in) begin
        case (ascii_in)
            // Map ASCII input to Morse code and length
            // If no mapping found, set morse_out and morse_length to zero
            default:
                morse_out = 10'b0000000000;
                morse_length = 4'b0;
            endcase
    end

endmodule
