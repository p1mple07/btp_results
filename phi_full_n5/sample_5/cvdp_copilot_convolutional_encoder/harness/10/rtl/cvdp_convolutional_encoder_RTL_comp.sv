module convolutional_encoder (
     input clk,
     input rst,
     input data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length
     // Constraint length K=3
     // Shift register for storing the input data
     reg [1:0] data_reg [0:2];
     integer i;

     // Encoded bit generation logic
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             // Reset shift register
             for (i = 0; i < 3; i = i + 1) begin
                 data_reg[i] <= 0;
             end
         end else begin
             if (rst == 0) begin
                 // Shift input data to the right
                 data_reg <= {data_reg[0], data_in};
             end
             // Generate encoded bits
             encoded_bit1 <= data_reg[1] ^ data_reg[2];
             encoded_bit2 <= data_reg[1] ^ data_reg[0];
         end
     end
 endmodule
