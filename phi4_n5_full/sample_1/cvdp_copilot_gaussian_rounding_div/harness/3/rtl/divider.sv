<think>We are asked: "Complete the divider RTL module given below to implement a non-restoring division for division. The divider module performs unsigned integer division of a given dividend by a given divisor and provides the resulting quotient and remainder. The design uses an iterative non-restoring division algorithm, controlled by a finite-state machine (FSM)." We are given a non-restoring algorithm details. The provided code is partial. We must complete the code.

We have a code snippet with module divider with parameter WIDTH=32, ports clk, rst_n, start, dividend, divisor, quotient, remainder, valid. We have state registers: state_reg, state_next. Also we have a register aq_reg with width AW+WIDTH (where AW = WIDTH+1) but check: AW is defined as WIDTH+1, then aq_reg is declared as [AW+WIDTH-1:0] which is (WIDTH+1+WIDTH-1) = 2*WIDTH bits. So aq_reg width is 2*WIDTH bits. But then we use the algorithm. The algorithm: non-restoring division algorithm. The algorithm steps: initialization: Q = dividend, A = 0, N = WIDTH. Then iterative steps for each bit.

Algorithm steps: we have register "aq" that is a concatenation of A and Q. But note that A is AW bits? Wait, let's check: in non-restoring division, we typically use A (accumulator) with one extra bit to hold sign. But the algorithm is for unsigned division. But they said non-restoring division for unsigned integer division. But non-restoring division algorithm is typically used for signed division. But here we are doing unsigned division using non-restoring division algorithm. The algorithm's steps:
- Step1: Initialize: Q = dividend, M = divisor, A = 0, N = number of bits in dividend.
- Step2: Check the sign bit of register A (MSB of A, which is bit AW -1, since A is AW bits). But A is sign bit? But for unsigned division, sign bit is not used. But algorithm given: "Check sign bit of register A". In non-restoring division, sign bit is used to decide addition or subtraction. But for unsigned division, the sign bit is 0 always initially. But algorithm: if sign bit is 1 then do A = A + M else A = A - M. But then step 3: shift left AQ by 1 bit, update Q[0] with sign bit. Actually algorithm: Step-2: Check sign bit of A. Then if it's 1, do A = A+M, else A = A-M. Then step3: shift left AQ by 1 bit, and update Q[0] with sign bit. But careful: The algorithm instructions: "Step-2: Check the sign bit of register A (MSB of register A which is treated as the signed bit). Step-3: If it is 1, shift left content of AQ and perform A = A+M, otherwise shift left AQ by 1 bit and perform A = A-M". Wait, check the provided algorithm: "Step-2: Check the sign bit of register A (MSB of the register A which is treated as the signed bit). Step-3: If it is 1, shift left content of AQ by 1 bit and perform A = A+M, otherwise shift left AQ by 1 bit and perform A = A-M". Wait, then "Step-4: Again check the sign bit of register A. Step-5: If sign bit is 1, Q[0] become 0 otherwise Q[0] become 1." But then we do shift left AQ and then update Q[0]. But the provided pseudo-code is a bit ambiguous. Let's re-read the provided algorithm steps:

Algorithm steps:

- Step-1: Initialize registers: Q = Dividend, M = Divisor, A = 0, N = number of bits in dividend.
- Step-2: Check the sign bit of register A (MSB of the register A which is treated as the signed bit).
- Step-3: If it is 1, shift left content of AQ (concatenation of A and Q) by 1 bit and perform A = A+M, otherwise shift left AQ by 1 bit and perform A = A-M (means add 2’s complement of M to A and store it to A)
- Step-4: Again check the sign bit of register A
- Step-5: If sign bit is 1, Q[0] become 0 otherwise Q[0] become 1 (Q[0] means least significant bit of register Q)
- Step-6: Decrements value of N by 1
- Step-7: If N is not equal to zero go to Step 2 otherwise go to next step
- Step-8: If sign bit of A is 1, then perform A = A+M
- Step-9: Register Q contains quotient and A contains remainder.

But the provided example for 11 ÷ 3 (4-bit example) shows iterations:
Iteration 1: 
- Start: A=0000, Q=1011, N=4.
- Operation: shift left AQ: becomes A=0001, Q=0110.
- Then perform operation: A = A - M = 0001 - 0011 = 1110.
- Check sign bit of A: 1. So then update Q[0] becomes 0. (So Q becomes 0110? But then they mention Q[0] become 0.)
- Decrement N: becomes 3.

Iteration 2:
- shift left AQ: A=1110, Q=0110 becomes A=1100, Q=1100.
- Operation: A = A + M = 1100 + 0011 = 1111.
- Check sign bit of A: 1, so update Q[0] becomes 0.
- Decrement N: becomes 2.

Iteration 3:
- shift left AQ: A=1111, Q=1100 becomes A=1111, Q=1000.
- Operation: A = A + M = 1111 + 0011 = 0010 (wrap-around arithmetic).
- Check sign bit of A: 0, so update Q[0] becomes 1.
- Decrement N: becomes 1.

Iteration 4:
- shift left AQ: A=0010, Q=1001 becomes A=0101, Q=0010.
- Operation: A = A - M = 0101 - 0011 = 0010.
- Check sign bit of A: 0, so update Q[0] becomes 1.
- Decrement N: becomes 0.

