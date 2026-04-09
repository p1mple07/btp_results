module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length
     // Constraint length K=3
     // Shift register logic for storing input bits
     reg [1:0] input_bits [0:2];
     reg [1:0] encoded_bits [0:2];

     // Generator polynomials: g1=111 (x^2 + x + 1), g2=101 (x^2 + 1)
     // Encoding logic
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             input_bits <= {0, 0, 0};
             encoded_bits <= {0, 0, 0};
         end else begin
             input_bits <= {input_bits[2], input_bits[1], data_in};
             encoded_bits[0] = (input_bits[0] & input_bits[1]) | (input_bits[0] & input_bits[2]);
             encoded_bits[1] = (input_bits[1] & input_bits[2]) | (input_bits[0] & input_bits[2]);
             encoded_bits[2] = (input_bits[0] & input_bits[1]) | (input_bits[1] & input_bits[2]);
         end
     end

     // Output logic
     assign encoded_bit1 = encoded_bits[0];
     assign encoded_bit2 = encoded_bits[1];
 endmodule
