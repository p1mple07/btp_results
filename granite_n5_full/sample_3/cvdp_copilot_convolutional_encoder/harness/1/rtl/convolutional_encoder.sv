module convolutional_encoder (
  input wire clk,
  input wire rst,
  input wire data_in,
  output reg encoded_bit1,
  output reg encoded_bit2
);

  // Shift register to hold the previous 2 bits
  reg [1:0] prev_bits;

  // Generator polynomial g1 = x^2 + x + 1
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      prev_bits <= 2'b00;
    end else begin
      prev_bits <= {prev_bits[0], data_in};
    end
  end

  // Generator polynomial g2 = x^2 + 1
  reg [1:0] gen_poly_g2;
  initial begin
    gen_poly_g2 = 2'b01;
  end

  assign encoded_bit1 = ^(gen_poly_g2 * prev_bits);
  assign encoded_bit2 = ~^(gen_poly_g2 * prev_bits);

endmodule