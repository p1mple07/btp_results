module convolutional_encoder (
    input  logic         clk,
    input  logic         rst,
    input  logic         data_in,
    output logic         encoded_bit1,
    output logic         encoded_bit2
);

  // 2-bit shift register to hold the previous two bits.
  // Convention: shift_reg[1] is the oldest bit, shift_reg[0] is the next bit.
  logic [1:0] shift_reg;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      shift_reg      <= 2'b00;
      encoded_bit1   <= 1'b0;
      encoded_bit2   <= 1'b0;
    end else begin
      // Update the shift register:
      // New data_in is shifted into the LSB while the previous LSB becomes the MSB.
      shift_reg <= { shift_reg[0], data_in };

      // The encoding window is: [oldest = shift_reg[1], middle = shift_reg[0], current = data_in]

      // Generator polynomial g1 = "111" (x^2 + x + 1):
      // encoded_bit1 = (oldest XOR middle XOR current)
      encoded_bit1 <= shift_reg[1] ^ shift_reg[0] ^ data_in;

      // Generator polynomial g2 = "101" (x^2 + 1):
      // encoded_bit2 = (oldest XOR current)
      encoded_bit2 <= shift_reg[1] ^ data_in;
    end
  end

endmodule