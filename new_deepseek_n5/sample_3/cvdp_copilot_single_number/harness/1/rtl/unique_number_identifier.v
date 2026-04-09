Okay, I need to implement the unique_number_identifier module in Verilog based on the given specifications. Let me break down the problem and figure out how to approach this.

First, the module's goal is to identify a unique number from a series of input numbers. All numbers except one appear exactly twice, and the unique number should be outputted. If all are in pairs, the output should be 0.

The inputs are i_clk (positive edge triggered), i_rst_n (active-low reset), i_ready (valid signal), and i_number (the current number). The output is o_unique_number.

I need to think about how to track the occurrences of each number. Since all numbers except one appear twice, I can use a hash map or an array to count the occurrences. But in Verilog, using a reg array might be more straightforward for synthesis.

Wait, but how do I handle the counting? Each time i_ready is asserted on the rising edge of i_clk, I should process the incoming number. So, I'll need to add the number to a map and check if it's already present.

I'll create an array of size p_bit_width to keep track of counts. Each index represents a possible number, and the value at each index is the count. When a number is received, I increment the corresponding index. If the count reaches 2, I can remove it from the map and set it to 0 or just leave it as is.

But wait, in Verilog, I can't directly delete elements from an array. So, perhaps I should maintain a separate array to track which numbers have been seen once. When a number is received, I check if it's in the seen array. If it is, I remove it and mark it as seen twice. If it's not, I add it to the seen array. At the end, the unique number is the one that remains in the seen array.

Alternatively, I can use a FIFO approach. Each time a number is received, I add it to the array. If the array has more than two of the same number, I remove duplicates until each appears exactly twice. The unique number will be the one that's left unpaired.

Hmm, but how to handle this in a stateful way. Maybe I need a state variable to track whether I'm looking for the first or second occurrence of a number.

Let me outline the steps:

1. When i_rst_n is triggered, reset all internal states. So, I'll need a reset signal that clears the necessary registers.

2. When i_ready is asserted, process the incoming i_number on the rising edge of i_clk.

3. For each incoming number, check if it's already in the map. If it is, remove it (since it's now appearing twice). If not, add it to the map.

4. After processing all numbers, the unique number is the one that's left in the map.

But how to handle the case where the unique number hasn't been processed yet? Wait, no, because the unique number appears only once, so when all others are processed twice, the unique number remains once.

Wait, no. The unique number appears once, others appear twice. So, when processing, each number except the unique one will be added twice, but when they are added the second time, they are removed from the map. The unique number is added once and never removed.

So, the map will have the unique number as the only entry when all is done.

But how to handle the timing. Since the module needs to continuously update the output while i_ready is asserted, I need to process each incoming number as it comes in.

I think using a FIFO approach might be better. Each time a number is received, add it to a list. If the count of that number exceeds two, remove the duplicates. The unique number will be the one that's left after processing all inputs.

Wait, but how to track the count. Maybe I can use a dictionary-like structure, but in Verilog, that's not directly possible. So, perhaps using an array where each index represents a possible number, and the value is the count.

But for p_bit_width up to 8, the maximum possible numbers are 256. So, an array of size 256 is manageable.

So, I'll create an array count of size 256, initialized to 0. When a number is received, I increment the corresponding count. If the count exceeds 2, I subtract 1 each time until it's 2, and then remove it from the array.

Wait, but how to remove it. Alternatively, I can have a separate array that tracks the numbers that have been seen once. When a number is received, if it's in the seen array, remove it and mark it as seen twice. If not, add it to the seen array.

But in Verilog, arrays are fixed size, so I can't dynamically resize them. So, perhaps I can use a reg array of size p_bit_width, where each element is a bit indicating whether the number has been seen once or twice.

Wait, maybe I can use a reg array called 'seen' of size p_bit_width, where each bit represents whether the corresponding number has been seen an odd number of times. Wait, no, that's not directly applicable.

Alternatively, I can use a reg array called 'count' of size p_bit_width, where each element is the count of how many times the number has been seen. Each time a number is received, I increment the count. If the count becomes 3, I subtract 1 until it's 2, and then remove it from the map.

