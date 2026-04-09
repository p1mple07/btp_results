module caesar_cipher(
    input_char,
    key,
    output_char
);
    // Check if input_char is uppercase letter
    if (input_char >= 'A' && input_char <= 'Z') {
        output_char = ('A' + (input_char - 'A' + key) % 26);
    }
    // Check if input_char is lowercase letter
    else if (input_char >= 'a' && input_char <= 'z') {
        output_char = ('a' + (input_char - 'a' + key) % 26);
    }
    // Else, output unchanged
    else {
        output_char = input_char;
    }
endmodule