
module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    // Lookup table for ASCII to Morse code conversion
    // Each entry is indexed by the ASCII value
    localparam [31:0] ascii_to_morse_length_table [128:0] [5:0] =
    {
        // ASCII values 0-31 and 127 map to invalid input
        {6'b0, 4'b0, 4'b0, 4'b0, 4'b0},
        {6'b0, 6'b0, 4'b0, 4'b0, 4'b0},
        // ... (fill in the rest of the table with the correct mappings)
        // ASCII values A-Z and 0-9
        {6'b01, 4'b0, 4'b0, 4'b0, 4'b0}, {6'b00, 4'b0, 4'b0, 4'b0, 4'b0},
        {6'b00, 6'b0, 4'b0, 4'b0, 4'b0}, {6'b00, 6'b0, 6'b0, 4'b0, 4'b0},
        {6'b00, 6'b0, 6'b0, 6'b0, 4'b0}, {6'b00, 6'b0, 6'b0, 6'b0, 6'b0},
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // Z
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 9
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 8
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 7
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 6
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 5
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 4
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 3
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 2
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 1
        // ... (fill in the rest of the table with the correct mappings)
        {6'b00, 6'b0, 6'b0, 6'b0, 6'b0}, // 0
    };

    always @(*) begin
        case (ascii_in)
            ascii_to_morse_length_table[ascii_in]
        endcase
        // Set morse_length to the length specified in the lookup table
        morse_length = {ascii_to_morse_length_table[ascii_in][4:0]; default: 4'b0};
        // Set morse_out to the Morse code from the lookup table
        morse_out = {ascii_to_morse_length_table[ascii_in][3:0]; default: 6'b0};
    end

endmodule
