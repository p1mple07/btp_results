module skeleton and detailed specification. Our answer must include only the RTL code generated. The code must be saved to rtl/spi_fsm.v.

We must produce the code in plain text, not markdown formatting, etc. But instructions say "Your response will be saved directly to: rtl/spi_fsm.v." So we must output the file content exactly in plain text. I'm not sure if we need to provide a file header with file name? Possibly not, we simply output the code.

I must produce a verilog module that implements a state machine for SPI. The module must have states: Idle (00), Transmit (01), Clock Toggle (10), Error (11). The FSM is triggered by signals i_enable, i_clear, i_fault. The reset is asynchronous active low (i_rst_b). The code must also support the outputs: o_spi_cs_b, o_spi_clk, o_spi_data, o_bits_left, o_done, and o_fsm_state.

We have to consider the following states:

- Idle (00): 
  - o_spi_cs_b = 1, o_spi_clk = 0, default values.
  - Wait for i_enable=1.
  - Also if i_clear is asserted, then state becomes Idle and all outputs are reset.
  - Also if i_fault is asserted, then error state.
- Transmit (01):
  - Activate SPI signals: o_spi_cs_b = 0.
  - Load the MSB of i_data_in into o_spi_data.
  - Start shifting bits out sequentially. But the specification says: "load the MSB of i_data_in into o_spi_data" so that's the first bit to be transmitted. But then what? Possibly we need to store the data in a shift register? But specification says "i_data_in" is 16-bit input data. But we are not storing in a shift register? But then the state "Clock Toggle" says: "decrement o_bits_left and determine if more bits remain to be transmitted." So the FSM does not have a shift register? But wait: It says "Serialized SPI data output derived from the i_data_in input vector." The simplest interpretation: We can shift out the bits by shifting right, but then we need to store the data. But the specification says "load the MSB of i_data_in into o_spi_data" in the "Transmit" state. But then "o_bits_left" is decremented in "Clock Toggle" state. But then how do we get the next bit? We can store the data in a shift register internal variable, or we can simply use the input i_data_in, but i_data_in is parallel, and we need to shift out bits serially. But the spec says "Complete the given Verilog module to implement a state machine for a Serial Peripheral Interface (SPI)." So it's a state machine that handles data transmission. It must use a shift register for serializing the bits. But the given skeleton doesn't show any internal registers for shift register. But we can add an internal register "data_shift" of width 16 bits. But then we need to update it in "Clock Toggle" state. But wait, the specification: "load the MSB of i_data_in into o_spi_data" is done in Transmit state. But then in Clock Toggle, we toggle the clock, then decrement bits left, and if more bits remain, then shift left the shift register? Actually, in SPI, the typical shifting is: Initially, the data is loaded into a shift register, then on each clock edge, the data is shifted out. But the state machine as described: Idle, then Transmit, then Clock Toggle, then back to Clock Toggle until bits finished, then Idle. But the spec says "load the MSB of i_data_in into o_spi_data" in Transmit state. But then in Clock Toggle state, it toggles the clock and then "determine if more bits remain" - so if there are more bits, then the next bit should be loaded from the shift register. But then we need to shift the data. But if we assume that i_data_in is static during transmission, then we can use a shift register that starts with i_data_in and then shifts right each clock cycle. But the specification says "load the MSB of i_data_in into o_spi_data" in Transmit state, so that implies that the first bit out is the MSB of i_data_in. But then in Clock Toggle state, after toggling the clock, we can shift the data right (or left depending on the protocol). But in SPI, the order of shifting can be LSB first or MSB first. The specification says "MSB first", so we want to shift right. But then, if we have a shift register, we do: data_shift <= data_shift >> 1, and then o_spi_data = data_shift[15]. But wait, if we shift right, then the MSB becomes bit 0? Actually, if we have a 16-bit register, then the MSB is bit 15. Shifting right by one, then the next bit is bit 14, but then the output bit should be the new MSB, which is bit 15 of the shifted result. But that's the same as simply shifting right and then taking the MSB. But then, in the Transmit state, we are already loading the MSB into o_spi_data. But we don't update o_spi_data in Transmit state; the update in Clock Toggle state is when we shift the data. But the spec says "start shifting the bits out sequentially" so the shifting must happen in Clock Toggle state. But then what is the purpose of Transmit state? Possibly the Transmit state is to set the chip select and load the initial bit? But then in Clock Toggle, we toggle clock and shift data. But then if we are shifting data in Clock Toggle state, then we need to store the data in an internal shift register. So I'll add an internal register "shift_reg" of width 16 bits. Then in Idle state, if i_enable is high, then we load shift_reg <= i_data_in. But the spec says "load the MSB of i_data_in into o_spi_data", but we can also load the shift register in Idle. But the spec is ambiguous: It says in Transmit state: "Activate SPI signals and load the MSB of i_data_in into o_spi_data." But then in Clock Toggle state, it says "decrement o_bits_left, and determine if more bits remain to be transmitted." It doesn't mention shifting. So maybe the design is simpler: Use a counter bits_left = 16. Then in Transmit state, output o_spi_data = i_data_in[15] (MSB). Then in Clock Toggle state, toggle the clock, decrement bits_left. And then if bits_left > 0, then update o_spi_data = i_data_in[15 - bits_left] maybe? Because if we start with bits_left=16, then after first bit, bits_left becomes 15, and then the next bit should be i_data_in[14]. But then if we do that, we need to track the bit index. Alternatively, we can use a shift register. But the spec doesn't mention a shift register explicitly. But the spec says "data transmission in a serial format" and "serialized SPI data output derived from the i_data_in input vector." But since i_data_in is parallel and doesn't change, we can compute the bit index by using a counter bits_left. But then how do we get the correct bit? We can use a counter that counts from 0 to 15. But then the first bit transmitted is i_data_in[15] (MSB) when bits_left==16. Then after one clock cycle, bits_left becomes 15, and then the next bit is i_data_in[14]. But that's if we assume the bits are shifted out left? Wait, we need to check: The spec says "load the MSB of i_data_in into o_spi_data". That means the first bit out is i_data_in[15]. Then in Clock Toggle state, "determine if more bits remain" then if yes, then the next bit should be i_data_in[14] if we are shifting right. But then the shifting process: The state machine transitions Idle -> Transmit -> Clock Toggle -> ... -> Clock Toggle -> then when bits_left==0, done. But then what state transitions? The FSM transitions: Idle -> Transmit when i_enable is high, then Transmit -> Clock Toggle, then Clock Toggle toggles the clock and if bits_left > 0 then Clock Toggle state again? But spec says: "Clock Toggle: toggle o_spi_clk, decrement bits_left, and determine if more bits remain. If all bits are sent, assert o_done and transition to Idle." So it seems that after each Clock Toggle, if bits_left > 0, then remain in Clock Toggle state? But then how do we load next bit? Possibly we do a combinational logic that updates o_spi_data. But in our FSM, the outputs update in the always block. We can update o_spi_data in the always block in the always @ (posedge clk or negedge rst_b) block, in the Clock Toggle state, we update the shift register. But if we don't use a shift register, we can compute the bit index as 16 - bits_left. But careful: When bits_left=16, the bit index should be 15 (MSB). When bits_left=15, the bit index is 14, etc. So formula: o_spi_data = i_data_in[16 - bits_left]. But wait, when bits_left becomes 0, then 16 - 0 = 16, but that's out-of-range. So maybe we need to check that if bits_left==0, then done and idle. But the spec says: "If all bits are sent, assert o_done and transition to Idle." So in Clock Toggle, if bits_left==1, then after toggling clock and decrementing, bits_left becomes 0, then assert done and transition to Idle. So then the next bit should never be computed.

