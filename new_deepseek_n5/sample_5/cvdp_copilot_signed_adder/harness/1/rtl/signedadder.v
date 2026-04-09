module based on the given specifications. Let me start by understanding the requirements.

First, the module has to add or subtract two signed 2's complement numbers based on the mode. The mode is controlled by the i_mode input. So, I'll need to use a case statement or if-else to handle the two cases: addition and subtraction.

The state machine has four states: IDLE, LOAD, COMPUTE, and OUTPUT. The state is stored in o_status, which is a 2-bit register. I'll need to manage state transitions using a state variable. Maybe a finite state machine (FSM) approach would work here.

The inputs include i_start, which is used to initiate the operation when i_enable is high. But if i_enable is low, i_start is ignored. Also, i_clear resets the state to IDLE and clears the result.

I should handle the clock and reset signals properly. Since it's a synchronous module, I'll use a clocked process with i_clk as the clock. The state transitions should be triggered by positive clock edges.

For the operands, they are DATA_WIDTH bits. I'll need to store them in registers. So, i_operand_a and i_operand_b will be loaded into reg_a and reg_b, respectively, when in the LOAD state.

The computation happens in the COMPUTE state. Depending on i_mode, I'll either add or subtract the two operands. After computation, I need to check for overflow. Overflow occurs if both operands are positive and the result is negative, or both are negative and the result is positive.

The outputs o_resultant_sum, o_overflow, and o_ready need to be set appropriately. o_ready should be high only when the computation is complete, which is in the OUTPUT state. Also, if i_clear is asserted, it should clear the result and reset the state.

I should also handle the initial state (IDLE). When the module starts, it waits for i_start to be asserted while i_enable is high. Once i_start is high, it moves to the LOAD state.

Let me outline the steps:

1. Initialize the state as IDLE.
2. When i_start is high and i_enable is high, transition to LOAD.
3. In LOAD, capture the operands and store them.
4. When Ready is set (after computation), transition to COMPUTE.
5. In COMPUTE, perform the operation based on i_mode and check for overflow.
6. After computation, transition to OUTPUT and set o_ready.
7. When i_clear is high, reset the state to IDLE, clear the result, and set o_ready to 0.
8. Handle clock and reset signals with positive edge and asynchronous reset.

I'll need to use a state variable, say state, which is a 2-bit reg. The state transitions will be handled in the state machine.

Now, considering the code structure, I'll start with the module declaration, then define the state variable. Inside a clocked process, I'll handle the state transitions on the positive edge of i_clk.

I should also make sure that all the inputs are properly handled, especially the edge sensitivity. Since i_rst_n is active-low, I'll check for its falling edge to reset the state machine.

Wait, in Verilog, the state transitions are triggered by the clock edge. So, I'll use a positive edge sensitivity list for the state transitions. Also, i_rst_n is an active-low signal, so I'll check for its falling edge to reset the state.

Let me think about the initial state. Initially, state is 00 (IDLE). When i_start is high and i_enable is high, and the state is IDLE, it transitions to LOAD.

In the LOAD state, when the operands are loaded, the state transitions to COMPUTE after the next clock edge. Then, in the COMPUTE state, after the computation, it transitions to OUTPUT. In the OUTPUT state, if i_clear is high, it goes back to IDLE, else it stays in OUTPUT until the next operation.

I also need to handle the o_ready signal. It should be high only when the computation is complete, which is in the OUTPUT state. So, in the OUTPUT state, I'll set o_ready to 1.

For overflow detection, after performing the addition or subtraction, I'll check the sign bits. For addition, if the sum's sign is different from the operands' signs, there's an overflow. Similarly for subtraction.

Wait, but for subtraction, it's equivalent to adding the two's complement. So, when i_mode is 1, operand_b is negated and then added to operand_a. So, I can handle subtraction by inverting operand_b and adding it to operand_a.

Alternatively, I can perform the operation as per the mode. Let me code it using a case statement:

case (i_mode)
  0: o_resultant_sum = i_operand_a + i_operand_b;
  1: o_resultant_sum = i_operand_a - i_operand_b;
endcase

But wait, in Verilog, subtraction is straightforward, but for overflow, I need to check the sign bits.

