module caesar_cipher(
    input_char,
    key,
    output_char
);
    case input_char
        'A' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'B' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'C' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'D' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'E' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'F' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'G' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'H' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'I' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'J' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'K' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'L' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'M' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'N' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'O' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'P' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'Q' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'R' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'S' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'T' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'U' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'V' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'W' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'X' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'Y' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'Z' + key: output_char = 'A' + (input_char - 'A' + key) % 26;
        'a' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'b' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'c' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'd' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'e' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'f' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'g' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'h' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'i' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'j' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'k' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'l' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'm' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'n' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'o' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'p' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'q' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'r' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        's' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        't' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'u' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'v' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'w' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'x' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'y' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        'z' + key: output_char = 'a' + (input_char - 'a' + key) % 26;
        default: output_char = input_char;
    endcase
endmodule