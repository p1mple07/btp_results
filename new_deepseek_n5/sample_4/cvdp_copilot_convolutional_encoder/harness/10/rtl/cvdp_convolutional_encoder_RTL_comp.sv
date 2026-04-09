module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     // Fixed constraint length
     // Constraint length K=3
     // It will be necessary to add a shift register logic
     // Generate encoded bits logic here
     // Generator polynomials: g1=111 (x^2 + x + 1), g2=101 (x^2 + 1)
     reg shift_reg_1, shift_reg_2;
     reg current_bit;
     wire next_bit1, next_bit2;
     
     // Initialize shift register
     initial begin
         shift_reg_1 = 0;
         shift_reg_2 = 0;
         current_bit = 0;
     end
     // Encode logic
     always @* begin
         encoded_bit1 = data_in ^ shift_reg_1 ^ shift_reg_2;
         encoded_bit2 = data_in ^ shift_reg_2;
     end
     // Shift register logic
     always @posedge clk begin
         next_bit1 = current_bit;
         next_bit2 = data_in;
         current_bit = next_bit1;
         shift_reg_1 = next_bit2;
         shift_reg_2 = 0;
     end
     // Reset
     initial begin
         $monitor("Convolutional Encoder Initialization");
         rst = 1;
         $wait;
         rst = 0;
     end
endmodule