The operands are DATA_WIDTH bits, so the sign bit is at position DATA_WIDTH-1. For addition, if both operands are positive (sign bit 0) and the result is negative (sign bit 1), overflow occurs. Similarly, if both are negative (sign bit 1) and result is positive (sign bit 0), overflow occurs.

So, after computing the sum, I'll check the sign bits of the operands and the result.

Let me write the code step by step.

First, define the state variable:

reg [1:0] state;

Then, in the clocked process:

always clocked positive edge of i_clk begin
  case (state)
    00: 
      if (i_start & i_enable) 
        state = 01;
    01: 
      if (i_operand_a is ready and i_operand_b is ready)
        state = 10;
    10: 
      // perform computation
      reg a = i_operand_a;
      reg b = i_operand_b;
      o_resultant_sum = a + b; // for mode 0
      // or a - b for mode 1
      // compute overflow
      // get sign bits
      sign_a = (a >> (DATA_WIDTH-1)) & 1;
      sign_b = (b >> (DATA_WIDTH-1)) & 1;
      sign_result = (o_resultant_sum >> (DATA_WIDTH-1)) & 1;
      if ((sign_a == 0 && sign_b == 0 && sign_result == 1) || 
          (sign_a == 1 && sign_b == 1 && sign_result == 0)) 
        o_overflow = 1;
      else 
        o_overflow = 0;
      state = 11;
    11: 
      if (i_clear) 
        state = 00;
        o_resultant_sum = 0;
        o_ready = 0;
      else 
        o_ready = 1;
  endcase
end

Wait, but in the Compute state, I need to make sure that the operands are loaded. So, perhaps in the Load state, after asserting the state, I should wait for the next clock edge to perform the computation.

Alternatively, maybe the state transitions should be handled differently. Let me think again.

In the Load state (01), when the state is set, the next clock edge should trigger the computation. So, in the Load state, I'll set a flag to indicate that the operands are being captured. Then, in the next clock edge, if i_mode is valid, perform the computation.

Alternatively, perhaps the state transitions should be based on the positive edge. So, in the Load state, when the positive edge is received, it transitions to Compute.

Wait, perhaps the code should be structured as follows:

- In the IDLE state (00), when i_start is high and i_enable is high, transition to LOAD (01).
- In the LOAD state (01), when the positive edge is received, capture the operands and transition to COMPUTE (10).
- In the COMPUTE state (10), perform the operation and check for overflow, then transition to OUTPUT (11).
- In the OUTPUT state (11), wait for the next operation. If i_clear is high, reset to IDLE.

But I'm not sure if the operands are captured immediately upon assertion of i_start or if they need to be ready before computation. According to the problem statement, i_start is a control signal to initiate the operation, so perhaps the operands are captured when i_start is asserted and i_enable is high.

Wait, the problem says that i_start is a control signal to initiate the operation. So, when i_start is high and i_enable is high, it starts the process of capturing the operands and performing the computation.

So, in the IDLE state, when i_start is high and i_enable is high, transition to LOAD. In the LOAD state, capture the operands and transition to COMPUTE after the next clock edge.

In the Compute state, perform the operation, check for overflow, then transition to OUTPUT. In the OUTPUT state, if i_clear is high, reset to IDLE, else stay in OUTPUT.

So, the code structure would be:

state = 00;
always clocked positive edge of i_clk begin
  case (state)
    00: 
      if (i_start & i_enable) 
        state = 01;
    01: 
      // capture operands
      reg a = i_operand_a;
      reg b = i_operand_b;
      state = 10;
    10: 
      // perform computation
      o_resultant_sum = a + b or a - b based on i_mode
      // compute overflow
      // set o_ready to 1
      state = 11;
    11: 
      if (i_clear) 
        state = 00;
        o_resultant_sum = 0;
        o_ready = 0;
      else 
        o_ready = 1;
  endcase
end

Wait, but in the Compute state, I need to compute the sum, check overflow, and then transition to OUTPUT. So, in the Compute state, after computing, set state to 11.

But I also need to make sure that the operands are loaded before performing the computation. So, in the Load state, after i_start is asserted, the operands are loaded, and the state transitions to Compute.

But in the code above, in the Load state, I'm setting a = i_operand_a and b = i_operand_b, then transitioning to Compute. But I should also ensure that the operands are valid. However, the problem states that the inputs are debounced and synced with i_clk, so perhaps I don't need to handle that.

