module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     
     parameter K = 3; // Constraint length K=3
     reg [K-1:0] data_reg; // Shift register to store the input data
     reg [1:0] encoded_bits; // Two encoded bits

     always @(posedge clk or posedge rst) begin
         if (rst) begin
             data_reg <= 0;
             encoded_bits <= 0;
         } else begin
             data_reg <= {data_in, data_reg[K-2:0]}; // Shift left to insert new data into the register
             encoded_bits <= encoded_bits >> 1; // Shift right to remove the least significant bit
             if (encoded_bits == 0) begin
                 encoded_bits[1] <= ~data_reg[K-1]; // Calculate the second encoded bit using the generator polynomial
                 encoded_bits[0] <= data_reg[K-1] & data_reg[K-2]; // Calculate the first encoded bit using the generator polynomial
             end
         end
     end
     
     assign encoded_bit1 = encoded_bits[1];
     assign encoded_bit2 = encoded_bits[0];
     
 endmodule