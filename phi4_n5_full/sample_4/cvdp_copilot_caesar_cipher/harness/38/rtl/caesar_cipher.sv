module caesar_cipher(
    input  wire [7:0] input_char, // 8-bit ASCII character
    input  wire [3:0] key,        // 4-bit shift key
    output reg  [7:0] output_char // 8-bit shifted output character
);

  // Define local parameters for ASCII values and number of letters
  localparam ASCII_A  = 8'd65;  // 'A'
  localparam ASCII_a  = 8'd97;  // 'a'
  localparam NUM_LETTERS = 8'd26;

  always @(*) begin
    if (input_char >= ASCII_A && input_char <= ASCII_A + NUM_LETTERS - 1) begin
      // Compute shifted uppercase letter
      output_char = ((input_char - ASCII_A + key) % NUM_LETTERS) + ASCII_A;
    end
    else if (input_char >= ASCII_a && input_char <= ASCII_a + NUM_LETTERS - 1) begin
      // Compute shifted lowercase letter
      output_char = ((input_char - ASCII_a + key) % NUM_LETTERS) + ASCII_a;
    end
    else begin
      // Non-alphabetical characters remain unchanged
      output_char = input_char;
    end
  end

endmodule