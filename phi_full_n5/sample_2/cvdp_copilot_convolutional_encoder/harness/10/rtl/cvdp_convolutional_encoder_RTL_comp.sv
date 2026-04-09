module convolutional_encoder (
     input clk,
     input rst,
     input data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length
     // Constraint length K=3

     // Shift registers for input data and encoded bits
     reg [1:0] data_reg [0:2];
     reg [1:0] encoded_reg [0:2];

     // Generator polynomials: g1=111 (x^2 + x + 1), g2=101 (x^2 + 1)
     reg [2:0] g1 = 3'b111;
     reg [2:0] g2 = 3'b101;

     // Encoding logic
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             data_reg <= 2'b00;
             encoded_reg <= 2'b00;
         end else begin
             data_reg <= {data_reg[1:0], data_in};

             // Encode using g1
             encoded_reg[0] <= data_reg[1] ^ g1[1] ^ data_reg[0];
             encoded_reg[1] <= data_reg[2] ^ g1[0] ^ data_reg[1];

             // Encode using g2
             encoded_reg[2] <= data_reg[2] ^ g2[1] ^ data_reg[1];
             encoded_reg[3] <= data_reg[1] ^ g2[0] ^ data_reg[0];
         end
     end

     // Output assignment
     assign encoded_bit1 = encoded_reg[0];
     assign encoded_bit2 = encoded_reg[1];
 endmodule
