module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
 
 parameter K = 3; // Constraint length
 parameter G1 = 11; // First generator polynomial coefficient
 parameter G2 = 10; // Second generator polynomial coefficient
 
 reg [K-1:0] shifting_reg; // Shift register for storing previous input bits
 
 always @(posedge clk or posedge rst) begin
   if (rst) begin
     shifting_reg <= 0; // Reset the shift register
   end else begin
     shifting_reg <= {shifting_reg[K-2:0], data_in}; // Shift input bits into the register
   end
 end
 
 assign encoded_bit1 = (shifting_reg[K-1] ^ shifting_reg[K-2]) & ((G1 << K-2) | (G2 << K-1)); // Calculate the first encoded bit using the generator polynomials
 assign encoded_bit2 = (shifting_reg[K-1] ^ shifting_reg[K-2]) & (G2 << K-1); // Calculate the second encoded bit using the second generator polynomial
 
 endmodule