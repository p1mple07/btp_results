<think>We are Phi. The request: "Provide me one answer for this request: Design a System Verilog module that performs division using the restoring division algorithm. The restoring division algorithm is a method used for binary division in computer architecture. It involves repeatedly subtracting the divisor from the dividend and restoring the partial remainder if the result is negative. The module efficiently handles division between two unsigned integers (dividend and divisor) and provides outputs for both quotient and remainder. The design supports varying input widths specified by the WIDTH parameter." We are given interface and details. We are asked to "return the file name in the correct place at the folder structure", but then said "Return the file name in the correct place at the folder structure". But instructions: "Provide me one answer for this request: ..." The answer should be plain text with the file name "rtl/restore_division.sv". But the user said: "Your response will be saved directly to: rtl/restore_division.sv". So our answer should be plain text, no JSON formatting, and include the file path "rtl/restore_division.sv" as the file name. So we need to produce a SystemVerilog module that implements the restoring division algorithm.

Let's check the specifications:

- Parameter: WIDTH, default value = 6. But then in the provided example, WIDTH = 3. So we must support parameter WIDTH.

- Inputs: clk, rst (active low asynchronous reset), start, dividend, divisor. Both dividend and divisor are WIDTH bits wide.

- Outputs: quotient (WIDTH bits), remainder (WIDTH bits), valid (active-high indicating completion).

- Behavior: The module processes a new pair of dividend and divisor inputs in each division cycle, and new inputs can be supplied only when previous outputs have been provided (valid high for one cycle). The algorithm: restoring division algorithm.

- The algorithm: division process: initialization: register dividend internally, remainder = 0.

- For each iteration (for WIDTH iterations if WIDTH is power of 2, else WIDTH+1 iterations), do: shift remainder left by one bit, append MSB of dividend. Then subtract divisor from remainder. If subtraction result's MSB is 0 (i.e. non-negative) then quotient bit for this iteration is 1, and remainder becomes result. If subtraction result's MSB is 1 (i.e. negative) then quotient bit for this iteration is 0, and remainder is restored (i.e. the original remainder from before subtraction). However, in typical restoring division algorithm, the quotient is built from the MSB to LSB, but then the remainder is updated if the subtraction is non-negative. But the problem states: "At each iteration, the remainder is shifted left by one bit, and the next MSB of the dividend is appended to the remainder. Then subtract divisor from remainder. If the subtraction result is positive (MSB 0), set quotient bit to 1 and update remainder; if negative (MSB 1) then quotient bit = 0 and restore remainder." Wait, but careful: "restoring division algorithm" is typically executed for each bit of the dividend, so we have WIDTH iterations. But the description said: "the division process must finish within WIDTH clock cycles if WIDTH is a power of 2 (2^n) to ensuring all data is processed; otherwise (if WIDTH is not a power of 2), it will take WIDTH+1 clock cycles." That is interesting: The algorithm uses one extra iteration if width is not a power of 2. But note that the classical restoring division algorithm always runs for N iterations, where N is the number of bits of the dividend. But here they specify: "if WIDTH is a power of 2, then exactly WIDTH cycles; if not, then WIDTH+1 cycles." I'm not entirely sure why that is. Possibly because the algorithm uses an extra iteration for aligning the divisor with the dividend? But the text says "the division process must finish within WIDTH clock cycles if WIDTH is a power of 2 (2^n) to ensuring all data is processed; otherwise (if WIDTH is not a power of 2), it will take WIDTH+1 clock cycles." This is a bit unusual: usually you'd have the same number of iterations regardless. But anyway, we must implement that: So we need a counter that runs from 0 to (WIDTH + extra) iterations. Possibly a parameter "NUM_ITER" that equals WIDTH if (WIDTH is a power of 2) else WIDTH+1. But how to check if WIDTH is a power of 2 in SystemVerilog? Possibly we can use a parameter expression that computes something like: `parameter NUM_ITER = (WIDTH == (1 << $clog2(WIDTH))) ? WIDTH : WIDTH + 1;` But $clog2 is not synthesizable in all cases. But we assume it is acceptable. Alternatively, we can define a parameter "NUM_ITER" manually? But the specification explicitly says that. I'll assume using $clog2 is acceptable.

But then, the division algorithm: It works as follows:

Initialize: quotient = 0, remainder = 0, and maybe a shift register for dividend bits? But instructions say: "At the start, dividend is registered internally, remainder is 0." So we need internal registers for dividend, remainder, quotient.

Algorithm: For each iteration, do:
- If not the first iteration: shift remainder left by one bit, then OR with next bit from dividend. But careful: The description "Shift remainder left by one bit, and append the next MSB of dividend" means: remainder = {remainder, dividend_bit}. But wait, the dividend is an input register. But we need to use its MSB in each iteration, but then move to next bit? So we need a register that holds the dividend bits, and then shift it right each iteration. But then the algorithm described: "Shift remainder left by one bit and append the next MSB of dividend." This is like the restoring division algorithm: At each step, you take the current remainder, shift left, then bring down the next bit of dividend. But wait, which order? Typically, restoring division algorithm is described as: For i = 0 to n-1, do: remainder = remainder << 1; remainder[0] = dividend[n-i-1]. Then subtract divisor from remainder. Then if remainder >= 0 then quotient bit = 1, else quotient bit = 0 and restore remainder.