Alternatively, we can use a shift register. Let's consider using a shift register. Let shift_reg be 16-bit register. Then in Idle, if i_enable is high, then load shift_reg <= i_data_in. And set bits_left to 16. Then in Transmit state, set o_spi_data = shift_reg[15] (MSB). Then in Clock Toggle, toggle o_spi_clk, shift left or right? In SPI, data is shifted out either on rising or falling edge. But the spec says "toggle o_spi_clk", so the clock toggles. But the data is output on the falling or rising edge. But we don't need to worry about that detail. We can simply update shift_reg in the Clock Toggle state. But which direction? If we are sending MSB first, then after the first bit, shift_reg should shift right by one. But then the new bit out is shift_reg[15]. So update: shift_reg <= shift_reg >> 1. And decrement bits_left. But then if bits_left==1, then after shifting, bits_left becomes 0, and then we assert o_done and return to Idle. But then what if i_clear or i_fault occur? We need to handle that.

So I'll use a shift register variable "shift_reg". But then the specification says "load the MSB of i_data_in into o_spi_data" in Transmit state. That means that in Transmit state, we assign o_spi_data = shift_reg[15]. And then in Clock Toggle state, we update shift_reg <= shift_reg >> 1. But then we need to update o_bits_left. But then how to count bits? We can use bits_left register. Initially, bits_left=16. Then in Clock Toggle, if bits_left > 1, then bits_left <= bits_left - 1, else if bits_left==1, then after shifting, bits_left becomes 0 and then we assert done and return to Idle. But what about i_clear? It says: "When asserted, FSM immediately transitions to Idle, resetting all counters and outputs regardless of the current state." So in all states, if i_clear is high, then we go to Idle and set bits_left=16 and shift_reg = 16'b0 maybe, and outputs to safe defaults.

