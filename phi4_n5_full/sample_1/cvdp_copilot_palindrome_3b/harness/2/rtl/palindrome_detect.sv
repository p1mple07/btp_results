module palindrome_detect #(parameter N = 3)(
    input         clk,
    input         reset,
    input         bit_stream,
    output reg    palindrome_detected
);

  // A 3-bit shift register will hold the last three bits of the stream.
  // We use a simple counter to delay checking until the register is fully populated.
  reg [N-1:0] shift_reg;
  reg [1:0]   counter;  // Counts cycles after reset until a full window is available

  always @(posedge clk) begin
    if (reset) begin
      shift_reg   <= {N{1'b0}};
      counter     <= 2'b00;
      palindrome_detected <= 1'b0;
    end else begin
      if (counter < 2) begin
        // Fill the shift register until it contains N bits.
        // Shift right so that the new bit becomes the MSB.
        shift_reg <= {bit_stream, shift_reg[N-1:1]};
        counter   <= counter + 1;
        palindrome_detected <= 1'b0;
      end else begin
        // Now the window [shift_reg[0], shift_reg[1], shift_reg[2]] is valid.
        // For a 3-bit palindrome, we require that the first bit equals the third bit.
        if (shift_reg[0] == shift_reg[N-1])
          palindrome_detected <= 1'b1;
        else
          palindrome_detected <= 1'b0;
          
        // Shift the register: new bit becomes MSB.
        shift_reg <= {bit_stream, shift_reg[N-1:1]};
      end
    end
  end

endmodule