Now, handling the overflow:

After computing the sum, I need to check if the result's sign is different from the expected based on the operands' signs.

For addition (i_mode=0), if both operands are positive (sign bit 0) and result is negative (sign bit 1), overflow occurs. Similarly, if both are negative (sign bit 1) and result is positive (sign bit 0), overflow occurs.

For subtraction (i_mode=1), it's equivalent to adding the two's complement, so the same overflow condition applies.

So, in the Compute state, after computing o_resultant_sum, I'll extract the sign bits of a, b, and the result.

sign_a = (a >> (DATA_WIDTH-1)) & 1;
sign_b = (b >> (DATA_WIDTH-1)) & 1;
sign_result = (o_resultant_sum >> (DATA_WIDTH-1)) & 1;

if ((sign_a == 0 && sign_b == 0 && sign_result == 1) || 
    (sign_a == 1 && sign_b == 1 && sign_result == 0)) 
  o_overflow = 1;
else 
  o_overflow = 0;

Now, putting it all together, the code would look like this:

module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);
    reg [1:0] state;

    always clocked positive edge of i_clk begin
        case (state)
            00: 
                if (i_start & i_enable)
                    state = 01;
            01: 
                // Capture operands
                reg a = i_operand_a;
                reg b = i_operand_b;
                state = 10;
            10: 
                // Perform computation
                if (i_mode == 0)
                    o_resultant_sum = a + b;
                else
                    o_resultant_sum = a - b;
                // Compute overflow
                sign_a = (a >> (DATA_WIDTH-1)) & 1;
                sign_b = (b >> (DATA_WIDTH-1)) & 1;
                sign_result = (o_resultant_sum >> (DATA_WIDTH-1)) & 1;
                if ((sign_a == 0 && sign_b == 0 && sign_result == 1) || 
                    (sign_a == 1 && sign_b == 1 && sign_result == 0)) 
                    o_overflow = 1;
                else 
                    o_overflow = 0;
                state = 11;
            11: 
                if (i_clear) 
                    state = 00;
                    o_resultant_sum = 0;
                    o_ready = 0;
                else 
                    o_ready = 1;
        endcase
    end
endmodule

Wait, but in the Compute state, I'm using a and b which are assigned from i_operand_a and i_operand_b. But in Verilog, assignments inside an always block are only valid if they are inside a clocked process or positive edge. Since this is a clocked process, it's okay.

But I should also consider that the operands might not be ready. However, the problem states that the inputs are debounced and synced with i_clk, so perhaps I don't need to handle that.

Another thing: when i_clear is high, it should clear the result and reset the state machine. So, in the OUTPUT state, if i_clear is high, it goes back to IDLE.

I think this covers all the cases. Now, I'll write the code accordingly.


module signedadder #(parameter DATA_WIDTH = 8)(
    input i_clk,
    input i_rst_n,
    input i_start,
    input i_enable,
    input i_mode,
    input i_clear,
    input [DATA_WIDTH-1:0] i_operand_a,
    input [DATA_WIDTH-1:0] i_operand_b,
    output reg [DATA_WIDTH-1:0] o_resultant_sum,
    output reg o_overflow,
    output reg o_ready,
    output reg [1:0] o_status
);
    reg [1:0] state;

    always clocked positive edge of i_clk begin
        case (state)
            00: 
                if (i_start & i_enable)
                    state = 01;
            01: 
                reg a = i_operand_a;
                reg b = i_operand_b;
                state = 10;
            10: 
                if (i_mode == 0)
                    o_resultant_sum = a + b;
                else
                    o_resultant_sum = a - b;
                sign_a = (a >> (DATA_WIDTH-1)) & 1;
                sign_b = (b >> (DATA_WIDTH-1)) & 1;
                sign_result = (o_resultant_sum >> (DATA_WIDTH-1)) & 1;
                if ((sign_a == 0 & sign_b == 0 & sign_result == 1) |
                    (sign_a == 1 & sign_b == 1 & sign_result == 0))
                    o_overflow = 1;
                else
                    o_overflow = 0;
                state = 11;
            11: 
                if (i_clear)
                    state = 00;
                    o_resultant_sum = 0;
                    o_ready = 0;
                else
                    o_ready = 1;
        endcase
    end
endmodule