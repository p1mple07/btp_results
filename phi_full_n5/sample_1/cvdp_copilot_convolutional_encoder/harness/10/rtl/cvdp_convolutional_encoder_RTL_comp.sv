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
     reg [1:0] shift_reg [0:2];
     
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             shift_reg <= {2'b0, 2'b0, 2'b0};
         end else begin
             shift_reg <= {shift_reg[2], shift_reg[1], shift_reg[0], data_in};
         end
     end
     
     // Generator polynomials: g1=111 (x^2 + x + 1), g2=101 (x^2 + 1)
     always @(data_in, shift_reg) begin
         case (shift_reg)
             3'b111: begin
                 encoded_bit1 <= shift_reg[1];
                 encoded_bit2 <= shift_reg[2];
              end
             3'b101: begin
                 encoded_bit1 <= shift_reg[2];
                 encoded_bit2 <= shift_reg[1];
              end
             3'b011: begin
                 encoded_bit1 <= shift_reg[0];
                 encoded_bit2 <= shift_reg[1];
              end
             3'b010: begin
                 encoded_bit1 <= shift_reg[1];
                 encoded_bit2 <= shift_reg[0];
              end
             3'b001: begin
                 encoded_bit1 <= shift_reg[2];
                 encoded_bit2 <= shift_reg[0];
              end
             3'b000: begin
                 encoded_bit1 <= 1'b0;
                 encoded_bit2 <= 1'b0;
              end
         endcase
     end
 endmodule
