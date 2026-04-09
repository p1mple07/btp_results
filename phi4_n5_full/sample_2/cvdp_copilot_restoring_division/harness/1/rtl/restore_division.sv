module that performs division using the restoring division algorithm." We have to provide RTL code. The module name is "restoring_division" with parameter WIDTH, default 6. It has inputs: clk, rst, start, dividend, divisor. And outputs: quotient, remainder, valid. We have to produce one answer in plain text. Our answer must be a SystemVerilog module code that does division using the restoring division algorithm. We have to implement a module that does division over WIDTH iterations.

We need to check specification: "The module processes a new pair of dividend and divisor inputs in each division cycle. New inputs can be supplied along with start signal only when the previous outputs have been provided, indicated by valid going high for one clock cycle." So we need a state machine that waits until valid goes high then ready to process new inputs. But the spec does not require pipelining? It says: "New inputs can be supplied along with start signal only when previous outputs have been provided, indicated by valid going high for one clock cycles." So likely, we need a flag that indicates that module is ready to start new computation. Possibly we need to check if valid is high, then accept new inputs.

The algorithm: For each iteration, we shift remainder left, append next MSB of dividend. Then subtract divisor from remainder. But note: The algorithm described is not exactly standard restoring division algorithm. The standard restoring division algorithm for unsigned division: The dividend is placed in the register A (n bits) and divisor in register B (n bits). Then the remainder is A, quotient is 0. Then for each iteration i from n-1 downto 0, we shift left remainder, and then subtract divisor from remainder. If remainder is >= divisor then set quotient bit to 1 and keep remainder as remainder. Else if remainder < divisor then set quotient bit to 0 and restore remainder to previous remainder? But the algorithm described in the problem is slightly different: It says:
"In each iteration, remainder is shifted left by one bit, and the next MSB of the dividend is appended to the remainder. Then subtract divisor from remainder. If MSB of subtraction result is 0, then quotient bit is set to 1 and remainder becomes subtraction result. Else if MSB is 1 then quotient bit is 0 and remainder is restored."

Wait, let's re-read the description carefully:

"Shift and Subtract:
1. At each iteration, the remainder is shifted left by one bit, and the next MSB of the dividend is appended to the remainder.
2. The divisor is subtracted from the remainder to check if it can fit.
   - If the most significant bit (MSB) of the subtraction result is 0, the quotient bit for this step is set to 1, and the result of the subtraction is kept as the new remainder.
   - If the most significant bit (MSB) of the subtraction result is 1, the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit."

