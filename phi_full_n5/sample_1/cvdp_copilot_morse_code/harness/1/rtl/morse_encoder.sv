module morse_encoder(
    input [7:0] ascii_in,
    output reg [9:0] morse_out,
    output reg [3:0] morse_length
);

    // Morse code mapping table
    localparam [7:0] morse_code_map = {
        8'h41, 8'h1000, 8'h1010, 8'h100, 8'h1, 8'h10010,
        8'h101, 8'h1000, 8'h10000, 8'h10, 8'h10001, 8'h10111,
        8'h110, 8'h10, 8'h100, 8'h111, 8'h10100, 8'h1001,
        8'h11, 8'h1000, 8'h1001, 8'h1001, 8'h11111, 8'h11111,
        8'h11111, 8'h10000, 8'h10000, 8'h10000, 8'h10000, 8'h10000
    };

    // Length mapping table
    localparam [3:0] morse_length_map = {
        2'b00, 4'b0000, 4'b0000, 3'b000, 1'b00, 4'b0000,
        3'b000, 4'b0000, 4'b0000, 3'b000, 2'b00, 4'b0000,
        3'b000, 4'b0000, 4'b0000, 3'b000, 2'b00, 4'b0000,
        5'b00000, 5'b00000, 5'b00000, 5'b00000, 5'b00000, 5'b00000
    };

    // Encoding logic
    always @ (ascii_in) begin
        case (ascii_in)
            8'h41: morse_out = morse_code_map[8'h41]; morse_length = morse_length_map[8'h41];
            8'h42: morse_out = morse_code_map[8'h42]; morse_length = morse_length_map[8'h42];
            // ... continue for all ASCII characters
            default: morse_out = 10'h0; morse_length = 4'b0;
        endcase
    end

endmodule
