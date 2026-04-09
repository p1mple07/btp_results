module caesar_cipher(
    input  wire [7:0] input_char, // 8-bit ASCII character
    input  wire [3:0] key,        // 4-bit shift key
    output reg  [7:0] output_char // 8-bit shifted output character
);

    // Define ASCII constants with explicit 8-bit widths
    localparam [7:0] ASCII_A = 8'h41;
    localparam [7:0] ASCII_Z = 8'h5A;
    localparam [7:0] ASCII_a = 8'h61;
    localparam [7:0] ASCII_z = 8'h7A;
    localparam [7:0] NUM_ALPHA = 8'd26;

always @(*) begin
    if (input_char >= ASCII_A && input_char <= ASCII_Z) begin
        // Ensure all intermediate expressions are 8-bit wide
        output_char = ((((input_char - ASCII_A) + key) % NUM_ALPHA) + ASCII_A);
    end
    else if (input_char >= ASCII_a && input_char <= ASCII_z) begin
        output_char = ((((input_char - ASCII_a) + key) % NUM_ALPHA) + ASCII_a);
    end
    else begin
        output_char = input_char;
    end
end

endmodule