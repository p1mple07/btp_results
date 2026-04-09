module caesar_cipher (
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

    assign output_char = input_char;

    if (input_char[3:0] == 4'b0000) begin // 'A'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0001) begin // 'B'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0010) begin // 'C'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0011) begin // 'D'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0100) begin // 'E'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0101) begin // 'F'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0110) begin // 'G'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b0111) begin // 'H'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1000) begin // 'I'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1001) begin // 'J'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1010) begin // 'K'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1011) begin // 'L'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1100) begin // 'M'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1101) begin // 'N'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1110) begin // 'O'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b1111) begin // 'P'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10000) begin // 'Q'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10001) begin // 'R'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10010) begin // 'S'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10011) begin // 'T'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10100) begin // 'U'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10101) begin // 'V'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10110) begin // 'W'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b10111) begin // 'X'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b11000) begin // 'Y'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else if (input_char[3:0] == 4'b11001) begin // 'Z'
        output_char = input_char + key;
        if (output_char > 'Z') output_char -= 26;
    end
    else
        output_char = input_char;

endfunction
