module caesar_cipher (
    input  wire [7:0] input_char,
    input  wire [3:0] key,
    output reg  [7:0] output_char
);

  // Combinational logic for Caesar cipher encryption
  always_comb begin
    // Check for uppercase letters (A-Z: 0x41 to 0x5A)
    if (input_char >= 8'h41 && input_char <= 8'h5A) begin
      output_char = 8'h41 + ((((input_char - 8'h41) + key) % 26));
    end
    // Check for lowercase letters (a-z: 0x61 to 0x7A)
    else if (input_char >= 8'h61 && input_char <= 8'h7A) begin
      output_char = 8'h61 + ((((input_char - 8'h61) + key) % 26));
    end
    // Non-alphabetic characters remain unchanged
    else begin
      output_char = input_char;
    end
  end

endmodule