But here, the description says: "Shift remainder left by one bit, append the next MSB of dividend." But careful: The example: WIDTH = 3, dividend = 7 (111). In iteration 1: remainder = 0 initially, then shift left (0) and append MSB (which is 1) gives remainder = 001 (binary)? Wait, how to get 001? Let's simulate the example:
Iteration 1: dividend = 111. Remainder = 000. Then "Shift remainder left by one bit, append MSB of dividend (1)" yields remainder = 001. Then subtract divisor (101) gives result = 001 - 101 = ??? Wait, 1 - 5 = -4 in decimal, which is negative. So quotient bit = 0. But then, because negative, we restore remainder to original remainder (which was 000) and then quotient bit becomes 0.
Iteration 2: Now remainder = 000, then shift left and append next dividend bit. But what is next dividend bit? The MSB of dividend is already used. But the description says "append next MSB of dividend" but in iteration 1, we appended the leftmost bit. But the example says: "Iteration 2: Shift remainder left, append next dividend bit (1): remainder becomes 0011." Wait, but if remainder was 000, shifting left gives 000 and appending next dividend bit (which is the next leftmost bit, which is the middle bit of 111) gives 010? But the example says 0011. Let me re-read the example:
Example:
Dividend = 3'd7 = 111, divisor = 3'd5 = 101.
Iteration 1:
- Remainder = 000 initially.
- Append MSB of dividend (1) after shifting: remainder = 001.
- Subtract divisor: 001 - 101 = negative.
- So quotient bit = 0.
Iteration 2:
- "Shift remainder left, append next dividend bit (1): remainder = 0011."
- Subtract divisor: 0011 - 101 = negative.
- Quotient bit = 0.
Iteration 3:
- "Shift remainder left, append final dividend bit (1): remainder = 0111."
- Subtract divisor: 0111 - 101 = positive.
- Remainder becomes 0010.
- Quotient bit = 1.
Final quotient = 001 (binary) and remainder = 010 (binary). That doesn't match the usual restoring division algorithm because quotient is 001, which is 1, but 7/5 equals 1 remainder 2. So it's correct.

So the algorithm is: For each iteration, we use a new bit from the dividend, in order from MSB to LSB. But then the algorithm says: "shift remainder left, append next MSB of dividend." That is ambiguous: In iteration 1, remainder was 000, then appended MSB (which is the leftmost bit of dividend) gives 0*2 + 1 = 1. In iteration 2, remainder is restored to 000 because the subtraction was negative in iteration 1, then we shift left and append the next bit (which is the second MSB, which is 1) gives 0*2 + 1 = 1, but then how do we get 0011? Possibly the algorithm is: We have a shift register that holds the dividend bits? Let's re-read the description carefully:

"Shift and Subtract:
1. At each iteration, the remainder is shifted left by one bit, and the next MSB of the dividend is appended to the remainder.
2. The divisor is subtracted from the remainder to check if it can fit.
   - If the most significant bit (MSB) of the subtraction result is 0, the quotient bit for this step is set to 1, and the result of the subtraction is kept as the new remainder.
   - If the most significant bit (MSB) of the subtraction result is 1, the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit."

Wait, "append the next MSB of the dividend" might be interpreted as: take the current dividend and shift it right by one, and then use that bit to fill the LSB of the remainder after shifting left. But then in iteration 1, dividend = 111. Shift right by 1 gives 011, so the MSB of the shifted dividend is 0? That doesn't match. Alternatively, maybe we maintain a register "dividend_reg" that is shifted right each iteration, and at each iteration, we do: remainder = {remainder, dividend_reg[WIDTH-1]}. And then shift dividend_reg right by 1. That is a typical approach.

But the example: iteration 1: dividend_reg initially = 111. Then remainder = {0, 1} = 001. Then dividend_reg = 011. Iteration 2: remainder = {000, 1} = 001, but then dividend_reg becomes 001. But the example says remainder becomes 0011 in iteration 2, which is 3 bits? Actually, let's simulate: In iteration 1, remainder becomes 1 (which is represented as 001 in 3 bits). Then in iteration 2, we do: shift remainder left, then append next bit from dividend. But if we had dividend_reg = 011, then the MSB of dividend_reg is 0. But the example says the appended bit is 1. So that doesn't match.

Maybe the order of iteration is reversed: Instead of shifting dividend right, we shift remainder left and then OR with the dividend bit from the leftmost bit. But then after iteration 1, we need to remove that bit from the dividend? But the specification says "append the next MSB of the dividend" which implies that we always take the next most significant bit, not the MSB of the remaining dividend. That means the dividend is fixed, and we iterate over its bits in order from MSB to LSB. But then in iteration 1, we take the first bit (which is 1 for 111), iteration 2, take the second bit (which is also 1), iteration 3, take the third bit (1). But then how do we get remainder = 0011 in iteration 2? Because if we just do remainder = {remainder, next_bit}, then iteration 1: remainder = {0, 1} = 1, iteration 2: remainder = {1, 1} = 3 (binary 11), iteration 3: remainder = {3, 1} = 7 (binary 111). Then subtract divisor from remainder in iteration 3: 7 - 5 = 2, which gives quotient bit 1. That would yield quotient = 001 (if we build quotient bits in order from iteration 1 to iteration 3). That matches the example. But then iteration 1: remainder becomes 1, subtract divisor: 1 - 5 = negative, so quotient bit 0 and remainder restored to 0. Iteration 2: remainder becomes {0, 1} = 1, but then shift left of previous remainder? Wait, but if we always use the dividend bits in order, we don't shift dividend register. But then the algorithm described "shift remainder left by one bit" means that remainder is left shifted by one, then the next dividend bit is appended as LSB. But then if we do that repeatedly, the remainder becomes a concatenation of all the dividend bits that were appended. That is exactly what happened: iteration 1: remainder = (0 << 1) | (dividend[WIDTH-1]) = (0) | 1 = 1, iteration 2: remainder = (1 << 1) | (dividend[WIDTH-2]) = (2) | 1 = 3, iteration 3: remainder = (3 << 1) | (dividend[WIDTH-3]) = (6) | 1 = 7. And then subtract divisor: 7 - 5 = 2, quotient bit becomes 1. So quotient bits, if we store them in a shift register, would be: iteration 1: quotient bit = 0, iteration 2: quotient bit = 0, iteration 3: quotient bit = 1, so final quotient = 001, remainder = 2. That is exactly the example. So that is the algorithm.

