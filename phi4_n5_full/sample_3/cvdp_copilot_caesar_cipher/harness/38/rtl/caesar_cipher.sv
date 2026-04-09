module caesar_cipher(
    input  wire [7:0] input_char, // 8-bit ASCII character
    input  wire [3:0] key,        // 4-bit shift key
    output reg  [7:0] output_char // 8-bit shifted output character
);

  // LINT improvements:
  // 1. Replaced string literals ("A", "Z", "a", "z") with 8-bit hexadecimal constants
  //    to ensure proper bit-width matching.
  // 2. Explicitly zero-extended the 4-bit key to 8 bits to avoid any potential truncation
  //    or unintended type conversions in arithmetic operations.
  
  always @(*) begin
    if (input_char >= 8'h41 && input_char <= 8'h5A) begin
      output_char = (((input_char - 8'h41) + {4'b0, key}) % 8'd26) + 8'h41;
    end
    else if (input_char >= 8'h61 && input_char <= 8'h7A) begin
      output_char = (((input_char - 8'h61) + {4'b0, key}) % 8'd26) + 8'h61;
    end
    else begin
      output_char = input_char;
    end
  end

endmodule