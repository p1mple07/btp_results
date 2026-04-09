module convolutional_encoder (
     input clk,
     input rst,
     input data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length
     // Constraint length K=3
     // Shift register logic
     reg [1:0] shift_reg [0:2]; // 3-bit shift register

     // Generator polynomials: g1=111 (x^2 + x + 1), g2=101 (x^2 + 1)
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             shift_reg <= {2'b0, 2'b0, 2'b0}; // Reset shift register
         end else begin
             shift_reg <= {shift_reg[2:0], data_in}; // Shift left

             // Generate encoded bits using generator polynomials
             encoded_bit1 <= shift_reg[1] ^ shift_reg[0] ^ shift_reg[2];
             encoded_bit2 <= shift_reg[1] ^ shift_reg[2];
         end
     end
 endmodule