What about i_fault? "If asserted, the FSM transitions to an error state, halts all activity, and drives outputs to safe defaults." So in any state if i_fault is high, then we go to Error state. And in Error state, we drive: o_spi_cs_b=1, o_spi_clk=0, o_spi_data=0, o_done=0, o_bits_left=10 (which is decimal 10, binary 01010) maybe, and remain in error until cleared or reset. But then how do we clear error state? The spec says "remains here until cleared or reset." But then i_clear and i_rst_b can cause transition? But if i_clear is asserted, it says "forces FSM to immediately clear the current transaction, clear counters, and transition to Idle." But in error state, should i_clear cause transition to Idle? Possibly yes. But spec says "until cleared or reset." But then it says in "Clear" control: "When asserted, FSM immediately transitions to Idle, resetting all counters and outputs regardless of the current state." So even if in error state, if i_clear is high, then we go to Idle. But then what about i_fault? If i_fault is high, then error state. But what if i_fault deasserts? The spec doesn't say. But maybe we assume that i_fault remains asserted until cleared externally. But then i_clear can clear error state. Also i_rst_b resets everything. So i_fault transitions to error state and stays there until reset or clear. But then if i_fault deasserts, do we remain in error state? The spec is ambiguous. It says "entered upon assertion of i_fault", so I assume if i_fault goes low, we might remain in error state? But then the spec "forces FSM to clear" with i_clear means that even if in error state, if i_clear is asserted, then we go to idle. But if i_fault remains high, then we stay in error state. But if i_fault goes low, do we go back to idle? The spec doesn't specify. It says "entered upon assertion of i_fault". Possibly we want to remain in error state until reset or clear. So I'll implement that.

Now what about i_enable? "If asserted, the FSM proceeds through normal transmission states." So in Idle state, if i_enable is high, then we transition to Transmit state. And if i_enable is low, then we go to Idle state. But then what if i_clear is asserted? i_clear takes precedence over i_enable. So in any state, if i_clear is high, then we go to Idle.

So overall FSM transitions:
- From Idle:
  - If i_clear, then go to Idle (but maybe we need to reset shift_reg, bits_left, outputs).
  - Else if i_fault, then go to Error.
  - Else if i_enable is high, then go to Transmit.
  - Otherwise, remain Idle.
- From Transmit:
  - If i_clear, then go to Idle.
  - Else if i_fault, then go to Error.
  - Else, go to Clock Toggle.
