module caesar_cipher(
  input logic [7:0] input_char,
  input logic [3:0] key,
  output logic [7:0] output_char
);

  always_comb begin
    if (input_char[7] == 1'b1) begin // Check if input_char is uppercase
      output_char = (input_char + key) % 26;
    end else if (input_char[7] == 1'b0) begin // Check if input_char is lowercase
      output_char = (input_char + key) % 26;
    end else begin // input_char is not alphabetic, so leave it unchanged
      output_char = input_char;
    end
  end
endmodule