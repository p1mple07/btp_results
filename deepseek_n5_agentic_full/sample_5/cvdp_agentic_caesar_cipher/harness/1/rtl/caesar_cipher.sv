module caesar_cipher(
  input  wire [7:0] input_char,
  input  wire [3:0] key,
  output reg  [7:0] output_char
);

function [7:0] shift;
  input [7:0] c;
  input [3:0] k;
  begin
    if (c >= 65 && c <= 90) // Uppercase letters
      shift = (((c - 65) + k) % 26) + 65;
    else if (c >= 97 && c <= 122) // Lowercase letters
      shift = (((c - 97) + k) % 26) + 97;
    else
      shift = c;
  end
endfunction

always @(*) begin
  output_char = shift(input_char, key);
end

endmodule