- From Clock Toggle:
  - If i_clear, then go to Idle.
  - Else if i_fault, then go to Error.
  - Else, toggle clock, shift data, decrement bits_left.
    - If bits_left > 1, then remain in Clock Toggle.
    - If bits_left == 1, then after shifting, bits_left becomes 0, assert o_done, and then go to Idle.
- From Error:
  - If i_clear, then go to Idle.
  - Else if i_rst_b is low (active low, so i_rst_b=0 resets), then go to Idle.
  - Otherwise, remain in Error.

Wait, check: i_rst_b is active low, so when i_rst_b==0, we reset FSM to Idle. So in Error, if !i_rst_b, then go to Idle.

Now outputs:
- In Idle:
  - o_spi_cs_b = 1, o_spi_clk = 0, o_spi_data = 0 (maybe).
  - bits_left = 16 (0x10), but spec says default bits_left = 0x10 when idle. So bits_left should be 16 decimal which is 0x10.
  - o_done = 0.
- In Transmit:
  - o_spi_cs_b = 0 (active low chip select).
  - o_spi_clk remains 0? But spec says in Idle, o_spi_clk = 0, but in Transmit, it doesn't specify explicitly but likely same.
  - o_spi_data = shift_reg[15] (MSB).
- In Clock Toggle:
  - o_spi_clk toggles: So if currently 0 then becomes 1, if currently 1 then becomes 0.
  - o_spi_data = shift_reg[15] (after shifting).
  - bits_left gets decremented.
- In Error:
  - o_spi_cs_b = 1, o_spi_clk = 0, o_spi_data = 0, bits_left = 10 (0x0A).
  - o_done = 0.
  
Also, o_done is asserted high for one clock cycle when transaction is successfully completed or FSM transitions to error state. So when transitioning from Clock Toggle to Idle after bits_left becomes 0, we assert o_done for one cycle. Also when transitioning from any state to Error, we assert o_done for one cycle? The spec says "or the FSM transitions to an error state." So yes, in error state, o_done should be asserted for one cycle. But then, in error state, we drive outputs to safe defaults and remain there until cleared or reset. But o_done is 0 in error state (as per spec: "o_done = 0" in error state). But then "asserted for one clock cycle when a transaction is successfully completed or the FSM transitions to an error state" means that the moment we enter error state, we should assert o_done for one cycle, then clear it. But then if we remain in error state, o_done should remain 0? But then the spec says "drives outputs to safe defaults" which include o_done = 0. So I think we assert o_done in the transition to error state, then on the next clock cycle, we clear it. But then the spec says "o_done pulses high for exactly one clock cycle when a transaction is successfully completed or the FSM transitions to an error state." So that means that in the state machine update, when a transition to Idle from Clock Toggle occurs after bits_left==0, we set o_done=1 for that cycle, and then in the next cycle, it goes to Idle and o_done=0. Similarly, when transitioning to Error, we set o_done=1 for one cycle. But then in error state, we output o_done=0. But then the next cycle, if still error, o_done remains 0. But then if i_clear or reset occurs, then we go to Idle and o_done=0.

So we need a mechanism to generate a one-cycle pulse for o_done. We can use a register that latches o_done and then clears it next cycle. Alternatively, we can detect state transitions and set done. But since our FSM is registered, we can simply assign o_done in combinational logic: if (current_state == Error and previous_state != Error) or if (transition from Clock Toggle to Idle and bits_left==0) then o_done=1. But then how to detect state transitions? We can use a register for previous state, but simpler is to assign o_done in always block in synchronous logic. But then we need to detect transitions. Alternatively, we can use a flag that is set when entering error or completion. But then we need to clear it in the next cycle.

Maybe we can use a temporary reg done_tick that is set in the combinational always block that checks if (old_state != current_state and (current_state==Error or (old_state==Clock Toggle and current_state==Idle and bits_left==0))). But then we need to store old_state. But I can store previous state in a register "prev_state". But then I need to update prev_state every cycle. But the spec says "o_done pulses high for exactly one clock cycle" so we can generate a pulse in a combinational block that compares current_state with previous_state. But then we need to update prev_state on every clock cycle. But then we must be careful with asynchronous reset.

