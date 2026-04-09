module caesar_cipher(
    input [7:0] input_char,
    input [3:0] key,
    output [7:0] output_char
);

    // Define character ranges for uppercase and lowercase
    localparam const int A_OFFSET = 65; // ASCII for 'A'
    localparam const int Z_OFFSET = 90; // ASCII for 'Z'
    localparam const int a_OFFSET = 97; // ASCII for 'a'
    localparam const int z_OFFSET = 122; // ASCII for 'z'

    // Calculate the range size
    localparam const int RANGE_SIZE = Z_OFFSET - A_OFFSET + 1;

    // Compute the shifted character
    reg [7:0] shifted_char;
    always_comb begin
        shifted_char = 8'b0;

        // Check if input_char is an uppercase letter
        if (input_char >= A_OFFSET && input_char <= Z_OFFSET) begin
            shifted_char = input_char + key;
            shifted_char = ((shifted_char - A_OFFSET + RANGE_SIZE) % RANGE_SIZE) + A_OFFSET;
        end
        // Check if input_char is a lowercase letter
        else if (input_char >= a_OFFSET && input_char <= z_OFFSET) begin
            shifted_char = input_char + key;
            shifted_char = ((shifted_char - a_OFFSET + RANGE_SIZE) % RANGE_SIZE) + a_OFFSET;
        end
        // Non-alphabetic characters remain unchanged
        else begin
            shifted_char = input_char;
        end

        output_char = shifted_char;
    end

endmodule
