module caesar_cipher (
    input  wire [7:0] input_char,
    input  wire [3:0] key,
    output reg  [7:0] output_char
);

    always_comb begin
        // Default: output the input unchanged.
        output_char = input_char;

        // Check for uppercase letters (A-Z)
        if (input_char >= 8'h41 && input_char <= 8'h5A) begin
            output_char = ((input_char - 8'h41) + key) % 26 + 8'h41;
        end
        // Check for lowercase letters (a-z)
        else if (input_char >= 8'h61 && input_char <= 8'h7A) begin
            output_char = ((input_char - 8'h61) + key) % 26 + 8'h61;
        end
    end

endmodule