module caesar_cipher(
    input  logic [7:0] input_char,
    input  logic [3:0] key,
    output logic [7:0] output_char
);

    // Define ASCII constants for A-Z and a-z
    localparam [7:0] ASCII_A = 8'h41;
    localparam [7:0] ASCII_Z = 8'h5A;
    localparam [7:0] ASCII_a = 8'h61;
    localparam [7:0] ASCII_z = 8'h7A;

    always_comb begin
        // Default: leave non-alphabetic characters unchanged
        output_char = input_char;

        // Uppercase letter handling
        if (input_char >= ASCII_A && input_char <= ASCII_Z) begin
            output_char = ASCII_A + ((input_char - ASCII_A + key) % 26);
        end
        // Lowercase letter handling
        else if (input_char >= ASCII_a && input_char <= ASCII_z) begin
            output_char = ASCII_a + ((input_char - ASCII_a + key) % 26);
        end
    end

endmodule