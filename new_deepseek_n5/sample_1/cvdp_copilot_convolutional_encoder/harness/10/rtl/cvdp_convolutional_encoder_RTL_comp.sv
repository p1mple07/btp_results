module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );

   reg shift_reg1, shift_reg2;

   // Initialize shift registers to 0
   always @* begin
       if (rst) begin
           shift_reg1 = 0;
           shift_reg2 = 0;
       end
   end

   // Compute encoded bits
   always @* begin
       encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
       encoded_bit2 = data_in ^ shift_reg2;
   end

   // Shift the shift registers
   always @* begin
       shift_reg1 = data_in;
       shift_reg2 = shift_reg1_old; // Wait, but how to capture the previous value?
       // Oh, I need to capture the previous value before shifting.
       // So, I should store the previous shift_reg1 in a temporary variable.
       // Let me adjust the code.

       // Capture the current value of shift_reg1
       reg shift_reg1_old;
       always @* begin
           shift_reg1_old = shift_reg1;
       end

       // Then, in the shift block:
       shift_reg1 = data_in;
       shift_reg2 = shift_reg1_old;
   end

Wait, but in Verilog, the always blocks are not synchronous. So, I need to make sure that the shift happens correctly.

Alternatively, I can use a single always block with a delay or ensure that the capture is done before the shift.

Wait, perhaps a better approach is to use a single always block that first captures the current state, then computes the outputs, then shifts the registers.

So, the code would be:

module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );

   reg shift_reg1, shift_reg2, shift_reg1_old;

   // Initialize shift registers to 0
   always @* begin
       if (rst) begin
           shift_reg1 = 0;
           shift_reg2 = 0;
       end
   end

   // Compute encoded bits and shift registers
   always @* begin
       shift_reg1_old = shift_reg1;
       encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
       encoded_bit2 = data_in ^ shift_reg2;
       shift_reg1 = data_in;
       shift_reg2 = shift_reg1_old;
   end

Wait, but in Verilog, the assignments in the always block are atomic, so the shift_reg1_old is captured before shift_reg1 is updated. So, this should work.

Let me test this with an example.

Initial state: shift_reg1=0, shift_reg2=0.

Input data_in=1:

- shift_reg1_old = 0
- encoded_bit1 = 1 ^ 0 ^ 0 = 1
- encoded_bit2 = 1 ^ 0 = 1
- shift_reg1 becomes 1
- shift_reg2 becomes 0

Next input data_in=0:

- shift_reg1_old = 1
- encoded_bit1 = 0 ^ 1 ^ 0 = 1
- encoded_bit2 = 0 ^ 0 = 0
- shift_reg1 becomes 0
- shift_reg2 becomes 1

Next input data_in=1:

- shift_reg1_old = 0
- encoded_bit1 = 1 ^ 0 ^ 1 = 0
- encoded_bit2 = 1 ^ 1 = 0
- shift_reg1 becomes 1
- shift_reg2 becomes 0

This seems correct.

So, the code should be as follows, including the necessary captures and shifts.


module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );

     // Fixed constraint length K=3
     // Shift registers to store previous two bits
     reg shift_reg1, shift_reg2, shift_reg1_old;

     // Initialize shift registers to 0
     always @* begin
         if (rst) begin
             shift_reg1 = 0;
             shift_reg2 = 0;
         end
     end

     // Compute encoded bits and update shift registers
     always @* begin
         shift_reg1_old = shift_reg1;
         encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
         encoded_bit2 = data_in ^ shift_reg2;
         shift_reg1 = data_in;
         shift_reg2 = shift_reg1_old;
     end
endmodule