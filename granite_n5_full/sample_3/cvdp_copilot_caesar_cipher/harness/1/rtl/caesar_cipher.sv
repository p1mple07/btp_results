module caesar_cipher(
  input wire [7:0] input_char, // 8-bit ASCII character
  input wire [3:0] key,         // 4-bit shift key
  output reg [7:0] output_char // 8-bit resulting ASCII character
);

  always @(*) begin
    if('a' <= input_char && input_char <= 'z') begin
      output_char = input_char + key;
      if(output_char > 'z') output_char -= 26;
    end else if('A' <= input_char && input_char <= 'Z') begin
      output_char = input_char + key;
      if(output_char > 'Z') output_char -= 26;
    end else begin
      output_char = input_char;
    end
  end
endmodule