This is slightly ambiguous: "discard the quotient bit" means the quotient bit is 0. The original remainder is restored. But in typical restoring division, if subtraction yields a negative result, we restore the previous remainder. But here it says "if the result is negative, the quotient bit is 0, and the remainder is restored by discarding the quotient bit." But in restoring division algorithm, the remainder is stored in a register and then is shifted left. But the algorithm described seems to require that each iteration, you shift the remainder and then do subtraction. But then you have a "restore" condition: if subtraction result is negative, then the quotient bit is 0 and remainder is restored to previous remainder (which is effectively not including the new bit that was appended? But note: "discard the quotient bit" might be a misinterpretation, but I'll assume that means the quotient bit is 0 and remainder remains the previous remainder, not the negative result.)

I need to check the algorithm with example:
Example: WIDTH=3, dividend=7, divisor=5.
Iteration 1: remainder=0, dividend=111.
Step 1: Shift remainder left by one (0 becomes 0), then append MSB of dividend (which is 1), so remainder becomes 001 (binary). Then subtract divisor (101) from remainder (001): 001 - 101 = negative (since MSB is 1). So quotient bit is 0, and remainder is restored (which means we revert to previous remainder? But previous remainder was 0. So remainder becomes 0? But then they mention final remainder is 010. Let's re-read the example iteration details:

Example:
Iteration 1: remainder=000, dividend=111.
Step 1: Shift remainder left, append MSB of dividend (1) => remainder becomes 001.
Then subtract 101: result is negative.
So quotient=0 (so far quotient=0--). Then it says "restore" the remainder. But in typical restoring division algorithm, if subtraction yields negative, then we restore the previous remainder. The previous remainder was 000. So remainder becomes 000 after iteration 1.
Iteration 2: remainder=000, then shift left and append next dividend bit (1) => remainder becomes 001 (or 001? Actually, it's 0 then appended bit becomes 01, but it's width=3 so maybe it's 010? Let's recalc: if we had 3 bits, then shift left by one means we shift out the LSB and shift in a new bit. So initial remainder was 000. After shifting left, it becomes 000. Then appending the next bit (which is 1) gives 000? Wait, how do we shift left? Let me re-read typical restoring division algorithm: It uses n+1 bits for the remainder register, where n is the bit width. But the spec says: "The division process must finish within WIDTH clock cycles if WIDTH is a power of 2 (2^n) to ensuring all data is processed; otherwise, it will take WIDTH+1 clock cycles." That implies that if WIDTH is a power of 2, then the process is exactly WIDTH cycles. But in typical restoring division algorithm, you need n cycles if you use a n-bit register for quotient and an n+1-bit register for remainder. But here they said it takes WIDTH cycles if WIDTH is a power of 2, so maybe they are not using an extra bit. But the algorithm as described: "Shift remainder left by one bit and append the next MSB of dividend" suggests that remainder is WIDTH bits wide. But then the subtraction can overflow if remainder < divisor. But then you check the MSB of the subtraction result to determine negativity. But if remainder is WIDTH bits and divisor is WIDTH bits, then subtraction is WIDTH bits with possible borrow? But in binary arithmetic, subtraction can be negative if the subtrahend is greater than the minuend. But how do we check negativity? Possibly by checking the sign bit of the result, i.e. if the result's MSB is 1, then it is negative. But in unsigned arithmetic, negative doesn't exist. But in restoring division algorithm, we typically use two's complement arithmetic. Alternatively, we can detect if the subtraction result is less than zero by checking if there was a borrow out from the most significant bit. But in SystemVerilog, we can do subtraction and then check if the subtraction result is less than zero? But we are dealing with unsigned numbers. But maybe the algorithm is implemented in a way that the subtraction is done in a "restoring" manner: if the subtraction result is negative, then the MSB of the result (the result of subtraction, if interpreted as signed) is 1, then quotient bit is 0 and remainder is restored (i.e. not updated). But how to do that in hardware? We can compute the difference as difference = remainder - divisor, then check if difference[WIDTH-1] is 1. But careful: if remainder and divisor are both WIDTH bits, then difference might be computed as a signed subtraction? But then we need to interpret the result as signed. But we can do that by treating the difference as a signed number. But then if difference is negative, then the MSB is 1. But if difference is positive, then the MSB is 0. But what if difference equals 0? That is non-negative. So condition: if (difference[WIDTH-1] == 0) then quotient bit is 1 and new remainder = difference, else quotient bit is 0 and remainder remains unchanged. But note: if the result is negative, then we restore the previous remainder, not the negative result. So in iteration, we need to store the previous remainder before shifting left. So the algorithm: 
- state machine: start state, then wait for iterations, then final state, then valid output high for one cycle.
- We need a counter for iterations. 
- We'll need a register for current remainder (WIDTH bits). But then we shift left and append new bit. But how do we append the next dividend bit? The dividend is provided as a WIDTH-bit value. We want to process it bit by bit from MSB to LSB. So we need a pointer index that goes from (WIDTH-1) down to 0, and a register to hold the dividend bits. But the algorithm says: "At the start of the division process, the dividend is registered internally." So we can register dividend and divisor. Then use a counter to track the iteration. 
- We'll need a register for quotient, which is WIDTH bits, but then quotient bits are produced one per iteration, but they are produced in order from MSB to LSB? But typical restoring division algorithm: the quotient bits are computed in order, but then the final quotient is the bits in order, but the example final quotient is 001 for dividend 7 and divisor 5, which is not the binary quotient? Wait, 7/5 equals 1 remainder 2, so quotient is 1, remainder is 2. But the algorithm computed quotient bits: iteration 1: quotient bit = 0, iteration 2: quotient bit = 0, iteration 3: quotient bit = 1, so quotient in binary (from MSB to LSB) is 001. So indeed quotient bit order is from iteration 1 is the MSB and iteration WIDTH is the LSB. So we need to shift quotient register left and then OR in the new quotient bit. But careful: the first iteration, quotient bit is computed and becomes the MSB. 
- We need to handle start signal: only process new inputs when previous valid is high. That means we need a flag "busy" that is high when we are computing, and then we set valid after computation. Possibly also need to check if start is high and not busy.

Let's define states: 
IDLE: waiting for start and valid from previous cycle? But specification says: "New inputs can be supplied along with start signal only when the previous outputs have been provided, indicated by valid going high for one clock cycles." So we can use a flag "busy" that is set when computation begins and cleared when finished. And maybe check that start is high and not busy, or valid is high? But we want to allow one cycle gap? Possibly we want to sample start only when valid is high (meaning previous computation finished). But we can simply check that if busy is false, then if start is high, then start new division. But then we need to hold start for one cycle? But specification says "only supply new inputs when valid is high for one clock cycle" which means that we should latch the new input on the rising edge if valid is high. But we can do that by checking if valid is high in the previous cycle? But simpler: we can use a "ready" signal that indicates that module is ready to accept new inputs. And then if start is high and ready is true, latch new inputs and start computation. And then in each iteration, the computation takes either WIDTH or WIDTH+1 cycles, depending on parameter. But specification says: "The division process must finish within WIDTH clock cycles if WIDTH is a power of 2 (2^n) to ensuring all data is processed; otherwise (if WIDTH is not a power of 2), it will take WIDTH+1 clock cycles." So how do we determine that? We have parameter WIDTH. If WIDTH is a power of 2, then number of iterations = WIDTH; else iterations = WIDTH+1. But how do we determine if WIDTH is a power of 2? Possibly by checking if (WIDTH & (WIDTH - 1)) == 0. But WIDTH is a parameter constant, so we can use generate statements in SystemVerilog to decide number of iterations. But we cannot use "if (WIDTH & (WIDTH - 1)) == 0" in a generate because WIDTH is a parameter constant, but that might be allowed if WIDTH is a parameter? But the spec says: "WIDTH (default value = 6)". But then if WIDTH=6, 6 is not a power of 2, so iterations = WIDTH+1 = 7 cycles. If WIDTH=8, then iterations = WIDTH = 8 cycles. But the algorithm described says: "the division process must finish within WIDTH clock cycles if WIDTH is a power of 2, otherwise it will take WIDTH+1 clock cycles." So we need to generate a constant number of iterations: either a parameter NUM_STEPS = ( (WIDTH == 1) ? 1 : ( (WIDTH & (WIDTH-1)) == 0 ? WIDTH : WIDTH+1 ) ). But careful: if WIDTH=1, then power of 2? 1 is a power of 2. But then iterations = 1.
We can do: localparam integer NUM_STEPS = ( (WIDTH & (WIDTH-1)) == 0 ) ? WIDTH : WIDTH+1; But careful: WIDTH is a parameter, so we can compute that at elaboration time. But then if WIDTH is not a power of 2, then iterations = WIDTH+1.

But note: The algorithm described in the specification: "The division process must finish within WIDTH clock cycles if WIDTH is a power of 2 (2^n) to ensuring all data is processed; otherwise (if WIDTH is not a power of 2), it will take WIDTH+1 clock cycles." So we need to use a counter that counts from 0 to NUM_STEPS-1. But then we need to extract the dividend bits one by one from MSB to LSB. So we need an index that goes from (WIDTH-1) downto 0. But if NUM_STEPS equals WIDTH or WIDTH+1, then the index range might be different. Typically, in restoring division algorithm, you process WIDTH iterations. But here they want to support non-power-of-2 widths by taking an extra cycle. That extra cycle is probably used to process the final bit of the dividend? Let's simulate with WIDTH=6, which is not a power of 2 because 6 is not 2^n. So then NUM_STEPS = 7. And dividend is 6 bits. But then you have 7 iterations. How do you get a 7th bit? Possibly you need to append a zero? In some division algorithms, you append an extra 0 to the right. That is typical in restoring division algorithm: You left shift the dividend and append a 0 to get an extra bit. So the algorithm: For each iteration, do: remainder = remainder << 1; then if there is a dividend bit available, then remainder[0] = dividend_bit; else remainder[0] = 0. And the quotient bit is computed after subtraction. And after NUM_STEPS iterations, the remainder is the final remainder and the quotient is computed. So that is likely the algorithm: if WIDTH is not a power of 2, then do WIDTH+1 iterations, where the last iteration uses a 0 appended bit. So we need to compute an index that goes from (WIDTH-1) downto 0 for the first WIDTH iterations, and then in the (WIDTH+1)th iteration, append 0. But then, wait, if WIDTH is a power of 2, then we have exactly WIDTH iterations. But then the dividend has WIDTH bits and the algorithm would process all bits. But typically restoring division algorithm uses n iterations, where n is the number of bits in the dividend. But here the specification is a bit different: It says "if WIDTH is a power of 2, then the division process finishes in WIDTH clock cycles; otherwise, it will take WIDTH+1 clock cycles." That is exactly like a division algorithm that appends an extra 0 for non-power-of-2 widths. So we need to have a counter "step" that goes from 0 to NUM_STEPS-1. And then use "bit_index" to determine which bit of dividend to use. For step < WIDTH, bit_index = WIDTH-1 - step, and for step == WIDTH (if exists), then bit_index doesn't matter, use 0. But careful: if NUM_STEPS = WIDTH, then step goes 0 to WIDTH-1, and we use dividend bit = dividend[WIDTH-1 - step]. If NUM_STEPS = WIDTH+1, then step goes 0 to WIDTH, and for step==WIDTH, we use 0.

I will assume that the algorithm is iterative. We need a state machine with states: IDLE, COMPUTE. In IDLE state, if start is high and not busy, then latch the inputs (dividend and divisor) and set a counter = 0, set remainder = 0, quotient = 0, and set busy flag = 1, and then move to COMPUTE state. In COMPUTE state, if step < NUM_STEPS, then perform one iteration:
- Compute new remainder: temp = remainder - divisor, but then check if subtraction result is negative. But how to check negative? We can compute difference as signed. But remainder and divisor are unsigned. But we can do: temp = remainder - divisor; and then if (temp[WIDTH-1] == 1) then it's negative, else non-negative. But caution: subtraction in SystemVerilog for unsigned numbers will produce an unsigned result with wrap-around. But we want to detect borrow. We can use a "borrow" signal computed by subtracting with a borrow out. In Verilog, subtraction does not produce a borrow out signal, but we can compute it manually. Alternatively, we can compute the difference as a signed number by sign-extending remainder and divisor. But remainder and divisor are unsigned. But we can do: diff = $signed(remainder) - $signed(divisor). But then if diff < 0 then it's negative. But then if negative, then quotient bit is 0 and remainder remains same. But if non-negative, then quotient bit is 1 and remainder becomes diff. But note: The algorithm says "if MSB of subtraction result is 0, then quotient bit is set to 1 and remainder becomes subtraction result; if MSB is 1, then quotient bit is 0 and remainder is restored." So that's the algorithm.
- Then shift quotient left by one and OR in the new bit. But careful: quotient should be built bit by bit. But the algorithm order: In iteration 1, the computed quotient bit is the MSB of quotient. So quotient register should be shifted left and then the new quotient bit is inserted at LSB. But then after all iterations, quotient register holds the quotient in correct order? But if we shift left then OR with the new quotient bit, then after NUM_STEPS iterations, quotient register will contain the bits in order from MSB to LSB. But wait, if we do that, then after the final iteration, quotient will be shifted left and then the new bit is inserted. But then quotient bits are in the order that they were computed, with the first computed bit as the MSB. That is correct.

- Also, update remainder. But careful: the algorithm: before subtraction, we shift remainder left and append the next dividend bit. So the new remainder candidate = (remainder << 1) | dividend_bit. Then do subtraction: diff = candidate - divisor. Then if diff is negative, then quotient bit = 0 and remainder remains candidate? Wait, the description says: "If the MSB of the subtraction result is 0, then the quotient bit for this step is set to 1, and the result of the subtraction is kept as the new remainder. If the MSB is 1, then the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit." Wait, "restoring" means that we discard the appended bit if subtraction fails, so the remainder should be the remainder from previous iteration, not the candidate. So algorithm: 
   candidate = (remainder << 1) | next_bit.
   diff = candidate - divisor.
   if (diff < 0) then quotient_bit = 0, new remainder = remainder (the previous remainder), else quotient_bit = 1, new remainder = diff.
But wait, check example iteration 1: remainder initially 000, candidate = (000 << 1) | 1 = 001, diff = 001 - 101 = (in unsigned arithmetic, 1 - 5 = 6? But 6 in binary is 110, but if interpreted as signed 2-bit, it might be negative? But we are using WIDTH=3 bits, so we check bit2: 110's MSB is 1, so it's negative. So condition true, so quotient bit = 0, and new remainder = old remainder = 000.)
Iteration 2: remainder = 000, candidate = (000 << 1) | next_bit (which is 1) = 001, diff = 001 - 101 = negative, so quotient bit = 0, new remainder = old remainder = 000.
Iteration 3: remainder = 000, candidate = (000 << 1) | next_bit (which is 1) = 001, diff = 001 - 101 = negative? But the example said it became positive and remainder becomes 0010. Wait, check example: They had dividend=7 which is binary 111. Iteration 1: shift left remainder 0 becomes 0, then append MSB (1) becomes 001, subtract divisor (101) yields negative. So remainder remains 0. Iteration 2: shift left remainder 0 becomes 0, then append next dividend bit (1) becomes 001, subtract divisor (101) yields negative, so remainder remains 0.
Iteration 3: shift left remainder 0 becomes 0, then append final dividend bit (1) becomes 001, subtract divisor (101) yields negative. That would yield quotient bits all 0, which is not correct. The example output: quotient = 001 and remainder = 010. So clearly, the example doesn't match the described algorithm. Let's re-read the example: They said:
Iteration 1:
- Remainder = 000, dividend = 111.
- Shift remainder left, append MSB of dividend (1): remainder becomes 001.
- Subtract 101: result is negative.
- Quotient = 0-- (set bit to 0).
Iteration 2:
- Shift remainder left, append next dividend bit (1): remainder becomes 0011.
- Subtract 101: result is negative.
- Quotient = 00- (set bit to 0).
Iteration 3:
- Shift remainder left, append final dividend bit (1): remainder becomes 0111.
- Subtract 101: result is positive.
- Remainder becomes 0010.
- Quotient becomes 001 (set bit to 1).

Wait, how did they get remainder becomes 0111 in iteration 3? In iteration 2, they said remainder becomes 0011. But then iteration 3: "Shift remainder left, append final dividend bit (1): remainder becomes 0111." That implies that in iteration 2, the remainder was 0011, not 000. So maybe the algorithm is: Always shift left the current remainder and append the next dividend bit, regardless of the subtraction result. But then after subtraction, if subtraction is successful (non-negative), then update remainder to the subtraction result. But if subtraction fails (negative), then do not update remainder, but still shift quotient? But then how do we get 0011 in iteration 2? Let's simulate with that idea:
Iteration 1: remainder = 000, candidate = (000<<1) | (dividend[2]=1) = 001.
Subtract: 001 - 101 = negative, so quotient bit = 0, and remainder remains candidate? But then remainder becomes 001? But then iteration 2: remainder = 001, candidate = (001<<1) | (dividend[1]=1) = (010 | 1 = 011). Subtract: 011 - 101 = negative? But 011 (3) - 101 (5) = -2, so quotient bit = 0, and remainder remains candidate? That would yield remainder = 011, but then iteration 3: remainder = 011, candidate = (011<<1) | (dividend[0]=1) = (110|1 = 111). Subtract: 111 - 101 = 010, which is non-negative, so quotient bit = 1, remainder becomes 010. Then quotient bits: iteration 1: 0, iteration 2: 0, iteration 3: 1. That yields quotient = 001 and remainder = 010. That matches the example. So the algorithm might be: 
At each iteration:
- candidate = (remainder << 1) | next dividend bit.
- subtract: diff = candidate - divisor.
- If diff is non-negative, then quotient bit = 1 and remainder = diff.
- Otherwise, quotient bit = 0 and remainder = candidate (i.e. do not subtract, keep candidate as remainder).
But wait, that doesn't match the description "if subtraction result is negative, then restore the original remainder by discarding the quotient bit." But if we use candidate as remainder, then we are not discarding the appended bit. But the description said "restore the original remainder". In the example, iteration 1: original remainder was 000, but then candidate was 001, but they said they restored the original remainder, so remainder should remain 000, not 001. But the example says iteration 1: remainder becomes 001? Let's re-read the example carefully:
"Initialization:
- Remainder = 000 (set to 0 initially)
- Dividend = 111
- Quotient is initially unknown and will be calculated over 3 iterations.
- The division starts from the MSB of the dividend.
Iteration 1:
- Shift remainder left, append MSB of dividend (1):  
  - Remainder = 001  
  - Subtract 101: result is negative.  
  - Quotient = 0-- (set bit to 0).
Iteration 2:
- Shift remainder left, append next dividend bit (1):  
  - Remainder = 0011  
  - Subtract 101: result is negative.  
  - Quotient = 00- (set bit to 0).
Iteration 3:
- Shift remainder left, append final dividend bit (1):  
  - Remainder = 0111  
  - Subtract 101: result is positive.  
  - Remainder = 0010  
  - Quotient = 001 (set bit to 1)."
So according to the example, after iteration 1, remainder becomes 001 even though subtraction was negative. But then after iteration 2, remainder becomes 0011 even though subtraction was negative. And then after iteration 3, subtraction is successful so remainder becomes 0010, not 0111. So what is the logic? Let's simulate with candidate method:
Iteration 1: candidate = (000 << 1) | 1 = 001. Then diff = 001 - 101 = -? But then if we check signed diff, 001 (1) - 101 (5) gives -4. So negative. Then according to candidate method: if negative, then quotient bit = 0 and remainder = candidate? That would yield remainder = 001. But then iteration 2: candidate = (001 << 1) | 1 = (010|1=011) = 011. Then diff = 011 - 101 = 3 - 5 = -2, negative. So then quotient bit = 0 and remainder = candidate, remainder becomes 011.
Iteration 3: candidate = (011 << 1) | 1 = (110|1=111) = 111. Then diff = 111 - 101 = 6 - 5 = 1, non-negative. So then quotient bit = 1 and remainder becomes diff = 001.
Then quotient bits: 0, 0, 1. That matches the final quotient = 001 and remainder = 001 (but the example final remainder is 010, not 001). Wait, recalc remainder: iteration 3: candidate = 111 (7), diff = 7 - 5 = 2, so remainder becomes 2 which in 3-bit is 010. So that matches.

So the algorithm is: At each iteration, candidate = (remainder << 1) | next_bit. Then compute diff = candidate - divisor. If diff is non-negative (i.e. no borrow), then set quotient bit = 1 and update remainder = diff. Otherwise, set quotient bit = 0 and update remainder = candidate. But then in iteration 1, candidate was 001, and since diff was negative, we set remainder = candidate, i.e. 001. But then in iteration 2, candidate becomes (001<<1)|1 = (010|1=011), and diff = 011 - 101 = negative, so remainder becomes candidate = 011. And then iteration 3, candidate becomes (011<<1)|1 = (110|1=111), diff = 111 - 101 = 010, so remainder becomes diff = 010 and quotient bit = 1.
But then what is the purpose of "restoring"? Because if subtraction fails, normally you would restore the previous remainder, not the candidate. But the example clearly uses candidate as remainder when subtraction fails. Wait, let's re-read the text "if the most significant bit (MSB) of the subtraction result is 1, the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit." That implies that if subtraction fails, you want to discard the candidate bit. That means you want to revert remainder to what it was before shifting left and appending the dividend bit. But in the example, iteration 1: original remainder was 000, but after shifting left and appending the dividend bit, remainder became 001. But then they said "restore the original remainder", which should be 000, not 001. But the example explicitly says "Remainder = 001" after iteration 1. Let's re-read the example text carefully:
"Initialization:
- Remainder = 000 (set to 0 initially)
- Dividend = 111
- Quotient is initially unknown and will be calculated over 3 iterations.
- The division starts from the MSB of the dividend.
Iteration 1:
- Shift remainder left, append MSB of dividend (1):  
  - Remainder = 001  
  - Subtract 101: result is negative.  
  - Quotient = 0-- (set bit to 0)."
It doesn't say what the remainder becomes after subtraction, it just says quotient bit is 0. But then iteration 2:
"Shift remainder left, append next dividend bit (1):  
  - Remainder = 0011  
  - Subtract 101: result is negative.  
  - Quotient = 00- (set bit to 0)."
Iteration 3:
"Shift remainder left, append final dividend bit (1):  
  - Remainder = 0111  
  - Subtract 101: result is positive.  
  - Remainder = 0010  
  - Quotient = 001 (set bit to 1)."
So the final remainder is 0010 (2), and quotient is 001 (1). So what happened to remainder after iteration 1 and 2? They are not mentioned explicitly except the initial candidate values. It seems that after each iteration, they always shift left and append the dividend bit, and then do the subtraction. And if subtraction fails, they don't update the remainder with the subtraction result, but they keep the candidate as remainder? But that would mean the remainder is always the candidate regardless of subtraction result. But then the algorithm would always yield remainder = candidate, and then at the final iteration, if subtraction is successful, remainder becomes diff. But then quotient bits are determined solely by the subtraction result in the last iteration. But then how do we get quotient bits 0 in iteration 1 and 2? Because if we always update remainder to candidate, then remainder becomes 001 after iteration 1 and 011 after iteration 2, and then in iteration 3, candidate = 111, diff = 111 - 101 = 010, so quotient bit = 1. And quotient register would be 0, 0, 1. That is consistent. But then what is the point of "restoring"? Because in a typical restoring division, if subtraction fails, you restore the previous remainder. But here, it seems they are not restoring the previous remainder, they are simply using the candidate as the new remainder even when subtraction fails. But then the description "restoring" is misleading.

Wait, let me re-read the original text: "The restoring division algorithm is a method used for binary division in computer architecture. It involves repeatedly subtracting the divisor from the dividend and restoring the partial remainder if the result is negative." The classical restoring division algorithm for unsigned division: 
Let A be the dividend (n bits) and Q be the quotient (n bits) initially 0, and let M be the divisor. Then for i = n-1 downto 0 do:
   A = A << 1;
   A = A | next bit of dividend;
   if A >= M then
       A = A - M;
       Q[i] = 1;
   else
       Q[i] = 0;
At the end, A is the remainder.
That is the algorithm. And in that algorithm, if A < M, then we do not update A (i.e. we do not subtract M) and keep A as is. But here, the description says "restoring" which means if subtraction fails, then you restore A to its previous value. But the classical algorithm: A is updated to A << 1 | next_bit regardless, and then if A >= M then subtract M, else do nothing. But then if A < M, then quotient bit is 0 and remainder remains A (which is the candidate), not the previous remainder. But wait, in the classical algorithm, A is updated to A << 1 | next_bit regardless. And if A < M, then you don't subtract M, so A remains as is. So that is exactly what we are doing: candidate = A << 1 | next_bit, and if candidate >= M then A = candidate - M, else A = candidate. And quotient bit is 1 if candidate >= M, else 0.
Now, the description in the problem says: "if the subtraction result is negative, then the quotient bit is set to 0, and the original remainder is restored by discarding the quotient bit." That might be interpreted as: if subtraction yields a negative result, then do not update the quotient, and revert A to what it was before shifting left. But the classical algorithm does: A = A << 1 | next_bit always. And then if A < M, then quotient bit is 0, and A remains as is (which is the candidate, not the original remainder). But then the classical algorithm is sometimes called "non-restoring division" if you don't restore A. Wait, there are two algorithms: restoring division and non-restoring division. In the restoring division algorithm, if subtraction fails, you restore A to its previous value. But in the non-restoring division algorithm, you keep the result even if it's negative. Let me recall:
- Restoring division algorithm: 
   for i = n-1 downto 0:
       A = A << 1;
       A = A | next dividend bit;
       if A >= M then
            A = A - M;
            Q[i] = 1;
       else
            Q[i] = 0;
            (A remains unchanged)
- Non-restoring division algorithm:
   for i = n-1 downto 0:
       A = A << 1;
       A = A | next dividend bit;
       if A >= M then
            A = A - M;
            Q[i] = 1;
       else
            Q[i] = 0;
            A = A; // but sometimes you do A = A (no change) or A = A (not restored)

I recall that in the restoring algorithm, if subtraction fails, then you restore A to the value before the subtraction attempt, but since you already shifted A, you have to undo the shift. But the classical restoring division algorithm is usually described as:
   for i = 0 to n-1:
       A = A << 1;
       A = A | next dividend bit;
       if A >= M then
           A = A - M;
           Q[i] = 1;
       else
           Q[i] = 0;
           // A remains unchanged
At the end, A is the remainder.
But wait, then how is it "restoring"? Because if subtraction fails, you are not "restoring" A to its previous value, you are leaving it as is. Actually, I recall that in the restoring algorithm, you do:
   A = A << 1;
   A = A | next dividend bit;
   A = A - M;
   if (A < 0) then
       Q[i] = 0;
       A = A + M; // restore A
   else
       Q[i] = 1;
This is one version. But then the non-restoring algorithm is:
   A = A << 1;
   A = A | next dividend bit;
   A = A - M;
   if (A < 0) then
       Q[i] = 0;
   else
       Q[i] = 1;
   // A remains as A (even if negative) for next iteration.
But the classical algorithm for unsigned division is usually the restoring division algorithm. Let me check: For unsigned division, the restoring division algorithm is:
   for i = n-1 downto 0:
       A = A << 1;
       A = A | next dividend bit;
       if A >= M then
           A = A - M;
           Q[i] = 1;
       else
           Q[i] = 0;
           // A remains unchanged
That is the algorithm I know. And it doesn't require a separate subtraction then restoring step because the subtraction is only performed if A >= M. 
The description given in the problem: "If the MSB of the subtraction result is 0, the quotient bit for this step is set to 1, and the result of the subtraction is kept as the new remainder. If the MSB of the subtraction result is 1, the quotient bit for this step is set to 0, and the original remainder is restored by discarding the quotient bit." That sounds like a different algorithm: They are doing subtraction unconditionally and then checking the result. In that algorithm, you always compute candidate = A << 1 | next dividend bit, then diff = candidate - M. Then if diff is negative, then quotient bit = 0 and A remains as candidate (which is the same as not subtracting, but then you are discarding the quotient bit, i.e., you don't update A with diff, you keep candidate). But then if diff is non-negative, then quotient bit = 1 and A becomes diff. But then note: if diff is negative, candidate is not used, but then what is "restored"? The original remainder was A before shifting left. So if subtraction fails, then A should revert to the value before the shift. But the example: Iteration 1: A was 000, candidate becomes 001, diff = 001 - 101 = negative, so then A should be restored to 000, not candidate. But the example says "Remainder = 001" after iteration 1. So there's an inconsistency.
Let's re-read the example carefully. The example states:
Initialization: Remainder = 000, Dividend = 111.
Iteration 1:
- "Shift remainder left, append MSB of dividend (1):  
  - Remainder = 001"
So after shifting left and appending, the remainder becomes 001.
- "Subtract 101: result is negative."
- "Quotient = 0-- (set bit to 0)."
It does not explicitly say what the remainder becomes after subtraction. It just says quotient bit is 0.
Iteration 2:
- "Shift remainder left, append next dividend bit (1):  
  - Remainder = 0011"
So apparently, the remainder before iteration 2 was 001? Because shifting left 001 gives 010, then appending 1 gives 011, but they wrote 0011. Wait, 0011 is 3 bits. But if WIDTH=3, then remainder should be 3 bits. But 0011 is 4 bits. That is confusing.
Maybe the example is using a 4-bit register for remainder? Because dividend is 3 bits, so remainder should be 3 bits. But they wrote 0011, which is 4 bits. Perhaps they are representing the values in binary with a leading 0 for clarity. 0011 is actually 3 bits if you ignore the leading 0, but then it's 3 bits. But then iteration 3: "Remainder = 0111" is 4 bits. 
Maybe the example is just for illustration and not strictly following bit widths.

I think the intended algorithm is the classical restoring division algorithm:
Algorithm:
Initialize:
A = dividend (n bits), Q = 0 (n bits), count = n.
For i = n-1 downto 0:
    A = A << 1; // shift left by 1
    A = A | Q[i] (or rather, A gets the next bit from dividend? Actually, the dividend is shifted into A, not Q. Wait, the standard algorithm: Let A be the remainder register (n bits), and let Q be the quotient register (n bits). Then for i = n-1 downto 0, do: A = A << 1; A = A | next bit of dividend (which is Q[i] originally, but then replaced by dividend bit). Then if A >= M then A = A - M; Q[i] = 1; else Q[i] = 0.
At the end, A is the remainder.
But in our module, we are given dividend and divisor as inputs, and we want to output quotient and remainder. So we can do:
- reg [WIDTH-1:0] A; // remainder register, initially dividend.
- reg [WIDTH-1:0] Q; // quotient register, initially 0.
- For i = WIDTH-1 downto 0:
    A = A << 1;
    A[0] = dividend[i] (or dividend bit, but careful with order: the MSB of dividend is used first).
    if (A >= divisor) then
         A = A - divisor;
         Q[i] = 1;
    else
         Q[i] = 0;
At the end, remainder = A, quotient = Q.
This is the classical restoring division algorithm.

But the specification says "The design supports varying input widths specified by the WIDTH parameter." and "The division process must finish within WIDTH clock cycles if WIDTH is a power of 2, otherwise (if WIDTH is not a power of 2), it will take WIDTH+1 clock cycles." This is a bit odd because the classical algorithm always takes WIDTH cycles if you use the dividend bits. But sometimes for non-power-of-2 widths, you need an extra cycle to handle the final bit. Actually, the classical algorithm for unsigned division typically uses n cycles where n = number of bits in the dividend. But if the dividend width is not a power of 2, then n is not a power of 2. For example, if WIDTH=6, then n=6, but then you might need an extra cycle to process the final bit? There is a variant called "non-restoring division" that takes n+1 cycles for non-power-of-2 widths. But the specification explicitly states that. So I think we need to implement a counter that runs for NUM_STEPS cycles, where NUM_STEPS = (WIDTH is power of 2) ? WIDTH : WIDTH+1.

So the algorithm will be:
- State machine: IDLE, COMPUTE.
- In IDLE, wait for start signal and valid from previous cycle? The spec says "New inputs can be supplied along with start signal only when the previous outputs have been provided, indicated by the valid going high for one clock cycles." So we need a flag "ready" that is high when valid was high in the previous cycle. But we can simply check that if (start && !busy) then latch new inputs.
- In COMPUTE, on each clock cycle, if counter < NUM_STEPS, then:
   Determine the dividend bit to use: if (counter < WIDTH) then bit = dividend[WIDTH-1 - counter], else bit = 0.
   Then do: A = A << 1; A[0] = bit.
   Then if (A >= divisor) then 
         A = A - divisor;
         Q = Q | (1 << (counter)) but careful: the bit position: The first iteration (counter=0) corresponds to the MSB of quotient, so quotient bit for iteration i should be placed at bit (NUM_STEPS-1 - i) or something? Let's see: In the example, iteration 1 (counter=0) produced quotient bit 0 and placed it in the MSB position of a 3-bit quotient. That means the quotient register after 3 iterations is 001, which means the bit from iteration 1 is at bit2, iteration 2 at bit1, iteration 3 at bit0. So if we index iterations from 0 to NUM_STEPS-1, then the quotient bit computed at iteration i should be placed at bit (NUM_STEPS-1 - i). So we can do: Q[ (NUM_STEPS-1 - i) ] = result (0 or 1).
   Else, if (A < divisor), then Q[ (NUM_STEPS-1 - i) ] = 0.
   Then increment counter.
- When counter reaches NUM_STEPS, then division is complete. Set valid high for one cycle, and busy = 0.
- Also, need to latch inputs at start of computation.
- Use asynchronous reset: if rst is asserted (active low), then clear outputs and busy flag.

Let's design the module in SystemVerilog.

I will write something like:

module restoring_division #(
    parameter WIDTH = 6
)(
    input logic clk,
    input logic rst_n, // active low asynchronous reset, but spec says rst is active low asynchronous reset, so I'll name it rst.
    input logic start,
    input logic [WIDTH-1:0] dividend,
    input logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic valid
);

But the spec says rst is active-low asynchronous reset, so name it rst and then use if (!rst) ... reset.

We need a state machine. Let's define states:
typedef enum {IDLE, COMPUTE} state_t;
state_t state, next_state;

We need a counter for steps. Let parameter NUM_STEPS. We can compute that as:
localparam integer NUM_STEPS = ( (WIDTH & (WIDTH-1)) == 0 ) ? WIDTH : WIDTH+1;
But careful: WIDTH is a parameter, so we can do that.

We need registers:
logic [WIDTH-1:0] A; // remainder register.
logic [WIDTH-1:0] Q; // quotient register.
logic [WIDTH-1:0] dividend_reg; // to latch dividend.
logic [WIDTH-1:0] divisor_reg; // to latch divisor.
logic [NUM_STEPS-1:0] counter; // step counter.

We need a busy flag: logic busy.

We need a flag to indicate that the computation is in progress.

Algorithm in COMPUTE state:
If counter < NUM_STEPS:
   Get bit: if (counter < WIDTH) then bit = dividend_reg[WIDTH-1 - counter] else bit = 0.
   Then do: A = A << 1; then A[0] = bit.
   Then if (A >= divisor_reg) then
         A = A - divisor_reg;
         Q bit for current iteration = 1.
      else
         Q bit for current iteration = 0.
   Then counter++.
Else if counter == NUM_STEPS:
   End computation: set valid high for one cycle, then go to IDLE.

Also, state transition: In IDLE, if start is high and busy is false, then load inputs and set busy = 1, state = COMPUTE, counter = 0, A = dividend_reg, Q = 0.
In COMPUTE, do the iterations, then when done, output quotient = Q, remainder = A, and valid = 1 for one cycle, then busy = 0 and state = IDLE.

We need to handle asynchronous reset: if (!rst) then state = IDLE, busy = 0, counter = 0, A = 0, Q = 0, valid = 0, dividend_reg = 0, divisor_reg = 0.

I'll write the code accordingly.

I must output the file as plain text, saved in file rtl/restore_division.sv. So I'll output the code in plain text without markdown formatting.

I'll now produce the RTL code in SystemVerilog.

I'll use always_ff @(posedge clk or negedge rst) begin ... end for sequential logic.

I'll write a state machine with two states: IDLE and COMPUTE.

Define states:
localparam logic IDLE = 1'b0, COMPUTE = 1'b1; but better use an enum.

I'll define: typedef enum logic [0:0] {IDLE, COMPUTE} state_t; but then state is 1 bit. But I'll do: typedef enum {IDLE, COMPUTE} state_t; and then state_t state, next_state; But then I need to declare state variable as logic [1:0] maybe. I'll do: typedef enum logic [0:0] {IDLE=1'b0, COMPUTE=1'b1} state_t; That is one bit.

I'll then write combinational always block for next state logic.

I'll also write sequential always block for state update.

I'll also write always_ff for updating registers on posedge clk.

I'll write code as follows:

module restoring_division #(
    parameter WIDTH = 6
)(
    input  logic         clk,
    input  logic         rst,    // active low asynchronous reset
    input  logic         start,
    input  logic [WIDTH-1:0] dividend,
    input  logic [WIDTH-1:0] divisor,
    output logic [WIDTH-1:0] quotient,
    output logic [WIDTH-1:0] remainder,
    output logic          valid
);

    // Determine number of steps based on WIDTH
    localparam integer NUM_STEPS = ((WIDTH & (WIDTH-1)) == 0) ? WIDTH : WIDTH + 1;

    // State declaration
    typedef enum logic [0:0] {
        IDLE,
        COMPUTE
    } state_t;
    state_t state, next_state;

    // Internal registers
    logic [WIDTH-1:0] A;      // Remainder register
    logic [WIDTH-1:0] Q;      // Quotient register
    logic [WIDTH-1:0] dividend_reg;
    logic [WIDTH-1:0] divisor_reg;
    logic [NUM_STEPS-1:0] counter;
    logic busy;

    // Output assignment
    always_comb begin
        quotient = Q;
        remainder = A;
        valid = (state == IDLE && busy); // valid high when computation finished and in IDLE
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (start && !busy) begin
                    next_state = COMPUTE;
                end
            end
            COMPUTE: begin
                if (counter == NUM_STEPS) begin
                    next_state = IDLE;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // Sequential logic
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            busy <= 1'b0;
            counter <= {NUM_STEPS{1'b0}};
            A <= {WIDTH{1'b0}};
            Q <= {WIDTH{1'b0}};
            dividend_reg <= {WIDTH{1'b0}};
            divisor_reg <= {WIDTH{1'b0}};
        end else begin
            state <= next_state;
            if (state == IDLE) begin
                if (start && !busy) begin
                    // Latch new inputs
                    dividend_reg <= dividend;
                    divisor_reg <= divisor;
                    A <= dividend; // initialize remainder with dividend
                    Q <= {WIDTH{1'b0}};
                    counter <= 0;
                    busy <= 1'b1;
                end
            end else if (state == COMPUTE) begin
                if (counter < NUM_STEPS) begin
                    // Determine the dividend bit to shift in
                    logic [0:0] bit_in;
                    if (counter < WIDTH)
                        bit_in = dividend_reg[WIDTH-1 - counter];
                    else
                        bit_in = 1'b0;
                    
                    // Shift A left and insert bit_in at LSB
                    A <= (A << 1) | bit_in;
                    
                    // Check if A >= divisor_reg
                    if (A >= divisor_reg) begin
                        A <= A - divisor_reg;
                        // Set quotient bit for this iteration.
                        // The quotient bit position: MSB corresponds to iteration 0.
                        Q[WIDTH-1 - counter] <= 1'b1;
                    end else begin
                        // Do not subtract, quotient bit remains 0.
                        Q[WIDTH-1 - counter] <= 1'b0;
                    end
                    
                    counter <= counter + 1;
                end
                // When counter reaches NUM_STEPS, state will transition to IDLE in next cycle.
            end
        end
    end

endmodule