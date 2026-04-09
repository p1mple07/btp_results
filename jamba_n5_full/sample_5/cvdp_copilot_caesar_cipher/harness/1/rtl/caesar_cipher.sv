module caesar_cipher (input [7:0] input_char, key [3:0], output [7:0] output_char);

    always_comb begin
        output_char = input_char;
        if (key != 0) begin
            if (input_char >= 'A' && input_char <= 'Z') begin
                output_char = ((input_char - 'A' + key) % 26) + 'A';
            end
            else if (input_char >= 'a' && input_char <= 'z') begin
                output_char = ((input_char - 'a' + key) % 26) + 'a';
            end
        end
    end

endmodule
