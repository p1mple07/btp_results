module convolutional_encoder (
    input  logic         clk,
    input  logic         rst,
    input  logic         data_in,
    output logic         encoded_bit1,
    output logic         encoded_bit2
);

  // 2-bit shift register to hold the previous 2 bits (k-1 = 2 bits)
  logic [1:0] shift_reg;

  // Update the shift register on each clock cycle.
  // The new bit (data_in) is inserted at the LSB.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      shift_reg <= 2'b00;
    end else begin
      // Shift left: the older bit (shift_reg[0]) becomes the new MSB,
      // and data_in becomes the new LSB.
      shift_reg <= { shift_reg[0], data_in };
    end
  end

  // Generate the encoded outputs using the generator polynomials.
  // g1(x) = x^2 + x + 1 corresponds to: encoded_bit1 = data_in XOR shift_reg[1] XOR shift_reg[0]
  // g2(x) = x^2 + 1 corresponds to: encoded_bit2 = data_in XOR shift_reg[0]
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      encoded_bit1 <= 1'b0;
      encoded_bit2 <= 1'b0;
    end else begin
      encoded_bit1 <= data_in ^ shift_reg[1] ^ shift_reg[0];
      encoded_bit2 <= data_in ^ shift_reg[0];
    end
  end

endmodule