module morse_encoder (
    input wire [7:0] ascii_in,       // ASCII input character
    output reg [5:0] morse_out,      // Morse code output (6 bits max for each letter)
    output reg [3:0] morse_length    // Length of the Morse code sequence
);

    // Lookup table for ASCII to Morse code mapping
    // Key: ASCII value
    // Value: Morse code and length
    localparam [7:0] ASCII_LOOKUP = {
        [8'h41, 6'b000001, 3'd2],
        [8'h42, 6'b100000, 4'd4],
        [8'h43, 6'b101000, 4'd4],
        [8'h44, 6'b100000, 3'd3],
        [8'h45, 6'b000000, 3'd2],
        [8'h46, 6'b001000, 4'd4],
        [8'h47, 6'b110000, 3'd3],
        [8'h48, 6'b000000, 4'd4],
        [8'h49, 6'b000000, 2'd2],
        [8'h4A, 6'b011100, 4'd4],
        [8'h4B, 6'b101000, 3'd3],
        [8'h4C, 6'b010000, 2'd2],
        [8'h4D, 6'b110000, 2'd2],
        [8'h4E, 6'b100000, 2'd2],
        [8'h4F, 6'b111000, 3'd3],
        [8'h50, 6'b011000, 4'd4],
        [8'h51, 6'b110100, 4'd4],
        [8'h52, 6'b101000, 3'd3],
        [8'h53, 6'b000000, 3'd3],
        [8'h54, 6'b100000, 1'd1],
        [8'h55, 6'b001000, 3'd3],
        [8'h56, 6'b000100, 4'd4],
        [8'h57, 6'b011000, 3'd3],
        [8'h58, 6'b100010, 4'd4],
        [8'h59, 6'b110010, 4'd4],
        [8'h60, 6'b111111, 5'd5],
        [8'h30, 6'b111111, 5'd5],
        [8'h31, 6'b011111, 5'd5],
        [8'h32, 6'b001111, 5'd5],
        [8'h33, 6'b000111, 5'd5],
        [8'h34, 6'b000011, 5'd5],
        [8'h35, 6'b000001, 5'd5],
        [8'h36, 6'b100001, 5'd5],
        [8'h37, 6'b110001, 5'd5],
        [8'h38, 6'b111001, 5'd5],
        [8'h39, 6'b111110, 5'd5]
    };

    // Index for the lookup table
    reg [7:0] ASCII_INDEX;

    // Convert ASCII to index
    always @(*) begin
        ASCII_INDEX = ASCII_LOOKUP[ascii_in];
    end

    // Morse code and length output
    always @(*) begin
        case (ASCII_INDEX)
            8'h000001: begin morse_out = 6'b000001; morse_length = 1'd1; end    // T
            8'h010000: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000002: begin morse_out = 6'b001000; morse_length = 4'd4; end    // F
            8'h000004: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000007: begin morse_out = 6'b011000; morse_length = 3'd3; end    // V
            8'h000008: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000009: begin morse_out = 6'b100000; morse_length = 4'd4; end    // X
            8'h00000A: begin morse_out = 6'b110000; morse_length = 4'd4; end    // Z
            8'h00000B: begin morse_out = 6'b101000; morse_length = 3'd3; end    // K
            8'h00000C: begin morse_out = 6'b010000; morse_length = 2'd2; end    // L
            8'h00000D: begin morse_out = 6'b110000; morse_length = 2'd2; end    // M
            8'h00000E: begin morse_out = 6'b100000; morse_length = 2'd2; end    // N
            8'h00000F: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000010: begin morse_out = 6'b000100; morse_length = 3'd3; end    // U
            8'h000011: begin morse_out = 6'b011000; morse_length = 3'd3; end    // W
            8'h000012: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000013: begin morse_out = 6'b000011; morse_length = 3'd3; end    // S
            8'h000014: begin morse_out = 6'b100000; morse_length = 1'd1; end    // T
            8'h000015: begin morse_out = 6'b000100; morse_length = 3'd3; end    // Y
            8'h000016: begin morse_out = 6'b000011; morse_length = 5'd5; end    // 4
            8'h000017: begin morse_out = 6'b011000; morse_length = 3'd3; end    // V
            8'h000018: begin morse_out = 6'b100010; morse_length = 4'd4; end    // -..-
            8'h000019: begin morse_out = 6'b110010; morse_length = 4'd4; end    // --..
            8'h00001A: begin morse_out = 6'b110100; morse_length = 4'd4; end    // --.-
            8'h00001B: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h00001C: begin morse_out = 6'b000111; morse_length = 5'd5; end    // 3
            8'h00001D: begin morse_out = 6'b000011; morse_length = 5'd5; end    // S
            8'h00001E: begin morse_out = 6'b100000; morse_length = 0'd0; end    // Invalid ASCII
            8'h00001F: begin morse_out = 6'b111111; morse_length = 5'd5; end    // 0
            8'h000020: begin morse_out = 6'b000000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000021: begin morse_out = 6'b011100; morse_length = 4'd4; end    // J
            8'h000022: begin morse_out = 6'b010000; morse_length = 0'd0; end    // Invalid ASCII
            8'h000023: begin morse_out = 6'b000011; morse_length = 5'd5; end    // 2
            8'h000024: begin morse_out = 6'b000001; morse_length = 5'd5; end    // 5
            8'h000025: begin morse_out = 6'b100001; morse_length = 5'd5; end    // 6
            8'h000026: begin morse_out = 6'b110001; morse_length = 5'd5; end    // 7
            8'h000027: begin morse_out = 6'b111000; morse_length = 5'd5; end    // 8
            8'h000028: begin morse_out = 6'b111100; morse_length = 5'd5; end    // 9
        endcase
    end

endmodule
