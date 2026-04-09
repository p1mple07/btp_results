module palindrome_detect #(
  parameter N = 3
) (
  input  clk,
  input  reset,
  input  bit_stream,
  output reg palindrome_detected
);

  // Shift register to hold the previous 2 bits.
  // The sliding window is: [shift_reg[1], shift_reg[0], current bit]
  // A 3-bit palindrome is detected when the first and third bits are equal.
  reg [1:0] shift_reg;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      shift_reg           <= 2'b0;
      palindrome_detected <= 1'b0;
    end else begin
      // Shift left: new bit goes to LSB; oldest bit is in MSB (shift_reg[1])
      shift_reg <= {shift_reg[0], bit_stream};

      // Check if the 3-bit window [shift_reg[1], shift_reg[0], bit_stream] is a palindrome.
      // For a 3-bit sequence, the condition is: shift_reg[1] == bit_stream.
      if (shift_reg[1] == bit_stream)
        palindrome_detected <= 1'b1;
      else
        palindrome_detected <= 1'b0;
    end
  end

endmodule