Final adjustment: if sign bit of A is 0, then no additional adjustment.
Final result: Q=0011, A=0010.

Wait, but the algorithm as described in the text and example is a bit confusing: It says "Check sign bit, then shift left and perform addition or subtraction, then again check sign bit and update Q[0]". But then in iteration, they perform shift left, then operation, then update Q[0]. But then the next iteration, the new A and Q are used.

Wait, re-read the given algorithm description carefully:

Algorithm:
1. Initialize registers.
2. Check sign bit of A.
3. If sign bit is 1, shift left AQ and perform A = A+M, otherwise shift left AQ and perform A = A-M.
4. Again check sign bit of A.
5. If sign bit is 1, Q[0] become 0, otherwise Q[0] become 1.
6. Decrement N.
7. If N != 0, go to Step 2.
8. If sign bit of A is 1, then perform A = A+M.
9. Q contains quotient and A contains remainder.

But the given example seems to do shift left, then operation, then check sign bit, then update Q[0]. But the provided pseudo-code in the example:
Iteration 1:
- After shift left: A=0001, Q=0110.
- Then perform A = A - M = 0001 - 0011 = 1110.
- Then check sign bit: sign bit of A = 1.
- Then update Q[0] becomes 0.
- Decrement N.

Iteration 2:
- After shift left: A=1100, Q=1100.
- Then perform A = A + M = 1100 + 0011 = 1111.
- Then check sign bit: sign bit of A = 1.
- Then update Q[0] becomes 0.
- Decrement N.

Iteration 3:
- After shift left: A=1111, Q=1000.
- Then perform A = A + M = 1111 + 0011 = 0010.
- Then check sign bit: sign bit of A = 0.
- Then update Q[0] becomes 1.
- Decrement N.

Iteration 4:
- After shift left: A=0101, Q=0010.
- Then perform A = A - M = 0101 - 0011 = 0010.
- Then check sign bit: sign bit of A = 0.
- Then update Q[0] becomes 1.
- Decrement N.

So the algorithm is: For each iteration:
- Pre-add/sub operation: shift left AQ.
- Then perform addition/subtraction based on the previous sign bit? But the algorithm says "check sign bit" before shifting left and performing addition/subtraction. But the provided example: In iteration 1, A initially is 0000. Check sign bit: 0. So then operation should be A = A - M. But they did A = A - M, which is consistent. But then after performing the operation, they check sign bit again and update Q[0]. But then in iteration 2, A is 1110, sign bit is 1, so then operation: A = A + M. So it appears that the decision for addition/subtraction is based on the sign bit of A after the shift-left and operation? But then they check sign bit again for updating Q[0]. But then in iteration 3, A becomes 1111 after shift left and operation, sign bit is 1, so operation: A = A + M, then check sign bit again and update Q[0]. But then in iteration 4, A becomes 0010 after shift left and operation, sign bit is 0, so operation: A = A - M, then update Q[0].

Wait, but the provided pseudo-code says:
Step-2: Check sign bit of register A.
Step-3: If it is 1, shift left AQ and perform A = A+M, otherwise shift left AQ and perform A = A-M.
Step-4: Again check sign bit of register A.
Step-5: If sign bit is 1, Q[0] become 0 otherwise Q[0] become 1.
Step-6: Decrement N.

So the algorithm is: 
- Use the sign bit of A before shifting to decide addition or subtraction? But the example: In iteration 1, A before shifting is 0000, sign bit = 0, so then shift left, then do subtraction. But then after operation, A becomes 1110, sign bit is 1, so then Q[0] becomes 0.
But then iteration 2: A before shifting is 1110, sign bit is 1, so then shift left, then do addition, so A becomes 1111, sign bit is 1, so Q[0] becomes 0.
Iteration 3: A before shifting is 1111, sign bit is 1, so then shift left, then do addition, so A becomes 0010, sign bit is 0, so Q[0] becomes 1.
Iteration 4: A before shifting is 0010, sign bit is 0, so then shift left, then do subtraction, so A becomes 0010, sign bit is 0, so Q[0] becomes 1.

