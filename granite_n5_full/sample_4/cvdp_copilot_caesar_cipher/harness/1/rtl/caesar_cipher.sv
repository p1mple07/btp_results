module caesar_cipher(
  input [7:0] input_char, // ASCII character to be shifted
  input [3:0] key,         // Shift key (0-15)
  output reg [7:0] output_char // Resulting ASCII character after Caesar cipher shift
);

  always @(*) begin
    case (input_char[6:0])
      8'b1100000: // 'A'
        output_char = (key[3:0] == 4'b0000)? 8'b1100000 : ((key[3:0] % 26) + 8'b1100000);
      default: // Other alphabets
        output_char = (input_char < 8'b1000000)? (key[3:0] > 4'b0000? input_char - key[3:0] : input_char + (26 - key[3:0])) : input_char;
    endcase
  end

endmodule