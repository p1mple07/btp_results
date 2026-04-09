module caesar_cipher(
    input  wire [7:0] input_char, // 8-bit ASCII character
    input  wire [3:0] key,        // 4-bit shift key
    output reg  [7:0] output_char // 8-bit shifted output character
);

  // Define ASCII constants and number of letters for clarity
  localparam ASCII_A = 8'h41;
  localparam ASCII_Z = 8'h5A;
  localparam ASCII_a = 8'h61;
  localparam ASCII_z = 8'h7A;
  localparam NUM_LETTERS = 26;

  always @(*) begin
    // For uppercase letters, expand the 4-bit key to 8 bits to avoid truncation
    if (input_char >= ASCII_A && input_char <= ASCII_Z) begin
      output_char = ((input_char - ASCII_A + {4'b0, key}) % NUM_LETTERS) + ASCII_A;
    end
    // For lowercase letters, similarly expand the 4-bit key
    else if (input_char >= ASCII_a && input_char <= ASCII_z) begin
      output_char = ((input_char - ASCII_a + {4'b0, key}) % NUM_LETTERS) + ASCII_a;
    end
    else begin
      output_char = input_char;
    end
  end

endmodule