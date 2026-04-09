module caesar_cipher (
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

    logic [7:0] shifted_char;

    always_comb begin
        case (input_char[6:0])
            8'h41: // A
                shifted_char = input_char + key;
                8'h00: // B
                shifted_char = input_char + key;
                8'h01: // C
                shifted_char = input_char + key;
                8'h02: // D
                shifted_char = input_char + key;
                8'h03: // E
                shifted_char = input_char + key;
                8'h04: // F
                shifted_char = input_char + key;
                8'h05: // G
                shifted_char = input_char + key;
                8'h06: // H
                shifted_char = input_char + key;
                8'h07: // I
                shifted_char = input_char + key;
                8'h08: // J
                shifted_char = input_char + key;
                8'h09: // K
                shifted_char = input_char + key;
                8'h0A: // L
                shifted_char = input_char + key;
                8'h0B: // M
                shifted_char = input_char + key;
                8'h0C: // N
                shifted_char = input_char + key;
                8'h0D: // O
                shifted_char = input_char + key;
                8'h0E: // P
                shifted_char = input_char + key;
                8'h0F: // Q
                shifted_char = input_char + key;
                8'h10: // R
                shifted_char = input_char + key;
                8'h11: // S
                shifted_char = input_char + key;
                8'h12: // T
                shifted_char = input_char + key;
                8'h13: // U
                shifted_char = input_char + key;
                8'h14: // V
                shifted_char = input_char + key;
                8'h15: // W
                shifted_char = input_char + key;
                8'h16: // X
                shifted_char = input_char + key;
                8'h17: // Y
                shifted_char = input_char + key;
                8'h18: // Z
                shifted_char = input_char + key;
                default:
                shifted_char = input_char;
        endcase

        // Wrap around using modulo 26
        shifted_char = (shifted_char + 8'h01) % 26;

        // Handle uppercase by converting to 'A'
        case (input_char[6:0])
            8'h00: // A
                output_char = shifted_char;
            8'h01: // B
                output_char = shifted_char;
            8'h02: // C
                output_char = shifted_char;
            8'h03: // D
                output_char = shifted_char;
            8'h04: // E
                output_char = shifted_char;
            8'h05: // F
                output_char = shifted_char;
            8'h06: // G
                output_char = shifted_char;
            8'h07: // H
                output_char = shifted_char;
            8'h08: // I
                output_char = shifted_char;
            8'h09: // J
                output_char = shifted_char;
            8'h0A: // K
                output_char = shifted_char;
            8'h0B: // L
                output_char = shifted_char;
            8'h0C: // M
                output_char = shifted_char;
            8'h0D: // N
                output_char = shifted_char;
            8'h0E: // O
                output_char = shifted_char;
            8'h0F: // P
                output_char = shifted_char;
            8'h10: // Q
                output_char = shifted_char;
            8'h11: // R
                output_char = shifted_char;
            8'h12: // S
                output_char = shifted_char;
            8'h13: // T
                output_char = shifted_char;
            8'h14: // U
                output_char = shifted_char;
            8'h15: // V
                output_char = shifted_char;
            8'h16: // W
                output_char = shifted_char;
            8'h17: // X
                output_char = shifted_char;
            8'h18: // Y
                output_char = shifted_char;
            8'h19: // Z
                output_char = shifted_char;
            default:
                output_char = input_char;
        endcase
    end
endmodule
