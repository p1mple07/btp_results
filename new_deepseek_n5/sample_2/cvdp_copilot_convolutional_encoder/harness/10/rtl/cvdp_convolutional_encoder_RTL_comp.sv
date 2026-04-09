module. The input is data_in, and the outputs are encoded_bit1 and encoded_bit2. I'll use a process sensitive to the clock and reset.

Wait, but in Verilog, the process should be sensitive to the clock and reset. So, I'll write a continuous process that's always sensitive to the clock and reset signals.

In each clock cycle, when the reset is inactive, I'll compute the encoded bits. Let's see:

- For encoded_bit1, it's g1 applied to data_in, shift_reg1, and shift_reg2. So, data_in XOR shift_reg1 XOR shift_reg2.
- For encoded_bit2, it's g2 applied to data_in and shift_reg2. So, data_in XOR shift_reg2.

After computing the encoded bits, I'll shift the shift register. That means shift_reg1 becomes data_in, and shift_reg2 becomes shift_reg1. Then, shift_reg1 is shifted left, so it becomes the new data_in, but wait, no, the shift is done by assigning new values.

Wait, no. The shift is done by assigning shift_reg1 to data_in, and shift_reg2 to shift_reg1. So, each clock cycle, the new data_in becomes shift_reg1, and the previous shift_reg1 becomes shift_reg2. The oldest bit is lost.

Wait, no, the shift is done by assigning shift_reg1 = data_in, and shift_reg2 = shift_reg1. So, the new data_in is stored in shift_reg1, and shift_reg2 takes the previous shift_reg1. Then, the next data_in will be in shift_reg1, and so on.

Wait, but in the next clock cycle, data_in will be the next bit. So, the shift is correct.

Let me outline the steps:

1. On positive clock edge:
   a. If reset is inactive, compute encoded_bit1 and encoded_bit2.
   b. Shift the shift register: shift_reg1 becomes data_in, shift_reg2 becomes shift_reg1 (previous shift_reg1).
   c. data_in is then stored in shift_reg1 for the next cycle.

Wait, no, because data_in is the current input. So, when the clock comes, data_in is the new bit, and shift_reg1 and shift_reg2 are the previous two bits.

So, the computation is done, then the shift happens, which means the new data_in is stored in shift_reg1, and shift_reg2 is updated to shift_reg1's previous value.

Wait, perhaps I should structure it as:

- Compute encoded bits based on data_in, shift_reg1, shift_reg2.
- Then, shift the shift register: shift_reg1 becomes data_in, shift_reg2 becomes shift_reg1.
- But wait, that would shift the data into shift_reg1, and shift_reg2 takes the previous shift_reg1, which is the second oldest bit.

Wait, no, because the shift register should hold the last two bits. So, after the shift, the new data_in is in shift_reg1, and shift_reg2 is the previous shift_reg1, which was the second bit.

Yes, that makes sense.

So, in code:

Within the process:

if (!rst) {
   shift_reg1 = 0;
   shift_reg2 = 0;
}

if (posedge clk) {
   if (!rst) {
      // compute encoded bits
      encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
      encoded_bit2 = data_in ^ shift_reg2;
      
      // shift the shift register
      shift_reg1 = data_in;
      shift_reg2 = shift_reg1_old; // Wait, but how to capture the previous shift_reg1?
      // Oh, right, because in the same clock cycle, we can't assign and capture at the same time. So, we need to capture the current shift_reg1 before shifting.

      // So, we need to save the current shift_reg1 into a temporary variable.
      // Let me adjust the code:

      // Compute encoded bits
      encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
      encoded_bit2 = data_in ^ shift_reg2;

      // Capture the current shift_reg1
      reg temp_shift_reg1 = shift_reg1;

      // Shift the shift register
      shift_reg1 = data_in;
      shift_reg2 = temp_shift_reg1;
   }
}

Wait, but in Verilog, assignments happen at the end of the clock cycle. So, the shift_reg2 assignment uses the previous value of shift_reg1, which is correct.

So, the code inside the process would be:

if (!rst) {
   shift_reg1 = 0;
   shift_reg2 = 0;
}

if (posedge clk) {
   if (!rst) {
      encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
      encoded_bit2 = data_in ^ shift_reg2;

      shift_reg1 = data_in;
      shift_reg2 = shift_reg1_old; // Wait, no, because shift_reg1 is being updated. So, we need to capture the current shift_reg1 before shifting.

      // So, we need to save the current shift_reg1 into a temporary variable.
      // Let me adjust the code:

      // Compute encoded bits
      encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
      encoded_bit2 = data_in ^ shift_reg2;

      // Capture the current shift_reg1
      reg temp_shift_reg1 = shift_reg1;

      // Shift the shift register
      shift_reg1 = data_in;
      shift_reg2 = temp_shift_reg1;
   }
}

Wait, but in Verilog, you can't assign to a temporary variable inside the process like that. So, perhaps I should capture the current shift_reg1 before shifting.

Alternatively, perhaps I can structure it as:

if (!rst) {
   shift_reg1 = 0;
   shift_reg2 = 0;
}