So implementation: We need a state machine that goes through the iterations. The number of iterations is determined by the parameter. We'll define a parameter NUM_ITER = (WIDTH == (1 << $clog2(WIDTH))) ? WIDTH : WIDTH+1; But check: if WIDTH is a power of 2 then NUM_ITER = WIDTH else NUM_ITER = WIDTH+1.

We also need to consider that the module processes one division cycle at a time. It has a start signal. When start is high and valid is low, then new inputs are accepted. Then, on each clock cycle, perform one iteration of the algorithm. After NUM_ITER cycles, valid becomes high for one cycle to indicate that the division result is ready. Then, the outputs are available (quotient and remainder). And then the module is ready for a new cycle when valid goes high for one cycle.

We need registers: dividend_reg, remainder_reg, quotient_reg. We also need a counter to count iterations.

Algorithm steps per iteration:
- At beginning of each iteration, if it's not the first iteration, then shift remainder left by one bit and then OR with the next dividend bit. But wait, careful: The algorithm says "shift remainder left by one bit and append the next MSB of the dividend" but then subtract divisor. But if it's the first iteration, remainder is 0. But then what is the dividend bit to append? Possibly for iteration 1, remainder becomes {0, dividend[WIDTH-1]}. For iteration 2, remainder becomes {remainder, dividend[WIDTH-2]}, etc. So essentially, at each iteration i (starting at 0), the bit to append is dividend[WIDTH - 1 - i]. But then quotient bit is computed as: temp = remainder - divisor. If (temp[WIDTH-1] == 0) then quotient bit = 1 and new remainder = temp, else quotient bit = 0 and new remainder = remainder (unchanged). But wait, check iteration 1: i=0, remainder = {0, dividend[WIDTH-1]} = {0, 1} = 1, then temp = 1 - 5 = -4. In binary, -4 in 3-bit two's complement representation is 011? Actually, 3-bit two's complement representation: 1 is 001, 5 is 101, so subtraction: 001 - 101 = 110 (which is negative, since MSB is 1). So quotient bit becomes 0 and remainder remains 0. So iteration 1: quotient bit = 0.
Iteration 2: i=1, remainder = {0, dividend[WIDTH-2]} = {0, 1} = 1, then temp = 1 - 5 = -4, so quotient bit = 0.
Iteration 3: i=2, remainder = {0, dividend[WIDTH-3]} = {0, 1} = 1, then temp = 1 - 5 = -4? That doesn't match the example. Wait, let me simulate properly:

We need to simulate restoring division algorithm correctly. Let's recall the standard algorithm for restoring division:
Given dividend D and divisor d, assume D is n-bit and d is n-bit.
Initialize: A = 0, Q = D.
For i = 0 to n-1:
   A = A << 1 | Q[n-1] (the MSB of Q)
   Subtract: A = A - d.
   If A >= 0 then Q[i] = 1, else Q[i] = 0 and restore A by adding d back? But that's the non-restoring division algorithm. Wait, let me recall the restoring division algorithm properly.

Actually, the restoring division algorithm (also known as the repeated subtraction algorithm) works as follows:
Let A be the accumulator (initially 0) and Q be the quotient register (initially dividend). Then for i from 0 to n-1:
   A = A << 1 | Q[n-1] (i.e. shift left and bring down the next bit from Q)
   A = A - d.
   If A >= 0 then Q[i] = 1, else Q[i] = 0 and A = A + d (restoring A).
After the loop, A is the remainder, and Q is the quotient (but in reverse order maybe). However, the description here is slightly different. They say: "if the subtraction result is negative, then the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit." Wait, "discarding the quotient bit" might mean that if the subtraction is negative, then the quotient bit is 0 and we do not update the remainder.

However, the example does not match the standard restoring division algorithm either. Let me re-read the example carefully:
Dividend = 7 (111), divisor = 5 (101).
Iteration 1:
   Remainder = 000 initially.
   Append MSB of dividend: that is the leftmost bit (1) to get remainder = 001.
   Subtract divisor: 001 - 101 = negative.
   So quotient bit = 0, and remainder is restored (i.e., remains 000).
