module caesar_cipher(
    input  wire [7:0] input_char,
    input  wire [3:0] key,
    output reg [7:0] output_char
);

function [7:0] shift;
  input  [7:0] c;
  input  [3:0] k;
  begin
    // Determine if the character is uppercase, lowercase, or outside
    if (((c & 0x0F00) != 0) && (c & 0x00FF)) {
      // Uppercase letter
      if (c >= 0xA0 && c <= 0-zA0) { 
        shift = (c - 0x41 + k) % 26 + 0x41;
      }
    } else if (((c & 0x1F00) != 0) && (c & 0x00FF)) {
      // Lowercase letter
      if (c >= 0xD8 && c <= 0xDC0) {
        shift = (c - 0x61 + k) % 26 + 0x61;
      }
    }
    output_char = shift;
  end
endfunction

endmodule