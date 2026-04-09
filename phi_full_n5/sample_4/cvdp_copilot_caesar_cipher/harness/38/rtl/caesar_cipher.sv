module caesar_cipher(
    input wire [7:0] input_char, // Corrected to match the 8-bit input_char
    input wire [3:0] key,        // Correctly represents a 4-bit shift key
    output reg [7:0] output_char // Correctly matches the 8-bit output_char
);

always @(*) begin
    // Ensure intermediate calculations fit within the 4-bit key
    wire shift_amount = key;

    // Handle uppercase alphabetical characters
    if (input_char >= "A" && input_char <= "Z") begin
        // Shift amount is already within 4-bit range
        output_char = ((input_char - "A" + shift_amount) % 26) + "A";
    end

    // Handle lowercase alphabetical characters
    else if (input_char >= "a" && input_char <= "z") begin
        // Shift amount is already within 4-bit range
        output_char = ((input_char - "a" + shift_amount) % 26) + "a";
    end

    // Non-alphabetical characters should not be affected
    else begin
        output_char = input_char;
    end
end

endmodule