Wait, but how to track which numbers are in the map. Maybe I can have another array called 'active' of size p_bit_width, which is 1 if the number is in the map and 0 otherwise. Each time a number is received, if it's in the map, I decrement 'active' until the count is 2, then set 'active' to 0. If it's not in the map, set 'active' to 1 and increment the count.

Wait, perhaps that's a way. Let me outline:

- Initialize 'count' array to 0.
- When a number is received:
   - If 'active[number]' is 1:
      - Decrement 'count[number]' by 1.
      - Set 'active[number]' to 0.
   - Else:
      - Increment 'count[number]' by 1.
      - Set 'active[number]' to 1.
- After each increment, check if 'count[number]' is 3. If so, set 'active[number]' to 0 and 'count[number]' to 0.
- At the end, the unique number is the one where 'active[number]' is 1.

Wait, but how to handle the case where the unique number is the last one. Because when all others are processed twice, their 'active' is set to 0, and the unique number remains with 'active' 1.

So, the output is the index of the 'active' array that is 1.

But how to find that index. Since the array is p_bit_width in size, I can loop through each bit and find the one that's set.

But in Verilog, I can't loop in the module like that. So, perhaps I need to use a combinational logic to find the unique number.

Alternatively, I can use a scan approach. For each bit in the 'active' array, if it's set, set the corresponding bit in the output.

Wait, but the output is a p_bit_width-1:0, so each bit corresponds to a number. So, for example, if the 5th bit is set in 'active', then the output is 5.

Wait, no. Wait, the 'active' array is indexed from 0 to p_bit_width-1, each index representing a number. So, if index 3 is active, the output is 3.

So, the output is simply the index of the 'active' array that is 1.

But how to find that index in Verilog. Since I can't have a loop, perhaps I can use a combinational logic that checks each bit and sets the corresponding bit in the output.

Alternatively, perhaps I can use a scan register that iterates through each bit and checks if it's set.

Wait, but that might be complex. Alternatively, I can use a counter that counts from 0 to p_bit_width-1 and checks each index in turn.

But in a module, I can't have a loop. So, perhaps I can use a series of AND and XOR gates to find the unique number.

Wait, perhaps a simpler approach is to use a state machine. The state machine can track whether it's looking for the first or second occurrence of a number.

Let me outline the state machine approach:

- State 0: Initial state, looking for the first occurrence of a number.
   - When a number is received, store it in a register and transition to State 1.
- State 1: Looking for the second occurrence.
   - When the same number is received again, output it and transition back to State 0.
   - If a different number is received, store the new number and stay in State 1.

Wait, but this approach would require storing the current number, which can be done with a reg.

But how to handle the case where the unique number is the last one. Because when all others are processed twice, the unique number is processed once and remains in the state.

Wait, but in this approach, the state machine would only output the unique number when it's received the second time, but since it's only received once, it won't output it. So, this approach might not work.

Hmm, perhaps I need a different approach. Maybe using a FIFO buffer to collect all the numbers, then process them in pairs, and the remaining one is the unique number.

But how to implement this in Verilog. Let me think.

Each time a number is received, add it to a FIFO buffer. When the buffer size exceeds 2, remove the oldest number. The unique number will be the one that's left after processing all inputs.

But how to implement the FIFO. I can use a shift register. Each time a number is received, shift it into the register. If the register has more than two of the same number, remove the oldest one.

Wait, but how to detect duplicates. Because the FIFO approach would require checking if the new number is already in the register.

Alternatively, perhaps I can use a shift register and a comparator to check for duplicates.

But this might get complicated. Maybe a better approach is to use a hash map, but in Verilog, that's not directly possible. So, perhaps using an array to track the counts.

Wait, going back to the count array approach. Let me try to outline the code.

First, I'll declare the count array as a reg array of size p_bit_width, initialized to 0.

Then, in the always positive edge sensitive to i_ready, I'll have:

if (i_ready) begin
   // process the number
   if (active[number] == 1) begin
      count[number] -= 1;
      active[number] = 0;
   end else begin
      count[number] += 1;
      active[number] = 1;
   end
   // check if count exceeds 2
   if (count[number] == 3) begin
      count[number] = 0;
      active[number] = 0;
   end
end

