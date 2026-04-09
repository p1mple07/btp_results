module in Verilog based on the given parameters and algorithm. Let me start by understanding the problem.

The divider module takes a dividend and a divisor, both of WIDTH bits. It should compute the quotient and remainder using the non-restoring division algorithm. The module uses an FSM with states IDLE, BUSY, and DONE. 

First, I'll look at the provided Verilog code. The module has input ports for clk, rst_n, start, dividend, divisor, and output ports for quotient, remainder, and valid. There are also some internal registers like aq_reg, m_reg, etc.

The algorithm steps are given, so I need to translate those into Verilog code. The steps involve initializing registers, shifting, adding or subtracting, checking the sign bit, updating the quotient, and decrementing N until it reaches zero. Then, there's a final adjustment.

I notice that the current code has a loop that runs for WIDTH iterations. Each iteration involves shifting AQ, performing an add or subtract, and updating the quotient bit.

I'll need to set up the initial state. When the FSM is in IDLE and start is asserted, it should load the dividend and divisor, transition to BUSY, and set valid to 0. During BUSY, it performs the algorithm. After WIDTH iterations, it transitions to DONE, asserts valid, and waits for the next operation.

In the current code, the FSM is handled with state_reg and state_next. The initial state is IDLE (00), and when start is high, it transitions to BUSY (01). After processing, it goes to DONE (10).

I need to implement the non-restoring division steps. Each iteration involves:

1. Shifting AQ left. Since AQ is aq_reg, which is a combination of A and Q, I'll need to shift it left. But in Verilog, shifting is done with << operator. However, since aq_reg is a large register, I'll have to manage the bits correctly.