Alternatively, we can generate done_tick in sequential always block by checking if (i_clear or i_fault or bits_left==0 transition) occurred. But then we need to detect transition. Alternatively, we can generate done_tick in always block with a register that is set on entering error/completion and then cleared in the next cycle. But then we need to know when to clear it.

Maybe simpler: In the always block, if (current state is Error and previous state is not Error) then set o_done=1, else if (transition from Clock Toggle to Idle due to bits_left==0) then set o_done=1, else o_done=0. But then we need to store previous state.

I can do: reg [1:0] state, next_state; and also reg [1:0] prev_state; and then update prev_state <= state at every clock cycle. Then in always block, assign o_done = ( (state == 2'b11 && prev_state != 2'b11) ) || ( (prev_state == 2'b10 && state == 2'b00 && bits_left==0) ). But careful: bits_left==0 condition: We want to assert done when the transaction is completed. But the transition from Clock Toggle to Idle happens only when bits_left becomes 0. But then we can check that condition. But then we also want to assert done when transitioning to error. But then we want the pulse to be one cycle only. But then in the next cycle, o_done will be 0.

So I'll add a register prev_state, and then assign done_tick accordingly. But note that in the Error state, the spec says o_done is 0 in the state output, but the pulse is only one clock cycle when transitioning to error. So in the Error state, we want o_done to be 0 after the pulse. So we want to pulse it on transition.

We also have to handle asynchronous reset. i_rst_b is active low, so when i_rst_b==0, we reset state to Idle and also reset shift_reg, bits_left, outputs, prev_state, etc.

Also, i_clear is synchronous? It says "forces the FSM to immediately clear the current transaction". It might be synchronous to i_clk, but it might be asynchronous? The specification doesn't say asynchronous or synchronous. I'll assume it's synchronous with i_clk. But then if i_clear is high, then we want to go to Idle. But what if i_clear is high in the middle of transmission? We want to immediately clear counters and outputs. So in the always block, if (i_clear) then next_state = Idle, and also set bits_left=16, shift_reg=0, etc. But then i_clear takes precedence over i_enable and i_fault? But spec says: "when asserted, FSM immediately transitions to Idle, resetting all counters and outputs regardless of the current state." So yes.

Also, i_fault: if asserted, then next_state = Error, and outputs go to safe defaults, but done tick should be asserted for one cycle.

I will use a state register "state" and a next state register "next_state". But I can combine them if desired.

I'll declare parameter states: localparam IDLE = 2'b00, TRANSMIT = 2'b01, CLOCK_TOGGLE = 2'b10, ERROR = 2'b11.

Now I'll write an always block @(posedge i_clk or negedge i_rst_b). Then if (!i_rst_b) then state <= IDLE, shift_reg <= 16'b0, bits_left <= 5'd16, outputs <= defaults: o_spi_cs_b=1, o_spi_clk=0, o_spi_data=0, o_done=0, and prev_state <= IDLE.

Else, if (i_clear) then we want to go to Idle and reset counters. But also if (i_fault) then go to Error. But order: Check i_clear first because it forces immediate transition. But specification says "when asserted, FSM immediately transitions to Idle" so i_clear takes precedence over i_fault. But what if both are asserted? Possibly i_clear takes precedence, I assume.

So if (i_clear) then next state = IDLE, and assign outputs accordingly.
Else if (i_fault) then next state = ERROR, and outputs accordingly.

Else, normal FSM transitions:
- If state == IDLE:
   if (i_enable) then next_state = TRANSMIT.
   else remain in IDLE.
- If state == TRANSMIT:
   next_state = CLOCK_TOGGLE.
- If state == CLOCK_TOGGLE:
   next_state = if (bits_left > 1) then CLOCK_TOGGLE, else IDLE.
   But note: bits_left is updated in this state.
- In ERROR state, remain ERROR unless cleared or reset.
But then we need to generate done pulse if transition is from CLOCK_TOGGLE to IDLE when bits_left==0, or if transition from any state to ERROR.

