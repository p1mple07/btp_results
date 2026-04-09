module palindrome_detect #(parameter N = 3)(
  input  clk,
  input  reset,
  input  bit_stream,
  output reg palindrome_detected
);

  // Shift register to hold the last N bits of the stream
  reg [N-1:0] shift_reg;

  always @(posedge clk) begin
    if (reset) begin
      shift_reg      <= '0;
      palindrome_detected <= 1'b0;
    end else begin
      // Shift in the new bit: the MSB is dropped, LSB is new bit_stream
      shift_reg <= { shift_reg[N-2:0], bit_stream };

      // For a 3-bit window, a palindrome condition is:
      //   shift_reg[0] == shift_reg[2]
      // Since N is 3, shift_reg[0] is the oldest bit and shift_reg[2] is the newest.
      if (shift_reg[0] == shift_reg[N-1])
        palindrome_detected <= 1'b1;
      else
        palindrome_detected <= 1'b0;
    end
  end

endmodule