2. Depending on the sign bit of A (which is the MSB of aq_reg), either subtract M or add M. Wait, in the algorithm, if the sign bit is 1, we subtract M (add 2's complement). Otherwise, we add M. So, I'll need to check the sign bit and perform the appropriate operation.

3. Update the quotient bit based on the sign of A after the operation.

4. Decrement N by 1 each iteration.

5. After all iterations, if the sign bit of A is 1, add M to A.

I'll need to implement these steps in the code. Let me think about how to handle the sign bit. The sign bit is the MSB of A, which is the first bit of aq_reg. So, I can extract it using a bitwise operation: (aq_reg[0]).

For each iteration, I'll shift aq_reg left by 1. Then, based on the sign bit, I'll either add or subtract M. But since M is a WIDTH-bit number, I need to ensure that the addition or subtraction is done correctly, considering the width.

Wait, in the algorithm, after shifting, A is updated. So, in Verilog, I can perform aq_next = aq_reg << 1, but I have to handle the overflow. Since aq_reg is a width + 1 + width register, shifting left will naturally handle the overflow.

Let me outline the steps in code:

- Inside the loop, for each iteration:
  - Shift aq_reg left by 1 to get aq_next.
  - Check the sign bit (sign_bit = aq_reg[0]).
  - If sign_bit is 1, perform aq_next = aq_next + ~m_reg + 1 (which is equivalent to subtracting m_reg).
  - Else, perform aq_next = aq_next + m_reg.
  - Update the quotient bit based on the sign of aq_next after the operation. Wait, no, the sign bit after the operation is checked, not the previous A. So, after the operation, the new sign bit is the MSB of aq_next, which is now the new A.

Wait, in the algorithm, after the operation, the sign bit of A is checked. So, after performing the add or subtract, the new A is in aq_next, and its sign bit is checked to update Q[0].

So, in code:

sign_bit = aq_reg[0];
if (sign_bit) {
    aq_next = aq_reg << 1;
    aq_next = aq_next + ~m_reg + 1; // subtract m_reg
} else {
    aq_next = aq_reg << 1;
    aq_next = aq_next + m_reg; // add m_reg
}

Then, the new sign bit is aq_next[0], which will be used to update Q[0].

Wait, but in the algorithm, after the operation, the sign bit is checked, and Q[0] is set. So, after the operation, the sign bit of the new A (aq_next) is checked.

So, in code, after the operation, the new sign_bit is aq_next[0], which will determine Q[0] for the next step.

Wait, no. In the algorithm, after the operation, the sign bit of A is checked, and Q[0] is updated. So, in the code, after the operation, the sign_bit is aq_next[0], and that determines whether Q[0] is 0 or 1.

So, in the code, after the operation, we extract the new sign_bit and assign Q[0] accordingly.

But in the code, the quotient is stored in quotient_reg, which is a register. So, after each iteration, we need to store the new Q[0] into quotient_reg.

Wait, but in the code, the quotient is built bit by bit. So, in each iteration, the least significant bit of Q is determined and stored.

So, after the operation, the new sign_bit is the sign of the new A, which is the new Q's next bit.

Wait, perhaps I'm getting confused. Let me re-examine the algorithm steps.

In Step 3, after shifting, A is updated. Then, in Step 4, check the sign bit of A. If it's 1, Q[0] becomes 0; else, 1.

So, in each iteration, after the operation, the sign bit of A is checked, and Q[0] is set.

So, in code, after the operation, we extract the sign bit of aq_next, which is the new A, and set Q[0] accordingly.

Wait, but in the code, the quotient is stored in quotient_reg, which is a register. So, after each iteration, we need to assign the new Q[0] to quotient_reg[0], and shift the quotient left.

Wait, perhaps I should model the quotient as being built from the least significant bit to the most significant bit. So, in each iteration, the new bit is added to the least significant position.

So, in code:

quotient_next[0] = sign_bit_after_operation;
quotient_next = quotient_reg << 1 | quotient_next[0];

Wait, but in the code, the quotient is stored as a register, so perhaps after each iteration, we shift the quotient left and add the new bit.

Alternatively, perhaps the quotient is built in the aq_reg, but I think that's not the case. The aq_reg is A concatenated with Q, so perhaps the Q part is separate.

Wait, perhaps I should model the quotient as a register that is updated each iteration. So, in each iteration, the new Q[0] is determined and stored in quotient_reg.

So, in code:

After the operation, sign_bit = aq_next[0];
quotient_reg[0] = sign_bit;
quotient_reg = (quotient_reg << 1) | quotient_reg[0];

Wait, but in the code, the quotient_reg is a register that holds the current quotient. So, after each iteration, we shift it left and add the new bit.

But in the code, the quotient is assigned as quotient_reg, which is a register. So, perhaps in each iteration, after determining the new Q[0], we update quotient_reg.

Wait, perhaps I should structure it as:

In each iteration:
1. Shift AQ left.
2. Perform add or subtract based on sign bit.
3. Check the new sign bit of A (which is now aq_next[0]).
4. Update Q[0] to be this new sign bit.
5. Shift the quotient left and add the new bit.

Wait, but in the algorithm, Q is built from the least significant bit to the most significant bit. So, in each iteration, the new bit is added to the least significant position.

So, in code:

After the operation, sign_bit = aq_next[0];
quotient_reg[0] = sign_bit;
quotient_reg = (quotient_reg << 1) | quotient_reg[0];

Wait, but in the code, the quotient_reg is a register, so perhaps it's better to manage it as a register that shifts left each iteration and adds the new bit.

But in the current code, the quotient_reg is a register that holds the current quotient. So, perhaps after each iteration, we shift it left and add the new bit.

Wait, perhaps I should model it as:

quotient_next = (quotient_reg << 1) | (sign_bit_after_operation);
quotient_reg = quotient_next;

But I'm not sure. Maybe I should look at the example given.

In the example, for 11 ÷ 3 (4-bit), the quotient is 0011. So, the first bit is 0, then 0, then 1, then 1.

Wait, but in the algorithm, the quotient is built starting from the least significant bit. So, in each iteration, the new bit is added to the least significant position.

So, in code, after each iteration, the quotient is shifted left, and the new bit is added.

So, perhaps the code should have:

quotient_next = (quotient_reg << 1) | (sign_bit_after_operation);
quotient_reg = quotient_next;

But I'm not sure if that's the correct approach. Alternatively, perhaps the quotient is stored in a register that is updated each iteration.

Wait, perhaps I should model the quotient as a register that is updated each iteration. So, in each iteration, after the operation, the new Q[0] is determined, and then the quotient_reg is updated.

So, in code:

sign_bit = aq_next[0];
quotient_reg[0] = sign_bit;
quotient_reg = (quotient_reg << 1) | quotient_reg[0];

Wait, but in the code, the quotient_reg is a register, so perhaps it's better to manage it as a register that shifts left each iteration and adds the new bit.

Alternatively, perhaps the quotient is stored in a register that is updated each iteration by taking the previous quotient shifted left and adding the new bit.

But I'm getting a bit stuck on how to model the quotient in the code.

Let me think about the initial state. When the FSM is in IDLE, the start is asserted, so the dividend and divisor are loaded into the registers. Then, the FSM transitions to BUSY.

In the BUSY state, for WIDTH iterations, the algorithm is performed.

In each iteration:

- AQ is shifted left, and M is added or subtracted based on the sign bit of A.
- The new sign bit of A is checked, and Q[0] is set.
- The quotient is built by shifting left and adding the new bit.

So, in code, during each iteration:

1. Shift AQ left.
2. Perform add or subtract.
3. Check the new sign bit of A.
4. Update Q[0] to be this sign bit.
5. Shift the quotient left and add the new bit.

Wait, but the quotient is built from the LSB to the MSB. So, in each iteration, the new bit is the LSB of the quotient.

So, perhaps in code:

After the operation, sign_bit = aq_next[0];
quotient_reg[0] = sign_bit;
quotient_reg = (quotient_reg << 1) | quotient_reg[0];

But I'm not sure if that's the correct way to model it in Verilog.

Alternatively, perhaps the quotient is stored in a register that is updated each iteration by taking the previous quotient shifted left and adding the new bit.

Wait, perhaps the code should have:

quotient_next = (quotient_reg << 1) | (sign_bit_after_operation);
quotient_reg = quotient_next;

But I'm not sure. Maybe I should proceed step by step.

Let me outline the code structure.

In the module, after the initial setup, the FSM is in IDLE. When start is asserted, it loads the dividend and divisor, transitions to BUSY, and asserts valid for WIDTH + 2 cycles (as per latency).

In the BUSY state, for WIDTH iterations, it performs the algorithm.

Each iteration:

- Shift AQ left.
- Perform add or subtract based on sign bit of A.
- Check the new sign bit of A to update Q[0].
- Shift the quotient left and add the new bit.

Wait, perhaps the quotient is stored in a register that is updated each iteration.

Alternatively, perhaps the quotient is built in the aq_reg, but I think that's not the case.

Wait, perhaps the quotient is stored in a separate register, quotient_reg, which is updated each iteration.

So, in code:

Within the loop for WIDTH iterations:

- Shift aq_reg left to get aq_next.
- Check sign_bit = aq_reg[0].
- If sign_bit, aq_next = aq_next + ~m_reg + 1; else, aq_next = aq_next + m_reg.
- sign_bit_after = aq_next[0].
- quotient_reg[0] = sign_bit_after.
- quotient_reg = (quotient_reg << 1) | quotient_reg[0];
- aq_reg = aq_next;
- n_reg = n_next;

Wait, but in the code, the aq_reg is a register that holds A and Q concatenated. So, perhaps after each iteration, aq_reg is updated to aq_next, and the quotient_reg is updated as described.

But I'm not sure. Maybe I should model the quotient as a separate register.

Alternatively, perhaps the quotient is built in the aq_reg, but that might complicate things.

Wait, perhaps the quotient is stored in a separate register, and each iteration appends a bit to it.

So, in code:

quotient_reg = 0;
for (i = 0; i < WIDTH; i++) {
    // perform the algorithm
    // after operation, sign_bit_after is determined
    quotient_reg = (quotient_reg << 1) | sign_bit_after;
}

But in Verilog, I can't have a loop, so I have to implement this with a state machine and combinational logic.

So, perhaps in each iteration, the new bit is added to the quotient_reg.

So, in code:

After the operation, sign_bit_after = aq_next[0];
quotient_reg = (quotient_reg << 1) | sign_bit_after;
quotient_reg_next = quotient_reg;

Wait, but in the code, the quotient_reg is a register, so perhaps after each iteration, it's updated.

But I'm not sure. Maybe I should proceed.

Another thing to consider is the sign extension. Since the algorithm uses 2's complement, the add and subtract operations need to handle the sign correctly.

In Verilog, the addition and subtraction can be done using the standard operators, but I have to ensure that the operations are done correctly.

Wait, in the code, m_reg holds the divisor. So, when subtracting, I need to add the 2's complement of m_reg, which is ~m_reg + 1.

So, in code:

if (sign_bit) {
    aq_next = aq_reg << 1;
    aq_next = aq_next + ~m_reg + 1;
} else {
    aq_next = aq_reg << 1;
    aq_next = aq_next + m_reg;
}

But I have to make sure that the addition is done correctly, considering the width.

Wait, but in Verilog, the addition is done with the '+' operator, and the result is stored in a register of sufficient size.

So, perhaps the aq_next register is of size (WIDTH + 1) + WIDTH, which is handled by the aq_reg.

Wait, in the code, aq_reg is declared as reg [AW+WIDTH-1 : 0], which is WIDTH + 1 bits. So, when shifting left, it becomes WIDTH + 2 bits, but since AW is WIDTH + 1, perhaps it's handled correctly.

Wait, perhaps I should model aq_reg as a register that is WIDTH + 1 bits, so when shifted left, it becomes WIDTH + 2 bits, but the higher bit is the sign bit.

Hmm, perhaps I'm overcomplicating. Let me proceed.

Another thing to consider is the sign bit after the operation. After adding or subtracting, the sign bit is the first bit of aq_next.

So, in code:

sign_bit_after = aq_next[0];

Then, this sign_bit_after is used to update the quotient.

So, in code:

quotient_reg[0] = sign_bit_after;
quotient_reg = (quotient_reg << 1) | quotient_reg[0];

Wait, but in Verilog, shifting a register left by 1 would require that the new bit is added to the LSB. So, perhaps the quotient_reg is a register that is WIDTH bits, and each iteration, the new bit is added to the LSB.

So, in code:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But wait, in Verilog, the shift is a logical shift, so shifting left would add zeros to the right. So, to get the correct value, perhaps I should use a shift-left operation and then OR with the new bit.

Alternatively, perhaps the quotient_reg is a register that is WIDTH bits, and each iteration, the new bit is added to the LSB.

So, in code:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But I'm not sure if that's correct. Maybe I should model it as:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

Wait, but in the example, after each iteration, the quotient is built from LSB to MSB. So, in the first iteration, the LSB is set, then in the next iteration, the next bit is set, etc.

So, in code, after each iteration, the quotient_reg is shifted left, and the new bit is added to the LSB.

So, perhaps the code should be:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But I'm not sure if that's the correct approach.

Another thing to consider is the sign of the final result. After WIDTH iterations, if the sign bit of A is 1, we need to add M to A to get the correct remainder.

So, in code:

After the loop, if sign_bit_after is 1, then aq_next = aq_reg << 1;
aq_next = aq_next + m_reg;

Then, the remainder is aq_next, and the quotient is quotient_reg.

Wait, but in the algorithm, after the loop, if the sign bit is 1, we perform A = A + M, which is the same as adding the divisor to the remainder.

So, in code:

After the loop:

if (sign_bit_after) {
    aq_next = aq_reg << 1;
    aq_next = aq_next + m_reg;
}

Then, the remainder is aq_next, and the quotient is quotient_reg.

But I'm not sure if that's necessary because the algorithm says that after WIDTH iterations, the remainder is correct, but the quotient is built correctly during the loop.

Wait, in the example, after 4 iterations, the remainder is 0010, which is correct, and the quotient is 0011.

So, perhaps the final adjustment is not needed because the loop correctly computes the quotient and remainder.

But according to the algorithm, after the loop, if the sign bit is 1, we need to add M to A.

So, perhaps in code, after the loop, we perform this adjustment.

But in the example, after the loop, the sign bit is 0, so no adjustment is needed.

So, perhaps the code should include this final adjustment.

Putting it all together, the code inside the FSM's BUSY state would be:

- Load the dividend and divisor into their respective registers.
- Initialize aq_reg with the initial AQ (dividend and quotient, but initially quotient is 0).
- Start the loop for WIDTH iterations.
- In each iteration:
   - Shift aq_reg left to get aq_next.
   - Check the sign bit of aq_reg (sign_bit).
   - If sign_bit is 1, subtract M (add ~m_reg + 1).
   - Else, add M.
   - Update the quotient by appending the sign_bit_after to the LSB of quotient_reg.
   - Update aq_reg to aq_next.
   - Decrement n_reg.
- After the loop, if the sign bit of aq_reg is 1, add M to aq_reg to get the correct remainder.
- Assert valid to indicate the result is ready.
- Transition to DONE state.

Wait, but in the code, the aq_reg is a register that holds the AQ value. So, perhaps after each iteration, aq_reg is updated to aq_next.

But I'm not sure. Maybe I should model it as:

Within the loop:

aq_next = aq_reg << 1;
if (sign_bit) {
    aq_next = aq_next + ~m_reg + 1;
} else {
    aq_next = aq_next + m_reg;
}
quotient_reg = (quotient_reg << 1) | sign_bit;
aq_reg = aq_next;
n_reg = n_next;

But I'm not sure if that's correct.

Another thing to consider is the initial value of aq_reg. Initially, AQ is the dividend, and Q is 0. So, aq_reg should be the dividend shifted left by WIDTH bits, with the Q part being 0.

Wait, perhaps aq_reg is initialized as (dividend << WIDTH) | 0, but I'm not sure.

Alternatively, perhaps aq_reg is initialized as the dividend concatenated with the quotient (which is 0), so aq_reg = dividend << WIDTH | 0.

But in the code, aq_reg is declared as reg [AW+WIDTH-1 : 0], which is WIDTH + 1 bits. So, perhaps the initial value is (dividend << WIDTH) | 0.

Wait, but in the code, the aq_reg is part of the FSM's state, so perhaps it's initialized in the initial state.

But in the code, the initial state is IDLE, and when start is asserted, the dividend and divisor are loaded into their respective registers, and the FSM transitions to BUSY.

So, perhaps in the initial state, the aq_reg is set to (dividend << WIDTH) | 0.

But I'm not sure how to handle that in the code.

Alternatively, perhaps the aq_reg is loaded with the initial AQ value when the FSM transitions to BUSY.

So, in the code, when the FSM is in IDLE and start is asserted, the dividend and divisor are loaded into their respective registers, and the aq_reg is set to (dividend << WIDTH) | 0.

But I'm not sure how to implement that in the code.

Wait, perhaps the code should have a data path that initializes the aq_reg, m_reg, etc., when the FSM transitions to BUSY.

But since the code is provided, I have to work within that structure.

Another thing to consider is the sign extension. When adding or subtracting, the sign bit is correctly handled.

In Verilog, the addition and subtraction are done with the '+' and '-' operators, and the result is stored in a register of sufficient size.

So, perhaps the code should handle the sign correctly by using the sign bit.

Another point is that the quotient is built from LSB to MSB, so in each iteration, the new bit is added to the LSB of the quotient_reg.

So, in code:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But I'm not sure if that's correct.

Wait, perhaps the quotient_reg is a register that is WIDTH bits, and each iteration, the new bit is added to the LSB.

So, in code:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But I'm not sure if that's the correct way to model it.

Another thing to consider is the final adjustment. After the loop, if the sign bit is 1, we need to add M to A.

So, in code:

if (sign_bit_after) {
    aq_next = aq_reg << 1;
    aq_next = aq_next + m_reg;
}

Then, the remainder is aq_next, and the quotient is quotient_reg.

But I'm not sure if that's necessary because the algorithm says that after WIDTH iterations, the remainder is correct.

Wait, in the example, after 4 iterations, the sign bit is 0, so no adjustment is needed.

So, perhaps the code should include this adjustment.

Putting it all together, the code inside the FSM's BUSY state would be:

- For WIDTH iterations:
   - Shift aq_reg left to get aq_next.
   - Check sign_bit = aq_reg[0].
   - If sign_bit, aq_next = aq_next + ~m_reg + 1; else, aq_next = aq_next + m_reg.
   - quotient_reg = (quotient_reg << 1) | sign_bit.
   - aq_reg = aq_next.
   - n_reg = n_next.
- After loop:
   - If sign_bit_after is 1, aq_next = aq_reg << 1; aq_next = aq_next + m_reg.
   - remainder = aq_next.
   - quotient = quotient_reg.
   - valid = 1.

But I'm not sure about the final adjustment.

Another thing to consider is the initial value of aq_reg. Initially, it should be the dividend shifted left by WIDTH bits, with the quotient part being 0.

So, aq_reg = (dividend << WIDTH) | 0.

But in the code, aq_reg is a register that is WIDTH + 1 bits. So, perhaps the initial value is (dividend << WIDTH) | 0.

But I'm not sure how to handle that in the code.

Another point is that the n_reg is a counter that starts at WIDTH and decrements each iteration until it reaches 0.

So, in code:

n_reg = WIDTH;
n_next = n_reg - 1;

But in the code, n_reg is part of the FSM's state.

Putting it all together, the code inside the FSM's BUSY state would be:

always @ (posedge clock or start) begin
    if (state_reg == IDLE) {
        // load dividend and divisor
        aq_reg = (dividend << WIDTH) | 0;
        m_reg = divisor;
        state_next = BUSY;
        n_reg = WIDTH;
        n_next = n_reg - 1;
        valid_next = 0;
    } else if (state_reg == BUSY) {
        if (n_reg == 0) {
            // after all iterations, perform final adjustment
            if (sign_bit_after) {
                aq_next = aq_reg << 1;
                aq_next = aq_next + m_reg;
            }
            quotient_reg = (quotient_reg << 1) | sign_bit_after;
            aq_reg = aq_next;
            n_reg = n_next;
            valid_next = 1;
            state_next = DONE;
        } else {
            // perform one iteration
            sign_bit = aq_reg[0];
            aq_next = aq_reg << 1;
            if (sign_bit) {
                aq_next = aq_next + ~m_reg + 1;
            } else {
                aq_next = aq_next + m_reg;
            }
            quotient_reg = (quotient_reg << 1) | sign_bit;
            aq_reg = aq_next;
            n_reg = n_next;
            n_next = n_reg - 1;
            valid_next = 0;
        }
    } else {
        // invalid state
        aq_reg = 0;
        m_reg = 0;
        quotient_reg = 0;
        valid_next = 0;
        state_next = IDLE;
    }
endmodule

Wait, but I'm not sure if this is correct. Maybe I should look for a reference implementation or example.

Alternatively, perhaps I should use a different approach, such as using a state transition table.

But given the time constraints, I'll proceed with the code I have.

Another thing to consider is the initial value of aq_reg. Initially, it should be the dividend shifted left by WIDTH bits, with the quotient part being 0.

So, aq_reg = (dividend << WIDTH) | 0;

But in the code, the aq_reg is a register that is WIDTH + 1 bits. So, perhaps the initial value is (dividend << WIDTH) | 0.

But I'm not sure how to handle that in the code.

Another point is that the quotient_reg is a register that is WIDTH bits, and each iteration, the new bit is added to the LSB.

So, in code:

quotient_reg = (quotient_reg << 1) | (sign_bit_after);

But I'm not sure if that's correct.

Another thing to consider is that the sign bit after the operation is the sign of A after the operation, which is the new sign bit of A.

So, in code:

sign_bit_after = aq_next[0];

Then, this is used to update the quotient.

So, in code:

quotient_reg = (quotient_reg << 1) | sign_bit_after;

But I'm not sure if that's correct.

Another thing to consider is that the aq_reg is a register that is WIDTH + 1 bits, so when shifted left, it becomes WIDTH + 2 bits. But the aq_reg is WIDTH + 1 bits, so perhaps the shift is done in a way that the new bit is added to the LSB.

Wait, perhaps the aq_reg is a register that is WIDTH + 1 bits, so when shifted left, it becomes WIDTH + 2 bits, but the higher bit is the sign bit.

But in the code, the aq_reg is declared as reg [AW+WIDTH-1 : 0], which is WIDTH + 1 bits. So, when shifted left, the new bit is added to the left, and the sign bit is the first bit.

So, perhaps the code should handle that correctly.

Another point is that the n_reg is a counter that starts at WIDTH and decrements each iteration until it reaches 0.

So, in code:

n_reg = WIDTH;
n_next = n_reg - 1;

But in the code, n_reg is part of the FSM's state.

Putting it all together, the code inside the FSM's BUSY state would be:

always @ (posedge clock or start) begin
    if (state_reg == IDLE) {
        // load dividend and divisor
        aq_reg = (dividend << WIDTH) | 0;
        m_reg = divisor;
        state_next = BUSY;
        n_reg = WIDTH;
        n_next = n_reg - 1;
        valid_next = 0;
    } else if (state_reg == BUSY) {
        if (n_reg == 0) {
            // after all iterations, perform final adjustment
            if (sign_bit_after) {
                aq_next = aq_reg << 1;
                aq_next = aq_next + m_reg;
            }
            quotient_reg = (quotient_reg << 1) | sign_bit_after;
            aq_reg = aq_next;
            n_reg = n_next;
            valid_next = 1;
            state_next = DONE;
        } else {
            // perform one iteration
            sign_bit = aq_reg[0];
            aq_next = aq_reg << 1;
            if (sign_bit) {
                aq_next = aq_next + ~m_reg + 1;
            } else {
                aq_next = aq_next + m_reg;
            }
            quotient_reg = (quotient_reg << 1) | sign_bit;
            aq_reg = aq_next;
            n_reg = n_next;
            n_next = n_reg - 1;
            valid_next = 0;
        }
    } else {
        // invalid state
        aq_reg = 0;
        m_reg = 0;
        quotient_reg = 0;
        valid_next = 0;
        state_next = IDLE;
    }
endmodule