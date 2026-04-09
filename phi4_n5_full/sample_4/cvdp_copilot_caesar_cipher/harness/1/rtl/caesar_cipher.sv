module caesar_cipher (
    input  logic [7:0] input_char,
    input  logic [3:0] key,
    output logic [7:0] output_char
);

  always_comb begin
    if ((input_char >= 8'h41) && (input_char <= 8'h5A)) begin
      // Uppercase letter: shift within 'A' (41h) to 'Z' (5Ah)
      output_char = ((input_char - 8'h41) + key) % 26 + 8'h41;
    end else if ((input_char >= 8'h61) && (input_char <= 8'h7A)) begin
      // Lowercase letter: shift within 'a' (61h) to 'z' (7Ah)
      output_char = ((input_char - 8'h61) + key) % 26 + 8'h61;
    end else begin
      // Non-alphabetic character: leave unchanged
      output_char = input_char;
    end
  end

endmodule