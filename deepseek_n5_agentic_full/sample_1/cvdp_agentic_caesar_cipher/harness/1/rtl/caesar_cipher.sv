module caesar_cipher(
  input  wire [7:0] input_char,
  input  wire [3:0] key,
  output reg  [7:0] output_char
);

constant [7:0] 'A'    : ASCII 'A';
constant [7:0] 'B'    : ASCII 'B';
constant [7:0] 'C'    : ASCII 'C';
constant [7:0] 'D'    : ASCII 'D';
constant [7:0] 'E'    : ASCII 'E';
constant [7:0] 'F'    : ASCII 'F';
constant [7:0] 'G'    : ASCII 'G';
constant [7:0] 'H'    : ASCII 'H';
constant [7:0] 'I'    : ASCII 'I';
constant [7:0] 'J'    : ASCII 'J';
constant [7:0] 'K'    : ASCII 'K';
constant [7:0] 'L'    : ASCII 'L';
constant [7:0] 'M'    : ASCII 'M';
constant [7:0] 'N'    : ASCII 'N';
constant [7:0] 'O'    : ASCII 'O';
constant [7:0] 'P'    : ASCII 'P';
constant [7:0] 'Q'    : ASCII 'Q';
constant [7:0] 'R'    : ASCII 'R';
constant [7:0] 'S'    : ASCII 'S';
constant [7:0] 'T'    : ASCII 'T';
constant [7:0] 'U'    : ASCII 'U';
constant [7:0] 'V'    : ASCII 'V';
constant [7:0] 'W'    : ASCII 'W';
constant [7:0] 'X'    : ASCII 'X';
constant [7:0] 'Y'    : ASCII 'Y';
constant [7:0] 'Z'    : ASCII 'Z';

function [7:0] shift;
  input  wire [7:0] c;
  input  wire [3:0] k;
  
  if (c >= 'A' && c >= 'a' && c <= 'Z' && c <= 'z')
    if (c >= 'A' && c <= 'Z')
      shift = ((c - 'A' + k) % 26) + 'A';
    else
      shift = ((c - 'a' + k) % 26) + 'a';
  else
    shift = c;
endfunction

always @(*) begin
  output_char = shift(input_char, key);
end

endmodule