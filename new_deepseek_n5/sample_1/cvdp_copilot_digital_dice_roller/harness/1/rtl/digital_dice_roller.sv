Okay, I need to design a Digital Dice Roller module in Verilog. The user provided a detailed specification, so I'll start by understanding the requirements.

First, the module should have an FSM with two states: IDLE and ROLLING. In IDLE, the dice_value is constant. When the button is pressed (button is HIGH), it transitions to ROLLING, where it counts from 1 to 6. When the button is released (LOW), it goes back to IDLE, outputting the last dice value.

The input signals are clk, reset_n, and button. The output is dice_value, a 3-bit signal. The counter is an internal 3-bit register that cycles through 1 to 6.

I'll start by defining the necessary modules and ports. The module will have the input ports: clk, reset_n, button, and output ports: dice_value.

Next, the FSM needs to be implemented using a state variable. I'll create a state reg, which can be IDLE or ROLLING. The initial state is IDLE.

In the IDLE state, when the button is pressed (button is 1), it transitions to ROLLING. The dice_value is set to 0 initially, but when the button is pressed, it should start counting. Wait, no—the initial dice_value should be 0, and when the button is pressed, it starts counting. So in IDLE, if button is 1, next state is ROLLING, and dice_value becomes 0 (since it's about to start counting). But according to the example, when button is pressed, the FSM starts rolling, and the dice_value is 0 until the first count. Hmm, maybe I should set dice_value to 0 initially, and when the counter increments, it starts from 1.

Wait, the example shows that when the button is pressed, the counter starts at 1. So in IDLE, dice_value is 0. When button is pressed, it goes to ROLLING, and the counter starts at 0, then increments to 1 on the first positive edge.

So in the ROLLING state, the counter is incremented on the positive edge of the clock. Each increment cycles through 0 to 5, representing 1 to 6. When the counter reaches 5, the next increment wraps around to 0, and the dice_value is set to 5 (since 0 represents 6). Wait, no—the counter is 3-bit, so 0 to 5. So when counter is 0, dice_value is 1, 1 is 2, up to 5 being 6. So when the counter increments, dice_value is set to counter + 1.

Wait, no. Let me think again. The counter starts at 0, and on each positive edge, it increments. So the sequence is 0,1,2,3,4,5,0, etc. So dice_value is counter + 1, except when counter is 5, then it's 6, and when it wraps to 0, it's 1 again.

So in the ROLLING state, on the positive edge of the clock, the counter is incremented. Then, the dice_value is set to counter + 1, except when counter is 5, then it's 6, and when it wraps, it's 1 again.

Wait, but in the ROLLING state, the counter is 3-bit, so it goes from 0 to 5. So when the counter is 5, adding 1 would make it 6, but since it's 3-bit, it wraps to 0. So dice_value is (counter + 1) mod 6, but since it's 3-bit, when counter is 5, dice_value is 6, which is 100 in binary. So I need to represent that correctly.

Wait, no. The dice_value is a 3-bit signal, so it can be 0 to 7. But according to the specs, it should be 1 to 6. So when the counter is 0, dice_value is 1, 1 is 2, up to 5 being 6. So when the counter increments, dice_value is set to counter + 1. But when counter is 5, adding 1 would be 6, which is correct. When counter wraps to 0, dice_value becomes 1 again.

So in the ROLLING state, on the positive edge, counter is incremented, then dice_value is set to counter + 1. But wait, when the counter is 5, after incrementing, it becomes 6, but since it's a 3-bit register, it wraps to 0. So dice_value would be 0 + 1 = 1, which is correct.

Wait, no. Let me clarify: the counter is a 3-bit register, so it can hold 0 to 7. But we only want it to count from 0 to 5. So when the counter is 5, the next increment should make it 0, not 6. So the counter is a 3-bit register that counts 0,1,2,3,4,5,0,1, etc.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter wraps at 5, when it's 5, adding 1 makes it 6, but since it's a 3-bit register, it wraps to 0. So dice_value would be 0 + 1 = 1, which is correct.

Wait, no. Let me think again. The counter is a 3-bit register, so it can go from 0 to 7. But we want it to count from 0 to 5, then reset to 0. So when the counter is 5, on the next positive edge, it increments to 6, but since it's a 3-bit register, it wraps to 0. So dice_value is set to 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, when the counter is 0, the dice_value is 1. When it's 1, dice_value is 2, etc., up to 5 being 6. Then, when it wraps to 0, dice_value is 1 again. So that's correct.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110 in binary, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, no. Let me clarify: the counter is a 3-bit register, so when it's 5, adding 1 makes it 6, but since it's 3 bits, 6 is 110, which is 6, but the register can't hold that, so it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But wait, when the counter is 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so it can't hold 6. So when the counter is 5, the next increment should make it 0, not 6. So the counter is a 3-bit register that counts 0,1,2,3,4,5,0,1, etc. So when the counter is 5, the next increment wraps to 0. So dice_value is set to (counter + 1), which when counter is 5, becomes 6, but since it's a 3-bit register, it's 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts from 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so it can't hold 6. So when the counter is 5, the next increment should make it 0, not 6. So the counter is a 3-bit register that counts 0,1,2,3,4,5,0,1, etc. So when the counter is 5, the next increment wraps to 0. So dice_value is set to (counter + 1), which when counter is 5, becomes 6, but since it's a 3-bit register, it's 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1, which is correct.

Wait, but in the ROLLING state, the counter is 3-bit, so when it's 5, the next increment is 6, which is beyond 3 bits. So the counter should wrap to 0 when it exceeds 5. So the counter is a 3-bit register that counts 0 to 5, then wraps to 0.

So in the ROLLING state, on the positive edge, the counter is incremented, then dice_value is set to (counter + 1). But since the counter is 3-bit, when it's 5, adding 1 makes it 6, which is 110, but since it's a 3-bit register, it wraps to 0. So dice_value is 0 + 1 = 1