We can generate done pulse in combinational always block or in sequential always block. I'll generate a reg done_tick, and then assign o_done <= done_tick. And then in sequential always block, if (i_clear or i_fault or (transition from CLOCK_TOGGLE to IDLE when bits_left==0)) then done_tick <= 1; else done_tick <= 0; But then it must be one cycle pulse. But if we use state transition detection with prev_state, we can do that.

Let's do: always @(posedge i_clk or negedge i_rst_b) begin
  if (!i_rst_b) begin
    state <= IDLE;
    shift_reg <= 16'b0;
    bits_left <= 5'd16;
    o_spi_cs_b <= 1'b1;
    o_spi_clk <= 1'b0;
    o_spi_data <= 1'b0;
    o_done <= 1'b0;
    prev_state <= IDLE;
  end else begin
    // default assignments for outputs in combinational always block, but careful: outputs are reg and assigned in always block.
    // We'll assign outputs based on state.
    case (state)
      IDLE: begin
        o_spi_cs_b <= 1'b1;
        o_spi_clk <= 1'b0;
        o_spi_data <= 1'b0;
        bits_left <= 5'd16;
      end
      TRANSMIT: begin
        o_spi_cs_b <= 1'b0;
        // o_spi_clk remains 0 maybe
        o_spi_data <= shift_reg[15];
      end
      CLOCK_TOGGLE: begin
        // Toggle clock: if o_spi_clk was 0, make it 1; if 1, make it 0.
        o_spi_clk <= ~o_spi_clk;  // toggle
        // shift register update: shift right by 1
        shift_reg <= shift_reg >> 1;
        bits_left <= bits_left - 1;
        o_spi_data <= shift_reg[15];
      end
      ERROR: begin
        o_spi_cs_b <= 1'b1;
        o_spi_clk <= 1'b0;
        o_spi_data <= 1'b0;
        bits_left <= 5'd10; // 0x0A
      end
      default: ;
    endcase

    // Now determine next state based on control signals and current state
    if (i_clear) begin
      next_state <= IDLE;
    end else if (i_fault) begin
      next_state <= ERROR;
    end else begin
      case (state)
        IDLE: next_state <= (i_enable) ? TRANSMIT : IDLE;
        TRANSMIT: next_state <= CLOCK_TOGGLE;
        CLOCK_TOGGLE: next_state <= ((bits_left > 1) ? CLOCK_TOGGLE : IDLE);
        ERROR: next_state <= ERROR;
        default: next_state <= IDLE;
      endcase
    end

    // Update state register
    state <= next_state;

    // Update prev_state for done pulse detection
    prev_state <= state;

    // Generate done pulse: if transition to ERROR or transition from CLOCK_TOGGLE to IDLE when bits_left becomes 0.
    if ( (state == ERROR && prev_state != ERROR) || 
         (prev_state == CLOCK_TOGGLE && state == IDLE && bits_left == 5'd0) )
         o_done <= 1'b1;
    else
         o_done <= 1'b0;
  end
end

But wait, careful: bits_left is updated in the same always block, so when we check "bits_left == 5'd0", that is after update in the same cycle. But then the transition detection: We want to assert done if we transition from CLOCK_TOGGLE to IDLE and bits_left becomes 0. But then our code: "if (prev_state == CLOCK_TOGGLE && state == IDLE && bits_left == 5'd0)" But bits_left is updated in the same always block, so after update, bits_left is 0. But then prev_state was CLOCK_TOGGLE, so condition holds. But then o_done is set to 1. But then in the next cycle, state is IDLE, and done will be 0. That works.

But there is a subtlety: if i_clear is asserted, then next_state becomes IDLE, but then we don't assert done because it's not a completion or error. That is fine.

Also, i_fault: if asserted, then next_state becomes ERROR, and then done pulse is asserted if previous state is not ERROR. But what if we are already in ERROR? Then no pulse. That is correct.

I need to be careful with asynchronous reset: i_rst_b is active low. So if (!i_rst_b) then we do reset.

I also need to consider that i_clear and i_fault are synchronous signals. I assume they are synchronous.

I must also update o_fsm_state <= state maybe? But spec says "output reg [1:0] o_fsm_state" should reflect internal FSM state. So I'll assign o_fsm_state <= state.

I must also update outputs in the same always block, but careful with sequential assignments. I can use non-blocking assignments for all registers.

I need to declare a reg [1:0] state, next_state, prev_state; reg [15:0] shift_reg; reg [4:0] bits_left; and then assign outputs.

I'll now write the code.

I'll produce the final verilog code as plain text with no markdown formatting.

I'll produce the code in a file named "rtl/spi_fsm.v".

I'll now produce the code accordingly:

I'll produce code:

module spi_fsm (
    input wire i_clk,
    input wire i_rst_b,
    input wire [15:0] i_data_in,
    input wire i_enable,
    input wire i_fault,
    input wire i_clear,
    output reg o_spi_cs_b,
    output reg o_spi_clk,
    output reg o_spi_data,
    output reg [4:0] o_bits_left,
    output reg o_done,
    output reg [1:0] o_fsm_state
);

   // state encoding
   localparam IDLE    = 2'b00;
   localparam TRANSMIT= 2'b01;
   localparam CLOCK_TOG=2'b10;
   localparam ERROR   = 2'b11;

   reg [1:0] state, next_state, prev_state;
   reg [15:0] shift_reg;
   reg [4:0] bits_left;

   always @(posedge i_clk or negedge i_rst_b) begin
      if (!i_rst_b) begin
         state <= IDLE;
         next_state <= IDLE;
         prev_state <= IDLE;
         shift_reg <= 16'b0;
         bits_left <= 5'd16;
         o_spi_cs_b <= 1'b1;
         o_spi_clk <= 1'b0;
         o_spi_data <= 1'b0;
         o_done <= 1'b0;
         o_fsm_state <= IDLE;
      end else begin
         // Default assignments for outputs based on state
         case (state)
           IDLE: begin
              o_spi_cs_b <= 1'b1;
              o_spi_clk <= 1'b0;
              o_spi_data <= 1'b0;
              bits_left <= 5'd16; // reset bits left
           end
           TRANSMIT: begin
              o_spi_cs_b <= 1'b0;
              // o_spi_clk remains as in previous cycle
              o_spi_data <= shift_reg[15];
           end
           CLOCK_TOG: begin
              // Toggle SPI clock
              o_spi_clk <= ~o_spi_clk;
              // Shift out one bit: shift right by 1
              shift_reg <= shift_reg >> 1;
              bits_left <= bits_left - 1;
              o_spi_data <= shift_reg[15];
           end
           ERROR: begin
              o_spi_cs_b <= 1'b1;
              o_spi_clk <= 1'b0;
              o_spi_data <= 1'b0;
              bits_left <= 5'd10; // safe default
           end
           default: ;
         endcase

         // Determine next state based on control signals
         if (i_clear) begin
            next_state <= IDLE;
         end else if (i_fault) begin
            next_state <= ERROR;
         end else begin
            case (state)
              IDLE: next_state <= (i_enable) ? TRANSMIT : IDLE;
              TRANSMIT: next_state <= CLOCK_TOG;
              CLOCK_TOG: next_state <= ((bits_left > 1) ? CLOCK_TOG : IDLE);
              ERROR: next_state <= ERROR;
              default: next_state <= IDLE;
            endcase
         end

         // Update state register and previous state for done pulse detection
         prev_state <= state;
         state <= next_state;
         o_fsm_state <= state;

         // Generate done pulse: one cycle pulse on transition to ERROR or on completion of transmission (from CLOCK_TOG to IDLE when bits_left becomes 0)
         if ((state == ERROR && prev_state != ERROR) ||
             (prev_state == CLOCK_TOG && state == IDLE && bits_left == 5'd0))
             o_done <= 1'b1;
         else
             o_done <= 1'b0;
      end
   end

endmodule