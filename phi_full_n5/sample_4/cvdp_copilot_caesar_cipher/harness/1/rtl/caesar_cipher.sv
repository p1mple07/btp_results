module caesar_cipher (
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

    // Constants for ASCII values of 'A' to 'Z' and 'a' to 'z'
    localparam int A_ASCII = 65;
    localparam int Z_ASCII = 90;
    localparam int a_ASCII = 97;
    localparam int z_ASCII = 122;

    // Combinational logic to handle the shift
    always_comb begin
        case (input_char[7:0])
            // Uppercase letters
            'A': output_char = A_ASCII + key;
            'B': output_char = A_ASCII + 1 + key;
            'C': output_char = A_ASCII + 2 + key;
            'D': output_char = A_ASCII + 3 + key;
            'E': output_char = A_ASCII + 4 + key;
            'F': output_char = A_ASCII + 5 + key;
            'G': output_char = A_ASCII + 6 + key;
            'H': output_char = A_ASCII + 7 + key;
            'I': output_char = A_ASCII + 8 + key;
            'J': output_char = A_ASCII + 9 + key;
            'K': output_char = A_ASCII + 10 + key;
            'L': output_char = A_ASCII + 11 + key;
            'M': output_char = A_ASCII + 12 + key;
            'N': output_char = A_ASCII + 13 + key;
            'O': output_char = A_ASCII + 14 + key;
            'P': output_char = A_ASCII + 15 + key;
            'Q': output_char = A_ASCII + 16 + key;
            'R': output_char = A_ASCII + 17 + key;
            'S': output_char = A_ASCII + 18 + key;
            'T': output_char = A_ASCII + 19 + key;
            'U': output_char = A_ASCII + 20 + key;
            'V': output_char = A_ASCII + 21 + key;
            'W': output_char = A_ASCII + 22 + key;
            'X': output_char = A_ASCII + 23 + key;
            'Y': output_char = A_ASCII + 24 + key;
            'Z': output_char = A_ASCII + 25 + key;

            // Lowercase letters
            'a': output_char = a_ASCII + key;
            'b': output_char = a_ASCII + 1 + key;
            'c': output_char = a_ASCII + 2 + key;
            'd': output_char = a_ASCII + 3 + key;
            'e': output_char = a_ASCII + 4 + key;
            'f': output_char = a_ASCII + 5 + key;
            'g': output_char = a_ASCII + 6 + key;
            'h': output_char = a_ASCII + 7 + key;
            'i': output_char = a_ASCII + 8 + key;
            'j': output_char = a_ASCII + 9 + key;
            'k': output_char = a_ASCII + 10 + key;
            'l': output_char = a_ASCII + 11 + key;
            'm': output_char = a_ASCII + 12 + key;
            'n': output_char = a_ASCII + 13 + key;
            'o': output_char = a_ASCII + 14 + key;
            'p': output_char = a_ASCII + 15 + key;
            'q': output_char = a_ASCII + 16 + key;
            'r': output_char = a_ASCII + 17 + key;
            's': output_char = a_ASCII + 18 + key;
            't': output_char = a_ASCII + 19 + key;
            'u': output_char = a_ASCII + 20 + key;
            'v': output_char = a_ASCII + 21 + key;
            'w': output_char = a_ASCII + 22 + key;
            'x': output_char = a_ASCII + 23 + key;
            'y': output_char = a_ASCII + 24 + key;
            'z': output_char = a_ASCII + 25 + key;

            // Non-alphabetic characters
            default: output_char = input_char;
        endcase
    end

endmodule
