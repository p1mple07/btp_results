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
     // State variable to represent the shift register contents
     reg state = 0; // 00
     // State transitions
     always @* begin
         case (state, data_in)
             when (0, 0)
                 encoded_bit1 = 0;
                 encoded_bit2 = 0;
                 next_state = 0 << 1 | 0; // 00
             when (0, 1)
                 encoded_bit1 = 1;
                 encoded_bit2 = 1;
                 next_state = 0 << 1 | 1; // 01
             when (1, 0)
                 encoded_bit1 = 1;
                 encoded_bit2 = 0;
                 next_state = 1 << 1 | 0; // 10
             when (1, 1)
                 encoded_bit1 = 0;
                 encoded_bit2 = 1;
                 next_state = 1 << 1 | 1; // 11
             when (2, 0)
                 encoded_bit1 = 1;
                 encoded_bit2 = 0;
                 next_state = (2 << 1) | 0; // 00
             when (2, 1)
                 encoded_bit1 = 0;
                 encoded_bit2 = 1;
                 next_state = (2 << 1) | 1; // 01
             when (3, 0)
                 encoded_bit1 = 0;
                 encoded_bit2 = 1;
                 next_state = (3 << 1) | 0; // 10
             when (3, 1)
                 encoded_bit1 = 1;
                 encoded_bit2 = 0;
                 next_state = (3 << 1) | 1; // 11
             default
                 encoded_bit1 = 0;
                 encoded_bit2 = 0;
                 next_state = state << 1 | data_in;
         endcase
     end
     // Update state
     always @* begin
         state = next_state;
     end
     // Synchronization
     always @posedge clk or @negedge rst begin
         if (rst) begin
             state = 0;
             encoded_bit1 = 0;
             encoded_bit2 = 0;
         end
     end
 endmodule