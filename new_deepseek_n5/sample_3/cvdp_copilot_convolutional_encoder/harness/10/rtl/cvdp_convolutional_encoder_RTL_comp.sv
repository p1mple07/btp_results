module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length K=3
     // Shift register for storing previous input bits
     reg shift_reg1, shift_reg2;
     // Generator polynomials coefficients
     literal g1_coeff = 3'b111;
     literal g2_coeff = 3'b101;
     
     // Encode the current bit
     encoded_bit1 = data_in ^ (data_in & shift_reg1) ^ (data_in & shift_reg2);
     encoded_bit2 = data_in ^ shift_reg2;
     
     // Update shift register
     shift_reg1 = data_in;
     shift_reg2 = shift_reg1;
     
     // Reset the encoder
     if (rst) begin
         shift_reg1 = 0;
         shift_reg2 = 0;
     end
 endmodule