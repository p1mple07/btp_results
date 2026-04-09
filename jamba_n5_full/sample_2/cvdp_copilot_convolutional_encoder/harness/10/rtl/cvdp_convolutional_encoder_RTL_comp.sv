        module convolutional_encoder (
             input wire clk,
             input wire rst,
             input wire data_in,
             output reg encoded_bit1,
             output reg encoded_bit2
         );

             // Fixed constraint length
             // Constraint length K=3
             // Use two generator polynomials: (g1 = x^2 + x + 1), (g2 = x^2 + 1)

             always @(posedge clk) begin
                 if (rst) begin
                     encoded_bit1 <= 1'b0;
                     encoded_bit2 <= 1'b0;
                 end else begin
                     encoded_bit1 = data_in ^ 111;
                     encoded_bit2 = data_in ^ 101;
                 end
             end

         endmodule
        