This is consistent with the algorithm. So in our RTL, we need to implement the following per iteration:
- state: BUSY state.
- n_reg counts iterations. It starts at WIDTH.
- aq_reg holds A concatenated with Q. Initially, A = 0, Q = dividend. The width of A is AW = WIDTH+1 bits, Q is WIDTH bits, so aq is AW+WIDTH bits, but then we only use lower bits? Let's check: They declared aq_reg as [AW+WIDTH-1:0] which is (WIDTH+1+WIDTH) bits = 2*WIDTH+1 bits. But actually, maybe they intended A to be AW bits and Q to be WIDTH bits. But then aq is AW+WIDTH bits. But then initial value: A=0 (should be AW bits, but we only have AW bits? But they allocated AW+WIDTH bits, so we need to place A in the upper AW bits and Q in the lower WIDTH bits. But then the total width is AW+WIDTH. But AW is WIDTH+1, so total width is (WIDTH+1+WIDTH) = 2*WIDTH+1 bits. But then the algorithm uses shift left by 1 bit of AQ. But then after shifting, the new A is the top AW bits, and new Q is the lower WIDTH bits. And the new bit that comes in from the shift is the previous Q[0] (least significant bit) that we update. So the algorithm: In each iteration:
   - Determine operation: if (aq_reg[AW+WIDTH-1] is 1) then add M, else subtract M.
   - Then shift left AQ by 1 bit.
   - Then update Q[0] with the sign bit of A after the operation? Actually, the algorithm: "After performing the operation, check sign bit of A" and then update Q[0] accordingly. But in the example, the update of Q[0] is done after the operation and after shift left, not before. But the pseudo-code says: "Step-3: ... and then perform addition or subtraction". Then "Step-4: Again check sign bit of A" then "Step-5: If sign bit is 1, Q[0] becomes 0 else Q[0] becomes 1". So the procedure per iteration in RTL:
         op = (aq_reg[AW+WIDTH-1] == 1)? addition : subtraction.
         a = aq_reg[AW+WIDTH-1: WIDTH] (the A part) and q = aq_reg[WIDTH-1:0] (the Q part).
         Then new_a = (if op add: a + m, else a - m) but careful: subtraction means adding 2's complement of m. But m_reg is stored as divisor, but we need to do m = divisor. But in the algorithm, M is the divisor.
         Then shift left: new_aq = { new_a, q } shifted left by 1 bit? But then where does the new bit come from? It is the updated Q[0] bit which is the result of checking the sign bit of new_a. So:
            if (new_a[AW-1] == 1) then new_bit = 0 else new_bit = 1.
         Then new_aq = { new_a[AW-2:0], new_bit, q[WIDTH-1:1] } essentially.
         But careful: The algorithm: "shift left AQ by 1 bit". That means: new_a = { a[AW-2:0], q[WIDTH-1] }? Let's re-read: "shift left content of AQ by 1 bit" means that the concatenation A|Q is shifted left by one bit. The leftmost bit of A is the sign bit, then the next AW-1 bits of A, then Q bits. Shifting left by one bit means that the leftmost bit is dropped, and a new bit is inserted on the right. But the new bit that is inserted is determined by the sign bit of A after the arithmetic operation.
         Actually, the algorithm is: 
         - Let temp = aq_reg.
         - Operation: if sign bit of A is 1 then a = A + M, else a = A - M.
         - Then shift left: new_aq = { a[AW-1:0], q[WIDTH-1:0] } shifted left by 1 bit. But then the new LSB of Q becomes the sign bit of a? But the algorithm says: "update Q[0] with the sign bit of A". But careful: The algorithm says: "Again check the sign bit of register A. If sign bit is 1, Q[0] become 0 otherwise Q[0] become 1." So the new Q[0] is the complement of the sign bit of A? Because in iteration 1, A becomes 1110, sign bit is 1, so Q[0] becomes 0. In iteration 3, A becomes 0010, sign bit is 0, so Q[0] becomes 1. So rule: new Q[0] = ~ (sign bit of A). But then the shift left operation: When shifting left AQ by 1 bit, the new LSB of Q is what? 
         Let's simulate iteration 1 with our registers:
         Initially: A=0000 (5 bits, because AW = WIDTH+1 = 5 for WIDTH=4), Q=1011.
         aq = {A, Q} = {00000, 1011} = 000001011 (9 bits). But our register aq_reg width should be 2*WIDTH+1 = 9 bits, correct.
         Now iteration 1: Check sign bit of A: aq_reg[8] = 0.
         So op: A = A - M. M is 0011 (but extended to AW bits? Possibly M_reg is AW bits? They declared m_reg as [AW-1:0], so it is AW bits, so m_reg = 0000 0011 for WIDTH=4). So A = 00000 - 00000 0011 = 11101? Let's do binary arithmetic: 00000 - 00011 = (in 5-bit arithmetic) 11101, which is what the example said (1110, but wait, example said A becomes 1110, which is 4 bits, but here A is 5 bits, sign bit plus 4 bits. But then the example said A becomes 1110 which is 4 bits. Possibly we consider only the lower AW-1 bits of A for the algorithm, and the MSB is sign bit.)
         So then A becomes 11101 (5-bit). Then we check sign bit: sign bit = 1, so new Q[0] becomes 0.
         Then shift left: new AQ = { A[4:0] shifted left by 1 bit, new LSB = new Q[0] }? Let's simulate: A=11101, Q=1011 originally. Shifting left: The new A becomes the upper bits of previous A and Q[0]. But the algorithm says: "Shift left AQ by 1 bit and perform operation" but order: In the given example, they did: "Shift left AQ: A becomes 0001, Q becomes 0110" then operation A = A - M.
         Wait, re-read the example:
         Iteration 1: 
         "Shift Left AQ: A = 0000, Q = 1011 becomes A = 0001, Q = 0110"
         Then "Perform Operation: A = A - M = 0001 - 0011 = 1110"
         Then "Sign Bit of A: 1, so update Q[0] become 0".
         So the order is: first shift left, then perform arithmetic operation on A, then update Q[0] with the sign bit of the result.
         So in RTL, per iteration:
           - Extract current A and Q from aq_reg.
           - Pre-shift: new_aq_temp = aq_reg << 1. But careful: The shift left should incorporate the new bit from the previous operation result? But the algorithm order: 
             a) Shift left AQ by 1 bit. That means: new_A = { old_A[AW-2:0], old_Q[WIDTH-1] } and new_Q = { old_Q[WIDTH-2:0], ? } but then the ? is the bit we will update.
           - Then perform arithmetic on A. But the arithmetic operation is based on the original sign bit of A? But then the example: They did shift left first, then arithmetic. But then the arithmetic result is used to update Q[0].
           - But then the algorithm says: "Step-2: Check the sign bit of register A", then "Step-3: If it is 1, shift left AQ and perform A = A+M, otherwise shift left AQ and perform A = A-M". So the decision is taken from the original A before shifting.
           - But then after shifting, they perform the operation, and then update Q[0] based on the result of the operation.
           - So the sequence per iteration:
                temp_A = A (extracted from aq_reg, AW bits)
                temp_Q = Q (WIDTH bits)
                op = (temp_A[AW-1] == 1) ? add : subtract.
                new_A = (op ? (temp_A + m_reg) : (temp_A - m_reg))  // note: subtraction is done in AW bits arithmetic.
                // Then shift left AQ: new_AQ = { new_A[AW-1:0], temp_Q } shifted left by 1 bit? Wait, but the example: They did shift left first, then arithmetic. Let's re-read iteration 1 example carefully:
                "Shift Left AQ: A = 0000, Q = 1011 becomes A = 0001, Q = 0110"
                That means: new_A = { old_A[AW-2:0], old_Q[WIDTH-1] } and new_Q = { old_Q[WIDTH-2:0], ??? } But then they perform arithmetic on A: A = A - M, but they use the new A (which is the shifted result) for the arithmetic operation, not the old A.
                So the proper sequence: 
                   a) Shift left AQ. That means: new_aq = { aq_reg[AW+WIDTH-2 : WIDTH], aq_reg[WIDTH-1] } i.e. shift left by 1 bit.
                   b) Then perform arithmetic on the new A (the upper AW bits of new_aq) with m_reg: new_A = (if op add: new_A + m_reg, else new_A - m_reg) where op is determined from original A (or from new A? The algorithm says: "Step-2: Check sign bit of register A" before shifting. So op is determined by old A's sign bit).
                   c) Then update Q[0] of new_aq with the sign bit of new_A. That means: new_aq[WIDTH-1] becomes (new_A[AW-1] == 1 ? 0 : 1).
                   d) Then assign new_aq as the next state.
                   e) Decrement n.
         Let's simulate with iteration 1:
            Old A = 00000, Q = 1011.
            op = (old_A[4] = 0) so subtract.
            a) Shift left: new_aq = { aq_reg[8:5], aq_reg[4] } = { 0000, 1011? Let's compute: aq_reg is 9 bits: bits 8..0: 0 0 0 0 1 0 1 1? Actually, initial aq_reg = {A, Q} = {00000, 1011} = "000001011". Shifting left by 1: becomes "000010110". So new A = upper 5 bits of that = "00001" and new Q = lower 4 bits = "0110".
            b) Perform arithmetic on new A: new_A = new_A - m_reg. m_reg is 0011, but extended to 5 bits: 00011. So 00001 - 00011 = 11110? Let's compute: 1 - 3 in 5-bit arithmetic: 1 (binary 00001) - 3 (binary 00011) = (in two's complement, 00001 - 00011 = 11110) because 1 - 3 = -2 mod 16 = 14 decimal which is 1110 in binary, but in 5 bits it's 11110? Let's recalc: 1 - 3 = -2. Represented in 5 bits two's complement, -2 is 11110. So new A becomes 11110.
            c) Update Q[0] with sign bit of new_A: new_A[4] = 1, so new Q[0] becomes 0. So new_aq becomes: new A remains 11110, and Q becomes: original new Q was "0110", and we update LSB Q[0] = 0, so Q becomes "0110" with LSB unchanged? Wait, but the algorithm said: "Q[0] becomes 0" if sign bit is 1. But in our new Q, the bit that will be updated is the least significant bit. But in our new_aq, Q is bits [3:0]. We want to update bit 0 with the value (new_A[AW-1] == 1 ? 0 : 1). So new_aq[3:0] = { new_aq[3:1], new_bit }.
            So new Q becomes: "0" concatenated with "110" but we have 4 bits, so it becomes "0110" if new_bit is 0? Let's check: new Q originally from shift left is "0110", and we want to update Q[0] to 0. But it is already 0, so remains "0110". That matches the example: Q becomes 0110.
            d) Then aq_next = new_aq.
         Then iteration 2:
            Old A = 11110, Q = 0110.
            op = (old_A[4] = 1) so add.
            a) Shift left: new_aq = shift left of "11110110" (which is 9 bits) becomes "11101100"? Let's compute: "11110110" shifting left by 1: becomes "11101100" (top bit dropped, new LSB = old Q[0] which is 0). So new A = upper 5 bits = "11101", new Q = lower 4 bits = "1100".
            b) Perform arithmetic on new A: new_A = new_A + m_reg. m_reg is 00011. So 11101 + 00011 = 100000? Let's compute: 11101 (29 decimal) + 3 = 32 decimal, but in 5-bit arithmetic, 32 decimal is 100000 which is 5 bits, but we only have 5 bits, so it should wrap around: 29 + 3 = 32 mod 32 = 0, but in two's complement, 32 mod 32 = 0 with a carry out? Actually, wait, 5-bit arithmetic range is -16 to 15. 29 is not representable. Let's recalc properly: In 5-bit arithmetic, maximum positive is 15 (01111). But we are doing arithmetic on a signed number with 5 bits. So 11101 in 5-bit two's complement represents -7 (since 11101 = -7). Adding 3 gives -4 which in 5-bit two's complement is 10100. Let's compute: 11101 (which is -7) + 00011 (3) = 100000 in binary but that's 6 bits. But in 5-bit arithmetic, the sum is computed modulo 2^5. So 29 + 3 = 32, mod 32 = 0, but wait, 29 is not -7? Let's recalc two's complement: For 5-bit, the MSB is sign bit. 11101: if MSB is 1, then value = bitwise complement + 1 = (~11101 +1) = (000...)? Let's compute: 11101 in 5-bit, the positive value if interpreted as unsigned is 29, but as signed, it's -7 because 32 - 29 = 3. So 11101 represents -7. Then -7 + 3 = -4, which in 5-bit two's complement should be represented as: 10100 (which is 16 - 4 = 12, but 10100 in unsigned is 20, but as signed, 10100 = -12 because 32 - 20 = 12). Wait, let's recalc: For a 5-bit two's complement, the representation of -4 is: 2's complement of 4: 0000100, invert bits: 1111011, add 1 gives 1111100? That doesn't look right. Let's recalc properly:
            In n-bit two's complement, the representation of a negative number x is (2^n - |x|). For -4 in 5-bit, it should be 2^5 - 4 = 32 - 4 = 28, which in binary is 11100. So expected new_A = 11100.
            Let's do binary addition: 11101 + 00011.
            11101
          + 00011
          ------
            100000 (this is 6 bits) but then we take lower 5 bits: 00000. But that would give 0, which is not correct because -7 + 3 = -4.
            Wait, let's re-add: In 5-bit arithmetic, we have only 5 bits. We need to do mod 2^5 addition with wrap-around. The formula: result = (a + b) mod 2^5. For a = 29, b = 3, 29+3=32 mod 32 = 0, but that's if we treat them as unsigned. But as signed, we need to interpret 29 as -7. How to compute: (29 mod 32) + (3 mod 32) = 32 mod 32 = 0, but then interpret 0 as signed? That would be 0, but expected result is -4.
            There is confusion: In two's complement arithmetic, addition is performed modulo 2^n. But if we compute 29 + 3 mod 32, we get 32 mod 32 = 0. But 0 as a signed number is 0, not -4. So something is off. Let's recalc the addition with proper two's complement arithmetic:
            The operation: new_A = old_A + m_reg, where old_A is 5-bit two's complement.
            old_A = 11101. As a signed integer, that's -7.
            m_reg = 00011, as a signed integer, that's +3.
            So sum = -7 + 3 = -4.
            In 5-bit two's complement, -4 should be represented as: 2^5 - 4 = 32 - 4 = 28, which in binary (5 bits) is 11100.
            Let's add them manually in binary (with 5 bits):
            11101
          + 00011
          ------
            100000, but we only keep lower 5 bits: 00000. That seems to be what we got if we do unsigned addition mod 32. The problem is that 11101 (which is 29) plus 00011 (3) equals 32, and modulo 32 equals 0. But that's not how two's complement arithmetic works because the numbers are signed. Wait, check: In two's complement arithmetic, addition is performed modulo 2^n. So 29 + 3 = 32, mod 32 equals 0. But then how do we get -4? Because 29 is not -7 in 5-bit arithmetic? Let's recalc the conversion: In 5-bit two's complement, the MSB is sign. So if the MSB is 1, the value is computed as (2^5 - number). For 11101, the unsigned value is 29, so the signed value is 29 - 32 = -3? Wait, 29 - 32 = -3, not -7.
            Let's re-check: For a 5-bit two's complement, the range is -16 to 15. The MSB is bit 4. For a number with MSB = 1, the value = (unsigned_value - 32). So for 11101, unsigned_value = 29, so signed value = 29 - 32 = -3. But then iteration 1: A was 00000, so that's 0, then subtracting 3 gives -3, which would be represented as 32-3 = 29, i.e. 11101. That matches iteration 1: A becomes 11101, which as signed is -3, not -7. Let's re-read the example: They said A becomes 1110 in iteration 1. But for WIDTH=4, AW=5. They used 4-bit Q and 5-bit A. For dividend 1011 (11 decimal) and divisor 0011 (3 decimal). For 4-bit division, the range of A is 5 bits. Initially, A=00000 (0), Q=1011 (11). Then iteration 1: op determined by old A's sign bit: 0, so subtract: 00000 - 0011 (which is 3) = -3, which in 5-bit two's complement is 11101 (29). Then shift left: new A = { old A[3:0], old Q[3] } = { 0000, 1? Wait, let's simulate:
            initial aq = {A, Q} = {00000, 1011} = "000001011" (9 bits).
            Shift left by 1: becomes "000010110".
            So new A = upper 5 bits = "00001", new Q = lower 4 bits = "0110".
            Then perform arithmetic on new A: new A = new A - m_reg = 00001 - 0011 = 00001 - 0011 = (1 - 3) mod 32 = 30 mod 32? Let's compute: 1 - 3 = -2, which in 5-bit two's complement is 11110 (30 decimal). That matches example: A becomes 1110? But example said A becomes 1110 (which is 4 bits) but we are using 5 bits so it should be 11110. But the example printed only 4 bits for A, because maybe they dropped the sign bit for display. Possibly they display A without the sign bit? The algorithm says: "A contains remainder", and remainder is unsigned. So maybe we only care about the lower AW-1 bits of A after final adjustment. 
            In iteration 2: Now op is determined by new A's sign bit from previous iteration? But wait, the algorithm says op is determined by the sign bit of A before shifting. So in iteration 2, old A is 11110. Its sign bit is 1, so op = add.
            Then shift left: shift left of "11110110" becomes "11101100". So new A = upper 5 bits = "11101", new Q = lower 4 bits = "1100".
            Then perform arithmetic on new A: new A = new A + m_reg. m_reg is 0011 (3). So 11101 (which as signed is? 11101 in 5-bit: unsigned 29, signed = 29 - 32 = -3) plus 3 equals 0. But wait, 29 + 3 = 32 mod 32 = 0. So new A becomes 00000. That matches example: A becomes 1111? The example said A becomes 1111 in iteration 2. But wait, example iteration 2: They had A becomes 1111. Let's re-read example iteration 2:
            "Shift Left AQ: A = 1110, Q = 0110 becomes A = 1100, Q = 1100"
            Then "Perform Operation: A = A + M = 1100 + 0011 = 1111"
            So they expected A to become 1111 (which is 7 in decimal) not 00000. 
            There is discrepancy. Let's recalc iteration 2 using the algorithm from the example text:
            Iteration 2:
            Starting A = 1110 (from iteration 1 result, but they dropped the MSB maybe?) and Q = 0110.
            They did: Shift left: A=1110, Q=0110 becomes A=1100, Q=1100.
            Then perform operation: A = A + M = 1100 + 0011 = 1111.
            In our simulation with 5-bit numbers:
            After iteration 1, we got A = 11110 and Q = 0110. But maybe the algorithm in the example is working with 4-bit A (not 5-bit) for the arithmetic part. Because for unsigned division, we typically use A with one extra bit for sign, but then the remainder is taken from the lower bits of A. In many divider designs, A is actually AW bits where AW = WIDTH+1. And then after the algorithm, if A is negative (i.e., MSB = 1), then you add M to correct it. 
            So final adjustment: if A[AW-1] == 1 then A = A + M.
            So maybe in our RTL, we store A in AW bits and Q in WIDTH bits, and then in DONE state, if A[AW-1] is 1, then A = A + M.
            So our arithmetic should be done in AW bits. But then our addition/subtraction should be done on AW-bit numbers. But our m_reg is AW bits as well. So that's fine.
            Let's re-simulate with AW=5:
            Iteration 1:
             old A = 00000, Q = 1011.
             op = (old A[4]==0) so subtract.
             Shift left: new_aq = { old A[3:0], old Q[3] }? Let's define: aq = { A (5 bits), Q (4 bits) } = 9 bits.
             Shifting left by 1: new_aq = aq << 1, i.e. bits [8:0] becomes [7:0] with MSB dropped and LSB = 0.
             So new A = aq[8:4] = { old A[3:0], old Q[3] }.
             new Q = aq[3:0] = { old Q[2:0], ? } but then we update Q[0] with the sign bit of the arithmetic result.
             Let's compute: aq initially = 00000 1011 (bits 8..0: 0,0,0,0,0, 1,0,1,1).
             Shift left: becomes 00001 0110 (bits 8..0: 0,0,0,0,1, 0,1,1,0).
             So new A = 00001, new Q = 0110.
             Then perform arithmetic: new_A = new_A - m_reg. m_reg = divisor extended to 5 bits = 00011.
             00001 - 00011 = (1 - 3) mod 32 = 30, which in 5-bit is 11110.
             Then update Q[0] with sign bit of new_A: new_A[4] = 1, so Q[0] becomes 0. So new Q becomes: take current new Q (0110) and replace LSB with 0: That yields 0110 (since LSB is already 0).
             So aq_next = { new_A, new_Q } = { 11110, 0110 } = 111100110 (9 bits).
             So after iteration 1: A = 11110, Q = 0110, n = 3.
            Iteration 2:
             old A = 11110, Q = 0110.
             op = (old A[4]==1) so add.
             Shift left: shift left of 111100110 (9 bits) becomes: 11100110? Let's do: 111100110 << 1 = 11100110? Let's compute bit positions:
                 original: bit8:1, bit7:1, bit6:1, bit5:1, bit4:0, bit3:0, bit2:1, bit1:1, bit0:0.
                 Shift left: bit8 becomes old bit7 = 1, bit7 becomes old bit6 = 1, bit6 becomes old bit5 = 1, bit5 becomes old bit4 = 0, bit4 becomes old bit3 = 0, bit3 becomes old bit2 = 1, bit2 becomes old bit1 = 1, bit1 becomes old bit0 = 0, bit0 becomes 0.
                 So new aq = 11100110? Wait, let's recalc properly:
                 aq = 9 bits: b8 b7 b6 b5 b4 b3 b2 b1 b0 = 1,1,1,1,0,0,1,1,0.
                 Shift left by 1: result: b8' = b7 = 1, b7' = b6 = 1, b6' = b5 = 1, b5' = b4 = 0, b4' = b3 = 0, b3' = b2 = 1, b2' = b1 = 1, b1' = b0 = 0, b0' = 0.
                 So new aq = 11100110? But that's 8 bits, we need 9 bits. Actually, when shifting left by 1 in a fixed width register, the MSB is shifted out and a 0 is appended at LSB. So new aq becomes: 1,1,1,0,0,1,1,0,0 which is 111001100 in binary (9 bits). 
                 Then new A = upper 5 bits = bits 8..4 = 11100, new Q = lower 4 bits = bits 3..0 = 1100.
             Then perform arithmetic: new_A = new_A + m_reg = 11100 + 00011.
             Let's add: 11100 (which is binary for unsigned 28, but as signed, 11100 means 28 - 32 = -4) plus 00011 (3) equals 11100 + 00011 = 11111? Let's add: 11100 + 00011 = 11111 (if no overflow) because 28 + 3 = 31. In 5-bit, 31 is represented as 11111. So new_A becomes 11111.
             Then update Q[0] with sign bit of new_A: new_A[4] = 1, so Q[0] becomes 0. So new Q becomes: take current new Q (1100) and replace LSB with 0, resulting in 1100 (LSB already 0).
             So aq_next = { new_A, new_Q } = { 11111, 1100 } = 111111100 (9 bits).
             So after iteration 2: A = 11111, Q = 1100, n = 2.
            Iteration 3:
             old A = 11111, Q = 1100.
             op = (old A[4]==1) so add.
             Shift left: shift left of 111111100 becomes: 
                aq = 111111100 (9 bits): bits: 1,1,1,1,1,1,1,0,0.
                Shift left: becomes: 1,1,1,1,1,1,0,0,0 (9 bits) because the MSB is 1, then next bits: 1,1,1,1,1, then bit? Let's do: 
                   new A = upper 5 bits = bits 8..4 = 11111, new Q = lower 4 bits = bits 3..0 = 1000? Let's recalc:
                   aq = 111111100, shifting left: result = 111111000 (because the leftmost bit becomes dropped, then append 0).
                   So new A = 11111, new Q = 1000.
             Then perform arithmetic: new_A = new_A + m_reg = 11111 + 00011.
             11111 (unsigned 31, as signed 31 - 32 = -1) plus 3 equals 11111 + 00011 = 100010? Let's add: 31 + 3 = 34 mod 32 = 2. In 5-bit, 2 is represented as 00010.
             So new_A becomes 00010.
             Then update Q[0] with sign bit of new_A: new_A[4] = 0, so Q[0] becomes 1. So new Q becomes: take current new Q (1000) and replace LSB with 1, resulting in 1001.
             So aq_next = { new_A, new_Q } = { 00010, 1001 } = 000101001 (9 bits).
             So after iteration 3: A = 00010, Q = 1001, n = 1.
            Iteration 4:
             old A = 00010, Q = 1001.
             op = (old A[4]==0) so subtract.
             Shift left: shift left of 000101001 becomes: 
                aq = 000101001 (9 bits): bits: 0,0,0,1,0,1,0,0,1.
                Shift left: becomes: 000101001 << 1 = 00101001? Let's do: new A = upper 5 bits = bits 8..4 of result, new Q = lower 4 bits.
                Let's compute: shifting left: result = 000101001 << 1 = 001010010 (9 bits) because:
                   bit8 becomes old bit7 = 0, bit7 becomes old bit6 = 0, bit6 becomes old bit5 = 1, bit5 becomes old bit4 = 0, bit4 becomes old bit3 = 1, bit3 becomes old bit2 = 0, bit2 becomes old bit1 = 0, bit1 becomes old bit0 = 1, bit0 becomes 0.
                So new A = 00101, new Q = 0100? Wait, need to be careful: new A = bits [8:4] of result = 00101, new Q = bits [3:0] = 0100.
             Then perform arithmetic: new_A = new_A - m_reg = 00101 - 00011.
             00101 (which is 5 decimal) minus 00011 (3 decimal) equals 00110 (binary 6).
             Then update Q[0] with sign bit of new_A: new_A[4] = 0, so Q[0] becomes 1. So new Q becomes: take current new Q (0100) and replace LSB with 1, resulting in 0101.
             So aq_next = { new_A, new_Q } = { 00110, 0101 } = 001100101 (9 bits).
             So after iteration 4: A = 00110, Q = 0101, n = 0.
            Final adjustment:
             In DONE state, if A[AW-1] is 1 then A = A + m_reg, else no adjustment. Here A = 00110, MSB = 0, so no adjustment.
             Final quotient Q = 0101 (which is 5 decimal) and remainder A = 00110 (6 decimal).
             But expected result from example: Quotient = 3 and remainder = 2. 
             Our simulation yields quotient = 0101 (5) and remainder = 6. That is not matching.
             
             Let's re-read the provided example in the problem statement:
             "Final Result: Quotient (Q) = 0011 (3 in decimal)
              Remainder (A) = 0010 (2 in decimal)"
             And the steps:
             Iteration 1: Q becomes 0 at bit position, result A becomes 1110.
             Iteration 2: Q becomes 0, A becomes 1111.
             Iteration 3: Q becomes 1, A becomes 0010.
             Iteration 4: Q becomes 1, A becomes 0010.
             So final Q = 0011 and A = 0010.
             
             Our simulation with AW=5 gave different results. It seems the algorithm in the example might be using 4-bit A (i.e., A has same width as Q) and then the operation is performed with an extra bit borrowed from Q? Or maybe the arithmetic is done on A as if it were unsigned and then sign bit is interpreted in a different way.
             
             Let's try to simulate the given example using 4-bit A. Possibly the algorithm is implemented with A being WIDTH bits (not WIDTH+1). But then the FSM uses AW = WIDTH+1 for concatenation. 
             In the provided code, they define AW = WIDTH + 1. So they assume A is AW bits. But the algorithm example might be using a different convention.
             
             Alternatively, maybe our interpretation of the operations order is off. Let's re-read the provided algorithm steps carefully:

             "Step-1: Initialize: Q = Dividend, M = Divisor, A = 0, N = number of bits in dividend.
              Step-2: Check the sign bit of register A (MSB of the register A which is treated as the signed bit).
              Step-3: If it is 1, shift left content of AQ by 1 bit and perform A = A+M, otherwise shift left AQ by 1 bit and perform A = A-M (means add 2’s complement of M to A and store it to A)
              Step-4: Again check the sign bit of register A
              Step-5: If sign bit is 1, Q[0] become 0 otherwise Q[0] become 1 (Q[0] means least significant bit of register Q)
              Step-6: Decrements value of N by 1
              Step-7: If N is not equal to zero go to Step 2 otherwise go to next step
              Step-8: If sign bit of A is 1, then perform A = A+M
              Step-9: Register Q contains quotient and A contains remainder."

             According to this, the arithmetic operation (A = A+M or A = A-M) is performed after shifting left AQ. And the decision for addition or subtraction is taken from the sign bit of A before shifting.
             So sequence per iteration:
                temp = aq_reg;
                op = (temp[AW+WIDTH-1] ? 1 : 0) ; // if MSB of A is 1 then add, else subtract.
                Then shift left: new_aq = temp << 1; 
                Then perform arithmetic on A part of new_aq: new_A = (op ? (new_aq[AW+WIDTH-1:WIDTH] + m_reg) : (new_aq[AW+WIDTH-1:WIDTH] - m_reg)).
                Then update Q[0] of new_aq with the sign bit of new_A: new_bit = (new_A[AW-1] == 1 ? 0 : 1).
                Then replace the LSB of Q in new_aq with new_bit.
                Then aq_next = new_aq with updated LSB of Q.
                Decrement n.
                
             Let's simulate with that order using 4-bit division example, but using AW = 5 bits for A and WIDTH=4 for Q.
             Iteration 1:
                aq_reg initially = {A, Q} = {00000, 1011} = 000001011.
                op = check sign bit of A from aq_reg: aq_reg[8] = 0, so op = subtract.
                Shift left: new_aq = aq_reg << 1 = 000010110.
                Now new A (upper 5 bits) = 00001, new Q (lower 4 bits) = 0110.
                Perform arithmetic: new_A = new_A - m_reg. m_reg = divisor extended to 5 bits = 00011.
                00001 - 00011 = (1 - 3) mod 32 = 30, which in 5 bits is 11110.
                Then update Q[0] with sign bit of new_A: new_A[4] = 1, so new Q[0] becomes 0.
                So new_aq becomes: A = 11110, Q = (with LSB replaced by 0) = 0110 (since LSB already 0).
                So aq_next = 111100110.
                n becomes 3.
             Iteration 2:
                aq_reg = 111100110.
                op = check sign bit of A from aq_reg: aq_reg[8] = 1, so op = add.
                Shift left: new_aq = 111100110 << 1 = 111001100? Let's compute: 111100110 << 1 = 111001100 (9 bits) because the MSB becomes dropped, and LSB becomes 0.
                New A = upper 5 bits = 11100, new Q = lower 4 bits = 1100.
                Perform arithmetic: new_A = new_A + m_reg = 11100 + 00011.
                11100 (unsigned 28, as signed = 28-32 = -4) + 00011 (3) = 28 + 3 = 31 mod 32 = 31, which in 5 bits is 11111.
                Then update Q[0] with sign bit of new_A: new_A[4] = 1, so new Q[0] becomes 0.
                So new_aq becomes: A = 11111, Q = 1100.
                So aq_next = 111111100.
                n becomes 2.
             Iteration 3:
                aq_reg = 111111100.
                op = check sign bit of A from aq_reg: aq_reg[8] = 1, so op = add.
                Shift left: new_aq = 111111100 << 1 = 111111000 (9 bits).
                New A = upper 5 bits = 11111, new Q = lower 4 bits = 1000.
                Perform arithmetic: new_A = new_A + m_reg = 111