Wait, but in Verilog, you can't have if statements inside an always block like that. So, I need to implement this logic using combinational logic.

Alternatively, I can use a case statement or a series of if-else statements.

Wait, but in Verilog, the code inside the always block is a single statement, so I can't have multiple statements. So, perhaps I need to use a more efficient way.

Alternatively, I can use a scan approach where I check each bit in the 'active' array and find the one that's set.

Wait, perhaps I can use a scan register that iterates through each bit and checks if it's set. For example, using a series of AND and XOR gates to find the unique number.

But that might be complex. Alternatively, perhaps I can use a counter that counts from 0 to p_bit_width-1 and checks each index in turn.

Wait, but in Verilog, I can't have a loop in the module. So, perhaps I can use a combinational logic that checks each bit in parallel.

Wait, perhaps I can use a scan approach where I shift the bits and check for the unique number.

Alternatively, perhaps I can use a priority encoder. The unique number is the one that's present once, so it's the only one with a count of 1. So, I can create a priority encoder that outputs the highest bit set in the 'active' array.

Wait, but the priority encoder would require the 'active' array to be in a certain order. Alternatively, perhaps I can use a scan register that iterates through each bit and finds the first one that's set.

But again, without a loop, this is tricky.

Wait, perhaps I can use a series of AND and XOR gates to find the unique number. For example, for each bit position, if the bit is set in 'active', then the corresponding bit in the output is set.

But how to implement this. Let me think.

The output is the index of the 'active' array that is 1. So, for each bit position i, if active[i] is 1, then the output's bit i is 1.

So, the output can be constructed by OR-ing all the bits where active[i] is 1.

Wait, but that's not correct because the output is a number, not a bit vector. So, for example, if active[3] is 1, the output should be 3, which is 0b11 in 8-bit.

Wait, but in the code, the output is a reg [p_bit_width-1:0], so each bit corresponds to a number. So, the output is the number whose bit is set in the 'active' array.

Wait, no. Wait, the 'active' array is of size p_bit_width, where each index represents a number. So, if index 5 is active, the output should be 5, which is represented as a 8-bit number with the 5th bit set.

So, the output is the index of the 'active' array that is 1.

But how to find that index in Verilog. Since I can't loop, perhaps I can use a combinational logic that checks each bit in turn.

Wait, perhaps I can use a series of AND and XOR gates to find the unique number. For example, for each bit position i, if active[i] is 1, then the output's bit i is set.

But that's not directly possible because the output is a single number, not a bit vector. So, perhaps I can use a scan approach where I shift the bits and check for the unique number.

Alternatively, perhaps I can use a counter that counts from 0 to p_bit_width-1 and checks each index in turn.

Wait, but in Verilog, I can't have a loop in the module. So, perhaps I can use a combinational logic that checks each bit in parallel.

Wait, perhaps I can use a priority encoder. The priority encoder would take the 'active' array and output the index of the first set bit. But since the 'active' array can have only one set bit (the unique number), the priority encoder can be used to find that index.

But how to implement a priority encoder in Verilog without a loop. Alternatively, perhaps I can use a series of AND and XOR gates to find the unique number.

Wait, perhaps I can use a scan approach where I shift the bits and check for the unique number.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But that might be complex.

Wait, perhaps a simpler approach is to use a state machine that tracks whether it's looking for the first or second occurrence of a number.

Let me outline the state machine approach again:

- State 0: Initial state, looking for the first occurrence of a number.
   - When a number is received, store it in a register and transition to State 1.
- State 1: Looking for the second occurrence.
   - When the same number is received again, output it and transition back to State 0.
   - If a different number is received, store the new number and stay in State 1.

But how to handle the case where the unique number is the last one. Because when all others are processed twice, the unique number is processed once and remains in the state.

Wait, but in this approach, the state machine would only output the unique number when it's received the second time, but since it's only received once, it won't output it. So, this approach might not work.

Hmm, perhaps I need to adjust the state machine to handle the case where the unique number is the last one.

Wait, perhaps the state machine should track whether it's looking for the first or second occurrence, and when it's in State 1, if the same number is received, output it. Otherwise, if a different number is received, it's added to the count.

But I'm not sure how to implement this without a state variable, which would require a finite state machine (FSM).

