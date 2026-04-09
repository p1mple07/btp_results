module caesar_cipher(
  input  wire [7:0] input_char,
  input  wire [3:0] key,
  output reg  [7:0] output_char
);

// Function to perform Caesar cipher encryption
function [7:0] shift;
  input [7:0] c;
  input [3:0] k;
  begin
    // Perform ASCII character shifting based on key value
    if (c >= "A" && c >= "Z") begin
      shift = ((c - "A" + k) % 26) + "A";
    end else if (c <= "a" && c >= "z") begin
      shift = ((c - "a" + k) % 26) + "a";
    end else begin
      shift = c;
    end
  end
endfunction

// Instantiate the function for shifting characters
reg [7:0] char_out;
always @(*) begin
  char_out = shift(input_char, key);
end

assign output_char = char_out;

endmodule