if (posedge clk) {
   if (!rst) {
      encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
      encoded_bit2 = data_in ^ shift_reg2;

      // Capture the current shift_reg1
      reg temp_shift_reg1 = shift_reg1;

      // Shift the shift register
      shift_reg1 = data_in;
      shift_reg2 = temp_shift_reg1;
   }
}

Yes, that should work.

So, putting it all together, the code inside the module would be:

module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     reg shift_reg1, shift_reg2;
     reg encoded_bit1, encoded_bit2;

     initial begin
         shift_reg1 = 0;
         shift_reg2 = 0;
     end

     if (rst) begin
         shift_reg1 = 0;
         shift_reg2 = 0;
     end

     always @posedge clk begin
         if (!rst) begin
             encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
             encoded_bit2 = data_in ^ shift_reg2;

             // Capture the current shift_reg1
             reg temp_shift_reg1 = shift_reg1;

             // Shift the shift register
             shift_reg1 = data_in;
             shift_reg2 = temp_shift_reg1;
         end
     end
endmodule

Wait, but in Verilog, the initial block can be simplified. Also, the always @posedge clk can be used with a condition inside.

Alternatively, perhaps it's better to structure it as:

module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     reg shift_reg1, shift_reg2;
     reg encoded_bit1, encoded_bit2;

     always @posedge clk, !rst begin
         encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
         encoded_bit2 = data_in ^ shift_reg2;

         // Capture the current shift_reg1
         reg temp_shift_reg1 = shift_reg1;

         // Shift the shift register
         shift_reg1 = data_in;
         shift_reg2 = temp_shift_reg1;
     end
     initial begin
         shift_reg1 = 0;
         shift_reg2 = 0;
     end
endmodule

Wait, but the initial block is only executed once, at the start. So, perhaps it's better to initialize the shift registers inside the initial block.

Alternatively, perhaps the initial block can be removed, and the shift_reg1 and shift_reg2 can be initialized to 0 in the always block.

Wait, no, because in Verilog, the initial block is executed once, so if we don't have it, the shift_reg1 and shift_reg2 will be 0 by default.

Wait, no, in Verilog, the initial block is optional. So, perhaps the initial block can be removed, and the shift_reg1 and shift_reg2 will be initialized to 0.

So, the code can be simplified to:

module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     reg shift_reg1, shift_reg2;
     reg encoded_bit1, encoded_bit2;

     always @posedge clk, !rst begin
         encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
         encoded_bit2 = data_in ^ shift_reg2;

         // Capture the current shift_reg1
         reg temp_shift_reg1 = shift_reg1;

         // Shift the shift register
         shift_reg1 = data_in;
         shift_reg2 = temp_shift_reg1;
     end
endmodule

Wait, but in this case, the initial values of shift_reg1 and shift_reg2 are 0, which is correct.

Testing this logic: when the first data_in comes in, shift_reg1 is 0, shift_reg2 is 0.

So, encoded_bit1 = data_in ^ 0 ^ 0 = data_in
encoded_bit2 = data_in ^ 0 = data_in

Then, shift_reg1 becomes data_in, shift_reg2 becomes 0.

Next clock cycle, data_in is the previous data, shift_reg1 is data_in, shift_reg2 is 0.

So, encoded_bit1 = data_in ^ data_in ^ 0 = 0
encoded_bit2 = data_in ^ 0 = data_in

Wait, that doesn't seem right. Because for K=3, each encoded bit should depend on the current data and the previous two.

Wait, perhaps I made a mistake in the generator polynomials.

Wait, g1(x) = x² + x + 1 corresponds to taps at positions 0,1,2. So, the encoded bit is data_in XOR shift_reg1 XOR shift_reg2.

g2(x) = x² + 1 corresponds to taps at positions 0 and 2, so encoded bit is data_in XOR shift_reg2.

Yes, that's correct.

But in the first step, when shift_reg1 and shift_reg2 are 0, encoded_bit1 is data_in, encoded_bit2 is data_in.

Then, shift_reg1 becomes data_in, shift_reg2 becomes 0.

In the next step, data_in is the next bit, shift_reg1 is the previous data_in, shift_reg2 is 0.

So, encoded_bit1 = data_in XOR data_in XOR 0 = 0
encoded_bit2 = data_in XOR 0 = data_in

Wait, but that's correct because for the second bit, the previous two bits are data_in and 0.

Hmm, perhaps the logic is correct.

But I'm a bit confused because the shift register is only two flip-flops, so it's holding the last two bits. So, for each new bit, the encoded bits are computed based on the current bit and the last two.

I think the code is correct. So, the final code is as above.


module convolutional_encoder (
     input wire clk,
     input wire rst,
     input wire data_in,
     output reg encoded_bit1,
     output reg encoded_bit2
 );
     reg shift_reg1, shift_reg2;
     reg encoded_bit1, encoded_bit2;

     always @posedge clk, !rst begin
         encoded_bit1 = data_in ^ shift_reg1 ^ shift_reg2;
         encoded_bit2 = data_in ^ shift_reg2;

         // Capture the current shift_reg1
         reg temp_shift_reg1 = shift_reg1;

         // Shift the shift register
         shift_reg1 = data_in;
         shift_reg2 = temp_shift_reg1;
     end
endmodule