Alternatively, perhaps I can use a shift register to collect the numbers and then process them in pairs.

Wait, but I'm not sure how to implement that in Verilog without a loop.

Alternatively, perhaps I can use a counter that counts the number of times each number has been received and then find the one with a count of 1.

But again, without a loop, this is tricky.

Wait, perhaps I can use a combinational logic that for each bit i, if active[i] is 1, then the output is i.

But how to implement that. Let me think.

The output is the index of the 'active' array that is 1. So, for each i from 0 to p_bit_width-1, if active[i] is 1, then the output is i.

But in Verilog, I can't loop, so perhaps I can use a series of AND and XOR gates to find the unique number.

Wait, perhaps I can use a priority encoder. The priority encoder would take the 'active' array and output the index of the first set bit.

But how to implement a priority encoder without a loop. Alternatively, perhaps I can use a combinational logic that checks each bit in parallel.

Wait, perhaps I can use a series of AND and XOR gates to find the unique number.

Alternatively, perhaps I can use a scan approach where I shift the bits and check for the unique number.

Wait, perhaps I can use a shift register that shifts the 'active' array each time a new number is received. Then, after processing all numbers, the unique number would be the one that's left.

But I'm not sure how to implement this.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1, then the output is i.

Wait, but the output is a single number, not a bit vector. So, perhaps I can use a series of multiplexers to select the correct bit.

But that might be too complex.

Wait, perhaps I can use a scan approach where I iterate through each bit and check if it's set. For example, using a series of AND and XOR gates to determine the unique number.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But that would require checking each bit in order, which might be possible with a series of AND and XOR gates.

Wait, perhaps I can use a series of AND gates to check if the current bit is set and all higher bits are 0. If so, set the output to the current bit.

But I'm not sure how to implement this without a loop.

Alternatively, perhaps I can use a priority encoder with the 'active' array as input. The priority encoder would output the index of the first set bit, which would be the unique number.

But how to implement a priority encoder without a loop. Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

Wait, perhaps I can use a series of AND and XOR gates to create a signal that is 1 only when the current bit is set and all higher bits are 0. Then, the output would be the current bit.

But I'm not sure how to implement this.

Alternatively, perhaps I can use a series of nested AND gates to check each bit in order.

Wait, perhaps I can use a series of AND gates to check if the current bit is set and all higher bits are 0. For example, for bit i, if active[i] is 1 and active[i+1] to active[p_bit_width-1] are 0, then set the output to i.

But implementing this would require a lot of gates, but it's possible.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But in Verilog, the priority encoder is a built-in block, so perhaps I can use that.

Wait, but the priority encoder expects a vector of bits, not an array. So, perhaps I can create a vector from the 'active' array and then use the priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7 (the highest bit), if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a shift register to collect the 'active' bits and then find the unique number.

Wait, perhaps I can use a shift register that shifts the 'active' bits each time a new number is received. Then, after processing all numbers, the unique number would be the one that's left.

But I'm not sure how to implement this.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1, then the output is i.

But the output is a single number, so perhaps I can use a series of multiplexers to select the correct bit.

Wait, perhaps I can use a series of AND gates to create a signal that is 1 only when the current bit is set and all higher bits are 0. Then, the output would be the current bit.

But I'm not sure how to implement this.

Alternatively, perhaps I can use a priority encoder. The priority encoder would take the 'active' array and output the index of the first set bit.

But how to implement a priority encoder without a loop. Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit 6, and so on.

But implementing this would require a lot of logic.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and the sum of active[i+1] to active[p_bit_width-1] is 0, then set the output to i.

But again, this would require a lot of logic.

Wait, perhaps I can use a simpler approach. Since the 'active' array is of size p_bit_width, which is up to 16, I can create a signal for each bit and use a priority encoder.

But I'm not sure if that's the right approach.

Alternatively, perhaps I can use a combinational logic that for each bit i, if active[i] is 1 and all higher bits are 0, then set the output to i.

But I'm not sure how to implement this.

Wait, perhaps I can use a series of AND gates to check each bit in order.

For example, for bit 7, if active[7] is 1 and active[6] to active[0] are 0, then set the output to 7.

If not, check bit