Iteration 2:
   Remainder = 000.
   Append next dividend bit: which is the second bit (1) to get remainder = 001 (or maybe 001? But example says remainder becomes 0011, which is 3 decimal, but 001 in 3 bits is 1 decimal. Wait, 0011 in binary is 3 decimal, but they show 4 bits "0011". Possibly they are showing the intermediate value with an extra bit? The example says: "Iteration 2: Shift remainder left, append next dividend bit (1): remainder = 0011." That suggests that remainder is now 4 bits wide, not 3 bits. But our parameter WIDTH is 3. So maybe the algorithm uses a register wider than WIDTH to accumulate the remainder? Possibly the remainder register is WIDTH+1 bits wide? Let's check: In iteration 3, they get remainder = 0111, then subtract divisor (101) gives remainder = 0010. So remainder is 4 bits wide. So maybe the remainder register should be WIDTH+1 bits wide. That is common in division algorithms because the remainder can be as high as the dividend. But then quotient is WIDTH bits wide. So we need to define: parameter REM_WIDTH = WIDTH + 1. So remainder_reg should be WIDTH+1 bits.

Now, algorithm with REM_WIDTH:
Initialize: quotient_reg = 0 (WIDTH bits), remainder_reg = 0 (WIDTH+1 bits).
For each iteration i from 0 to (NUM_ITER - 1):
   remainder_reg = {remainder_reg[WIDTH:0], next_dividend_bit} where next_dividend_bit = dividend[WIDTH-1 - i] if we count from MSB to LSB.
   Then compute temp = remainder_reg - divisor_reg (but divisor_reg is WIDTH bits, but we need to sign extend divisor to REM_WIDTH bits? But since these are unsigned numbers, subtraction is unsigned arithmetic? But then negative result detection: if temp[REM_WIDTH-1] == 1, then subtraction result is negative. But in unsigned arithmetic, subtraction with borrow will produce a value that is less than divisor if it's negative. But we want to detect negative by checking if the MSB of the subtraction result is 1. But since these are unsigned numbers, the MSB is the sign bit in two's complement representation? But wait, we are dealing with unsigned integers. However, if we subtract and get a result that is less than 0 in unsigned arithmetic, then the MSB will be 1 because of borrow. So we can check if temp[REM_WIDTH-1] is 1 to decide if subtraction result is negative. But then if negative, we set quotient bit = 0 and restore remainder_reg to the previous value (which is remainder_reg before appending the dividend bit). But note that we already shifted and appended the dividend bit. So if subtraction is negative, we need to undo the shift and append? But the description says: "and the original remainder is restored by discarding the quotient bit." That might mean that we do not update quotient bit and we simply discard the appended bit. But then the quotient bit for that iteration becomes 0. But the remainder remains what it was before shifting? But then we lose the dividend bit that we appended. But that is the restoring division algorithm: if subtraction fails, then you subtract nothing and the quotient bit is 0, and then you restore the remainder to what it was before the subtraction attempt, and then shift left and bring down the next bit in the next iteration. However, in the standard restoring division algorithm, you do: 
   A = A << 1 | Q[n-1];
   A = A - d;
   if (A < 0) then Q[i] = 0, else Q[i] = 1.
   if (A < 0) then A = A + d (restoring).
But note that A is updated to A - d, but if negative then restore A by adding d. But that doesn't undo the shift? Actually, in restoring division, the algorithm is: 
   A = 0; Q = dividend;
   for i in 0 to n-1:
      A = A << 1 | Q[n-1];
      A = A - d;
      if (A < 0) then Q[i] = 0 and A = A + d, else Q[i] = 1.
   remainder = A, quotient = Q.
But in our algorithm, they said "if negative, then restore the original remainder by discarding the quotient bit." That implies that if subtraction is negative, then we do not update quotient with 1, and we restore remainder to its previous value (i.e., before the shift and append). But then what about the quotient bit? We need to shift quotient register left and then OR with the result of the subtraction test. But in standard restoring division, the quotient bit is stored in Q. So we need a register for quotient bits. We can build quotient bits in a shift register, where in each iteration, we shift left and then add the computed quotient bit in LSB. But then the final quotient is the shift register after NUM_ITER iterations, but note that the quotient bits are generated in order from MSB to LSB. So if we do a left shift and then OR with bit, then the bit computed in iteration i becomes the i-th bit from the left? But if we shift left, then the new bit is appended on the right. But then the final quotient register would be reversed. Alternatively, we can build quotient bits in a separate register and shift them right, or build them in parallel. The typical restoring division algorithm: 
   A = 0; Q = dividend; 
   for i=0 to n-1:
       A = A << 1 | Q[n-1];
       A = A - d;
       if (A < 0) then Q[i] = 0 and A = A + d; else Q[i] = 1.
   remainder = A; quotient = Q.
But then Q is assembled from the bits that were computed in each iteration, but the bit computed in iteration i goes to Q[i] (LSB is iteration 0, MSB is iteration n-1). But the description says "the quotient bit for this step is set to 1" etc. It doesn't specify the order but the final quotient is in the same order as the dividend bits? Usually quotient LSB corresponds to the first iteration. But the example: final quotient = 001, which means that the least significant bit is 1, and the other bits are 0. That corresponds to iteration 3 being 1, iteration 1 and 2 being 0. So indeed, the quotient LSB corresponds to the last iteration. So we can compute quotient bits in a shift register that shifts right, or we can store them in an array and then reverse at the end. But simpler is to compute quotient bits in a register that is shifted right each cycle, and then OR the new quotient bit into the MSB? Alternatively, we can build the quotient bits from MSB to LSB. But given that the algorithm processes iterations from first to last, the last iteration's quotient bit is the LSB of the quotient. So we want to accumulate quotient bits in a register that is shifted right each iteration, with the new quotient bit going into the MSB position. But then after all iterations, the quotient register will have the quotient in the correct order. Let's plan that:

We have a counter "iter" that goes from 0 to NUM_ITER - 1.
We have registers: dividend_reg (WIDTH bits), divisor_reg (WIDTH bits). But we only need to store the dividend bits maybe in a register that holds the dividend bits to be used for each iteration? But the algorithm says "append the next MSB of the dividend" and the dividend input is provided. But then, do we use the input dividend directly each iteration? But then the input dividend remains constant. But the algorithm expects the dividend bits to be used in order. But then the input dividend is not shifted, but we need to know which bit to use in each iteration. We can compute the bit index as (NUM_ITER - 1 - iter) if NUM_ITER equals the number of iterations. But note that if WIDTH is a power of 2, then NUM_ITER = WIDTH, and we use dividend[WIDTH-1:0] bits in order from MSB to LSB. If not, then NUM_ITER = WIDTH+1, and then we use dividend[WIDTH-1:0] bits? But then there is one extra iteration. Possibly the extra iteration is used to align the divisor with the dividend? In some division algorithms, you left shift the divisor until it is just less than or equal to the dividend, and then perform the algorithm. But the specification doesn't mention shifting the divisor. It just says that if WIDTH is not a power of 2, then it will take WIDTH+1 iterations. That is odd.

Alternatively, we might treat the dividend as having an extra MSB of 0 appended. That is common in division algorithms: sometimes you augment the dividend with an extra bit to ensure that the divisor fits. For example, if dividend is n bits, then you consider it as n+1 bits with a leading 0. That is the restoring division algorithm with an extra iteration. Yes, that is common: For unsigned division, you sometimes consider the dividend as n+1 bits with an extra 0 at the MSB, so that the division algorithm produces the correct quotient and remainder. That is likely what they mean by "if WIDTH is not a power of 2, then it will take WIDTH+1 clock cycles." So in that case, the dividend should be considered as WIDTH+1 bits, where the MSB (bit WIDTH) is 0. So then in each iteration, we use dividend_reg[WIDTH:0] where dividend_reg is WIDTH+1 bits, with dividend_reg[WIDTH] = 0 and dividend_reg[WIDTH-1:0] = input dividend. That makes sense.

So, we define a parameter REM_WIDTH = WIDTH + 1.
We define a register dividend_reg of width REM_WIDTH, which is set on start: dividend_reg[WIDTH] = 0, dividend_reg[WIDTH-1:0] = dividend.
Then, in each iteration i, we take the MSB of dividend_reg, which is dividend_reg[REM_WIDTH-1]. Then we shift dividend_reg left by 1 (and then the new MSB becomes 0 automatically). But careful: if we shift dividend_reg left, then the dividend bit that was used is lost. But we want to use that bit in the remainder update. So the typical algorithm is: 
   remainder_reg = {remainder_reg[REM_WIDTH-1:0], dividend_reg[REM_WIDTH-1]}; but that would put the used bit as LSB. But then we want to subtract divisor from remainder_reg.
   But then if subtraction is negative, then we restore remainder_reg to its previous value (i.e., without the appended bit) and quotient bit = 0. If subtraction is non-negative, then remainder_reg becomes the subtraction result and quotient bit = 1.
   But then we also update dividend_reg by shifting left.
   Also, update quotient_reg by shifting left and adding the computed quotient bit in the LSB.
   And then if it's the last iteration, output quotient_reg and remainder_reg (remainder_reg is the remainder, quotient_reg is the quotient, but note quotient_reg is built in reverse order? Let's check with example:
   Let WIDTH = 3, so REM_WIDTH = 4.
   Initially, dividend_reg = 0 111 (MSB 0, then 111) and remainder_reg = 0000.
   Iteration 0:
       dividend_reg = 0 111, take MSB = 0.
       remainder_reg becomes {remainder_reg[3:0], 0} = {0000, 0} = 0000.
       Compute temp = remainder_reg - divisor. Divisor is 101 (but need to extend to 4 bits: 0101).
       0000 - 0101 = 1011 (in unsigned arithmetic, 0 - 5 = 11 decimal with borrow? Actually, in 4-bit, 0000 - 0101 = 1011 which in binary is 11 decimal, but the MSB is 1, so negative).
       So quotient bit = 0.
       Then restore remainder_reg to previous value: which is 0000 (it was already 0000, so no change).
       Update quotient_reg: shift left and add 0: quotient_reg remains 0000.
       Then shift dividend_reg left: dividend_reg becomes 0111.
   Iteration 1:
       dividend_reg = 0111, MSB = 0.
       remainder_reg becomes {0000, 0} = 0000.
       Compute temp = 0000 - 0101 = 1011, negative.
       Quotient bit = 0.
       Restore remainder_reg to previous value: 0000.
       Update quotient_reg: shift left and add 0: quotient_reg remains 0000.
       Shift dividend_reg left: dividend_reg becomes 111? Actually, 0111 << 1 = 1110.
   Iteration 2:
       dividend_reg = 1110, MSB = 1.
       remainder_reg becomes {0000, 1} = 0001.
       Compute temp = 0001 - 0101 = 1012 (in 4-bit, 0001 - 0101 = 1012, which is 8 decimal? Let's compute: 1 - 5 = -4, in 4-bit, -4 is 1012 in binary, which has MSB 1, so negative.)
       Quotient bit = 0.
       Restore remainder_reg to previous value: 0000.
       Update quotient_reg: shift left and add 0: quotient_reg remains 0000.
       Shift dividend_reg left: dividend_reg becomes 1100.
   Iteration 3: (last iteration, because NUM_ITER = WIDTH if WIDTH is power of 2, so NUM_ITER = 3 here)
       dividend_reg = 1100, MSB = 1.
       remainder_reg becomes {0000, 1} = 0001.
       Compute temp = 0001 - 0101 = 1012, negative? That gives quotient bit = 0.
       But the example said iteration 3 yields quotient bit 1 and remainder = 0010.
       So this simulation doesn't match the example. Let's re-read the example carefully:

Example says:
Dividend = 3'd7 (binary: 111)
Divisor = 3'd5 (binary: 101)

Iteration 1:
- Remainder = 000 initially.
- Shift remainder left, append MSB of dividend (1): remainder = 001.
- Subtract 101: result is negative.
- Quotient = 0-- (set bit to 0).

Iteration 2:
- Shift remainder left, append next dividend bit (1): remainder = 0011.
- Subtract 101: result is negative.
- Quotient = 00- (set bit to 0).

Iteration 3:
- Shift remainder left, append final dividend bit (1): remainder = 0111.
- Subtract 101: result is positive.
- Remainder becomes 0010.
- Quotient = 001 (set bit to 1).

This example suggests that the dividend bits used in each iteration are not taken from an augmented dividend, but directly from the input dividend bits in order from MSB to LSB. And the remainder register width is WIDTH bits, not WIDTH+1. But then how do we get remainder = 0111 in iteration 3? Let's simulate with WIDTH = 3 and remainder register of 3 bits:
Iteration 1:
   remainder = 000 initially.
   Append MSB of dividend (which is the leftmost bit of 111, i.e. '1'): remainder becomes (000 << 1) | 1 = 001.
   Subtract divisor (101) from remainder: 001 - 101. In 3-bit arithmetic, 1 - 5 = (in binary, 001 - 101 = 110, which is 6 decimal, but with MSB 1, so negative).
   So quotient bit = 0, and restore remainder to original remainder (000).
Iteration 2:
   remainder = 000.
   Append next dividend bit: next dividend bit is the second bit of 111, which is '1': remainder becomes (000 << 1) | 1 = 001 (again 001).
   Subtract divisor: 001 - 101 = negative, quotient bit = 0, restore remainder to 000.
Iteration 3:
   remainder = 000.
   Append final dividend bit: final dividend bit is the third bit of 111, which is '1': remainder becomes (000 << 1) | 1 = 001.
   Subtract divisor: 001 - 101 = negative, but the example says result is positive? That doesn't match.

Wait, the example says iteration 3: remainder becomes 0111 before subtraction. That implies that in iteration 3, the remainder was not 000, but 0011 from previous iteration? Let's try to re-read the example with the possibility that the remainder register is kept across iterations even if the subtraction fails. But the algorithm says "if subtraction result is negative, then restore the original remainder by discarding the quotient bit." But in a typical restoring division algorithm, the remainder is not restored to 0; it is restored to what it was before the shift and append. Let me recall the standard restoring division algorithm:
We have an accumulator A (initially 0) and a register Q (initially dividend). For i from 0 to n-1:
   A = A << 1 | Q[n-1] (i.e., shift left and bring down the MSB of Q)
   A = A - divisor
   if A < 0 then Q[i] = 0 and A = A + divisor, else Q[i] = 1.
After the loop, A is the remainder, and Q is the quotient.
But note that in that algorithm, A is not reset to 0 when subtraction fails; it is updated to A - divisor, and then if negative, we add divisor back. That means that the accumulator A is always updated, but if subtraction fails, it gets restored by adding divisor. And the quotient bit is 0.

Let's simulate standard restoring division with dividend = 7 (111) and divisor = 5 (101), with n = 3:
Initialize: A = 0, Q = 111.
Iteration 0:
   A = 0 << 1 | Q[2] = 0 | 1 = 1.
   A = A - divisor = 1 - 5 = -4. In binary, -4 in 3-bit two's complement is 011? Actually, 1 (001) - 5 (101) = (001 - 101) = 110 (which is -2 in decimal? Let's do: 1 - 5 = -4 decimal, but in 3-bit two's complement, -4 is represented as 011? Wait, 3-bit two's complement range is -4 to +3. -4 in 3-bit is 011? Let's compute: 1 in decimal is 001, 5 is 101, subtraction: 001 + ~101 + 1 = 001 + 010 + 1 = 100? I'm confused.
   Let's do it in decimal: 1 - 5 = -4. In two's complement 3-bit, -4 is represented as 011? Actually, in 3-bit, -4 = 011 if we consider two's complement? Let's check: 011 in two's complement equals -5? Wait, let me recalc: In 3-bit, the range is -4 to +3. The representation: 0 = 000, 1 = 001, 2 = 010, 3 = 011, -1 = 110, -2 = 101, -3 = 100, -4 = 011? That doesn't work. Let's do two's complement conversion properly: For a 3-bit number, the MSB is sign bit. The maximum positive is 3 (011) and the minimum negative is -4 (100)? Actually, the formula for 3-bit two's complement: The negative numbers: -1 = 110, -2 = 101, -3 = 100, -4 = 011? That doesn't seem right.
   Let me compute two's complement for 3 bits: The range is -2^(n-1) to 2^(n-1)-1, i.e., -4 to 3. So -4 in binary (3 bits) should be 100? Because 100 in binary is -4 (since 100 + 1 = 101 which is 5, then two's complement of 100 is 011 which is 3, I'm confused).
   Let's recalc: For n=3, the two's complement representation: 
   0 = 000, 1 = 001, 2 = 010, 3 = 011, -1 = 110, -2 = 101, -3 = 100, -4 = 011? That can't be right because 011 is 3.
   Actually, the formula: For a negative number, x, its two's complement representation is (2^n - |x|) mod 2^n. For -4, that is (8 - 4) mod 8 = 4, which in binary (3 bits) is 100. So -4 should be 100.
   So iteration 0: A becomes 1, then A = 1 - 5 = -4, which in 3-bit representation is 100 (since 100 in binary is 4, but interpreted as -4 because the MSB is 1). So A = 100. Since MSB is 1, A < 0, so Q[0] = 0, and restore A by adding divisor: A = 100 + 101 = 001 (because 100 + 101 = 001 in 3-bit arithmetic? Let's compute: 4 + 5 = 9, but 9 in 3-bit two's complement: 9 mod 8 = 1, and sign bit 0, so 001). 
   So after iteration 0: A = 001, Q = 0?? But Q[0] = 0, and Q becomes shifted left, so Q becomes 0?? Actually, Q originally was 111, after iteration 0, Q becomes (111 << 1) | 0 = (110) | 0 = 110? That yields quotient = 110 which is 6, which is not correct.
   The standard algorithm is usually described with A and Q registers of equal width. But the description here is slightly different.

Maybe we should implement the algorithm exactly as described in the specification:
Algorithm as described:
- Remainder is a register, initially 0.
- For each iteration:
   remainder = (remainder << 1) | (next dividend bit).
   Subtract divisor from remainder.
   If MSB of (remainder - divisor) is 0, then quotient bit = 1 and remainder becomes (remainder - divisor).
   Else, quotient bit = 0 and remainder is restored to the value before the shift and append.
- After all iterations, output quotient and remainder.

Now let's simulate with this algorithm using WIDTH = 3 and remainder register of WIDTH bits.
Iteration 1:
   remainder = 0 initially.
   Next dividend bit: The most significant bit of dividend (111) is 1.
   So new remainder = (0 << 1) | 1 = 1 (in 3 bits: 001).
   Compute temp = remainder - divisor = 1 - 5 = -4.
   In 3-bit arithmetic, -4: The MSB of the result: how to determine negativity? We can compute temp and then check if temp[2] is 1. In 3-bit, 1 is 001, 5 is 101, subtraction: 001 - 101 = (001 + ~101 + 1) = (001 + 010 + 1) = 100 (since 1+1=10, plus 0 gives 0 with carry 1, then plus 0 gives 0, plus 0 gives 0, plus carry 1 gives 1, actually let's do bitwise: 001 - 101: borrow from 0, becomes 1 1? Let's do unsigned subtraction in Verilog, it will produce a value and we can check the MSB).
   But the specification says: "if the most significant bit (MSB) of the subtraction result is 0, then quotient bit = 1, else quotient bit = 0." For 3-bit numbers, the MSB is bit 2. For 1 (001), bit2 is 0. For -4, in unsigned arithmetic, -4 mod 8 = 4, which in binary is 100, so bit2 is 1. So iteration 1: result is negative, so quotient bit = 0, and remainder is restored to its original value (which is 0). So after iteration 1, remainder remains 0, and quotient bit computed is 0.
Iteration 2:
   remainder = 0.
   Next dividend bit: second most significant bit of dividend (111) is 1.
   So new remainder = (0 << 1) | 1 = 1 (001).
   Compute temp = 1 - 5 = -4, which in 3-bit is 100, MSB = 1, so negative.
   So quotient bit = 0, and remainder is restored to 0.
Iteration 3:
   remainder = 0.
   Next dividend bit: third bit (LSB) of dividend (111) is 1.
   So new remainder = (0 << 1) | 1 = 1 (001).
   Compute temp = 1 - 5 = -4, which is 100, MSB = 1, negative.
   So quotient bit = 0, and remainder is restored to 0.
   Final quotient = bits [2:0] = 000, remainder = 0.
But the example says final quotient = 001 and remainder = 010. So this algorithm does not match the example.

Maybe the algorithm is implemented differently: Perhaps the algorithm does not restore remainder to 0 on failure, but rather subtracts divisor and then conditionally updates remainder. The standard restoring division algorithm is:
   A = A << 1 | Q[n-1]
   A = A - d
   if (A < 0) then Q[i] = 0, else Q[i] = 1.
   if (A < 0) then A = A + d.
But that algorithm, when simulated with dividend = 7 (111) and divisor = 5 (101), yields:
   A = 0, Q = 111.
   Iteration 0:
      A = 0 << 1 | Q[2] = 1.
      A = 1 - 5 = -4 (in 3-bit, -4 is 100).
      Since A < 0, Q[0] = 0, and A = A + 5 = 100 + 101 = 001 (because 4+5=9 mod 8 = 1).
   Iteration 1:
      A = A << 1 | Q[1] = 1 << 1 | 1 = (10 binary) | 1 = 11 binary = 3.
      A = 3 - 5 = -2 (in 3-bit, -2 is 101).
      Since A < 0, Q[1] = 0, and A = A + 5 = 101 + 101 = 010 (because 5+5=10 mod 8 = 2).
   Iteration 2:
      A = A << 1 | Q[0] = 2 << 1 | 1 = 4 | 1 = 101 binary = 5.
      A = 5 - 5 = 0.
      Since A >= 0, Q[2] = 1, and A remains 0.
   Final: A = 0, Q = (Q[2:0]) = (1,0,0) = 001, remainder = 0, quotient = 1.
But the example says remainder = 2 (010). So there's a discrepancy: The standard restoring division algorithm for unsigned division, when dividing 7 by 5, yields quotient 1 and remainder 2. But here, the standard algorithm I just simulated gives remainder 0. Let me re-check standard restoring division for unsigned numbers:
The restoring division algorithm for unsigned numbers is usually not used; it's more common for division by repeated subtraction. Wait, there's an algorithm called "non-restoring division" and "restoring division". For unsigned division, the standard algorithm is "non-restoring division". The restoring division algorithm for unsigned numbers works as follows:
   Let A = 0, Q = dividend.
   For i = 0 to n-1:
      A = A << 1 | Q[n-1]
      A = A - divisor
      if (A < 0) then Q[i] = 0, else Q[i] = 1.
      if (A < 0) then A = A + divisor.
   After loop, remainder = A, quotient = Q.
Let's simulate that with 7 and 5, n = 3, but note that Q is 3 bits.
   Initially: A = 0, Q = 111.
   Iteration 0:
      A = 0 << 1 | Q[2] = 0 | 1 = 1.
      A = 1 - 5 = -4. (In 3-bit, -4 is represented as 100, but mathematically it's -4).
      Since A < 0, Q[0] = 0, and A = A + 5 = 1.
   Iteration 1:
      A = 1 << 1 | Q[1] = 2 | 1 = 3.
      A = 3 - 5 = -2.
      Since A < 0, Q[1] = 0, and A = A + 5 = 3.
   Iteration 2:
      A = 3 << 1 | Q[0] = 6 | 1 = 7.
      A = 7 - 5 = 2.
      Since A >= 0, Q[2] = 1, and A remains 2.
   Final: A = 2, Q = (Q[2:0]) = (1,0,0) = 001.
That yields quotient = 1 and remainder = 2, which matches the example.
So the correct algorithm is the standard restoring division algorithm (not the one described in the text earlier, but the one I just simulated).
But then what is the difference between the description and the standard algorithm?
The description said: "if the subtraction result is negative, then the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit." But in the standard algorithm, if subtraction result is negative, we do set quotient bit to 0 and then restore A by adding divisor. And note that A is not simply restored to the value before the shift and append; it's A + divisor, which in our simulation, after iteration 0, A becomes 1 (not 0) because 1 - 5 + 5 = 1.
So the algorithm should be:
   A = 0, Q = dividend.
   For i = 0 to n-1:
       A = A << 1 | Q[n-1];
       A = A - divisor;
       if (A < 0) then Q[i] = 0, else Q[i] = 1;
       if (A < 0) then A = A + divisor;
   Output: Quotient = Q, Remainder = A.
But then the specification says "the dividend is registered internally", which implies we store the input dividend in Q. And "remainder is initialized to zero", which implies A = 0.
And "at each iteration, the remainder is shifted left by one bit, and the next MSB of the dividend is appended to the remainder." That corresponds to A = A << 1 | Q[n-1] (if we consider Q as the dividend register).
Then "the divisor is subtracted from the remainder to check if it can fit." That is A = A - divisor.
Then "if the most significant bit (MSB) of the subtraction result is 0, the quotient bit for this step is set to 1, and the result of the subtraction is kept as the new remainder." That is if A >= 0, then Q[i] = 1, and A remains A.
"Otherwise, if the subtraction result is negative, the quotient bit is set to 0, and the original remainder is restored by discarding the quotient bit." But in the standard algorithm, when A < 0, we set Q[i] = 0, and then restore A by adding divisor (A = A + divisor). And note that the original remainder before the subtraction would have been A before subtraction? But wait, in our algorithm, the "original remainder" before the subtraction is actually the value before subtracting divisor. But in the standard algorithm, we don't store that separately; we just add divisor back.
So the algorithm is:
   A = 0, Q = dividend.
   for i in 0 to n-1:
       A = {A[width-1:0], Q[width-1]}? Actually, standard algorithm: A = A << 1 | Q[n-1].
       A = A - divisor.
       if (A < 0) then Q[i] = 0, A = A + divisor, else Q[i] = 1.
   quotient = Q, remainder = A.
That is the standard restoring division algorithm for unsigned division.

But wait, in our simulation for 7/5, we got:
Iteration 0: A = 0 << 1 | 1 = 1, then A = 1 - 5 = -4, so A < 0, so Q[0] = 0, A = -4 + 5 = 1.
Iteration 1: A = 1 << 1 | 1 = 3, then A = 3 - 5 = -2, so Q[1] = 0, A = -2 + 5 = 3.
Iteration 2: A = 3 << 1 | 1 = 7, then A = 7 - 5 = 2, so Q[2] = 1, A remains 2.
Thus quotient = 001, remainder = 010.
That matches the example.

So I'll implement that algorithm in SystemVerilog. But note: The specification says that the module supports varying input widths specified by WIDTH parameter. So WIDTH is the bit width of dividend and divisor. But in the standard algorithm, Q is of width WIDTH. But then when shifting A left, A should have WIDTH+1 bits (to accumulate the subtraction result) because the subtraction can be negative. So I'll define a local parameter: REM_WIDTH = WIDTH + 1.
I'll have registers: dividend_reg (WIDTH bits) and divisor_reg (WIDTH bits) stored. But in the algorithm, Q is the dividend register. But the input dividend is WIDTH bits. So I'll store that in a register "div_reg". And I'll have "acc" for A, which is REM_WIDTH bits, initialized to 0.
I also need a register for quotient, which will be WIDTH bits. But in the algorithm, quotient bits are built in Q. But Q is overwritten each iteration. But the algorithm as described: for each iteration, we do: Q = Q << 1 | computed_quotient_bit. But note that in the simulation above, we used Q from the input dividend. But then in iteration 0, Q[2] was used, but then Q was shifted left and appended with 0. But that doesn't match the simulation I did because I used Q as the input dividend and then did A = A <<