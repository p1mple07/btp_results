<think>We are asked: "Complete the given partial SystemVerilog code for an IR receiver module that decodes a 12-bit IR frame transmitted by a Sony remote control. The module must decode the frame, extract the function code and device address, and output their corresponding values and a valid signal. The design must adhere to the Sony IR protocol, handle invalid or incomplete frames, and manage the frame space between consecutive transmissions."

We have partial code. We need to complete the code in the file "rtl/ir_receiver.sv". The code is partial and we need to complete the missing parts: decode the frame, extract function code and device address, output valid signal, etc. It is partial code. The code includes states: idle, start, decoding, finish, frame_space. The code has missing logic in the always_comb always block for state transitions and for decoding and frame_space logic.

We must complete the code accordingly.

Let's analyze the problem.

We have a module "ir_receiver" with signals: reset_in, clk_in, ir_signal_in, outputs: ir_function_code_out, ir_device_address_out, ir_output_valid.

We have enumerated states: idle, start, decoding, finish, frame_space.

The protocol:
- IR signal input: "ir_signal_in" is the input signal. It is likely digital signal representing the IR LED output. But the code is incomplete.

We have an always_ff that updates state. Then we have always_comb that does state transitions. There is partial code for state transitions for idle, start, decoding, finish. But we need to complete the missing part for decoding and frame_space logic.

We need to decode a 12-bit frame based on timing. The given timings: Start bit: 2.4 ms HIGH pulse. Then each bit: either 0 (0.6ms LOW then 0.6ms HIGH) or 1 (0.6ms LOW then 1.2ms HIGH). And then frame space: 45 ms.

Given the system clock is 10KHz (100us), so each clock cycle is 100us. Let's check: 2.4 ms is 2.4/0.1 = 24 cycles, 0.6 ms is 6 cycles, 1.2ms is 12 cycles, 45 ms is 45/0.1 = 450 cycles. However, the code uses int cycle_counter and frame_space_counter and bit_counter. So we need to count cycles.

We need to decode the IR signal. The code is partial. We need to complete the logic.

We have signals: started, decoded, failed, success, frame_full, ir_frame_valid, etc. We need to use them to complete the state machine.

We need to decode the IR signal into a 12-bit frame. We'll probably store the bits in a register (ir_frame_reg). We'll need counters for start bit, data bits, etc.

Let's think of the state machine:

State: idle. In idle, we wait for a start condition: the start bit should be a HIGH pulse of 2.4ms. But the code in idle: if (ir_signal_in == 1 && started == 0) then next_state = start; else remain idle. But we need to start counting cycles? We need to detect start bit length.

In start state: We are expecting the start bit to be a 2.4ms HIGH pulse. So we should count cycles while the signal is high. Then check if the pulse width is correct. If not, then set failed and go to idle.

So in state start, if (ir_signal_in == 1 && started==1) then we count cycles. But the code in start: if (ir_signal_in==0 && started==1) then next_state = decoding; else if (failed==1) then next_state = idle; else next_state = start. But we need to count cycles. Actually, the code in start state seems to assume that if the pulse goes low then it's finished. But we need to count cycles to see if it's exactly 2.4ms? We need to count cycles when signal is high. But the code doesn't show any cycle counting in start state.

We see variable "cycle_counter" but it's declared. So we need to use cycle_counter to count cycles in the start state.

Plan: in start state, if (ir_signal_in == 1), then increment cycle_counter. If cycle_counter reaches 24 cycles (for 2.4ms) then if the pulse is still high then we have a valid start bit? But wait, the protocol: The start bit is a 2.4ms HIGH pulse. But then it should go low to signal the beginning of data bits. So in start state, we need to count cycles while the signal is high. Once we detect a transition from high to low, then check if the count is 24 cycles. If yes, then valid start, then clear cycle_counter and set started flag, then transition to decoding state. If not, then fail and go to idle.

But the partial code in start state: "if (ir_signal_in == 0 && started == 1) next_state = decoding; else if (failed == 1) next_state = idle; else next_state = start;". This is not complete.

We can do something like:

State start:
- if (ir_signal_in == 1) then cycle_counter++; if (cycle_counter >= 24) then set success? But wait, the start state should check if the pulse width is exactly 2.4ms. But the code should check when the pulse goes low if the counter is exactly 24 cycles. So in start state, if (ir_signal_in == 0) then check if cycle_counter equals 24. If yes, then set started flag and next_state = decoding; if not, then set failed flag and next_state = idle.

We also need to reset cycle_counter when we start a new state. We have variable "cycle_counter" declared as int. But careful: The code uses "cycle_counter" in state start and decoding. Possibly we need separate counters: one for start pulse and one for bit timing in decoding.

Maybe we can reuse cycle_counter for both, but then need to reset it when entering each state.

Plan: Use cycle_counter for start pulse duration. Also use bit_counter for number of bits decoded in decoding state.

State decoding: We need to decode 12 bits. For each bit, we need to detect a LOW pulse of 0.6 ms, then a HIGH pulse. But the protocol: Each bit is encoded as: for bit 0: LOW 0.6 ms, then HIGH 0.6 ms; for bit 1: LOW 0.6 ms, then HIGH 1.2 ms. So in decoding, we can do:
- Wait for the signal to go LOW (0.6ms pulse) then count cycles while low. But the signal should be low for 0.6ms. But wait, the pulse is: first part is always LOW for 0.6ms, then HIGH for 0.6ms if bit=0, or 1.2ms if bit=1.
So decoding procedure:
- For each bit, wait for the low pulse: if (ir_signal_in == 0) then count low cycles. We need to count 6 cycles. Then, when the signal goes high, count the high pulse duration. For bit 0, high pulse should be 6 cycles; for bit 1, high pulse should be 12 cycles.
- Use bit_counter to iterate from 0 to 11 (for 12 bits). Possibly store each bit in ir_frame_reg. But the code uses "logic [11:0] ir_frame_reg;" which is 12-bit register. So we can shift in bits as they are decoded.
- We can use cycle_counter as counter for timing durations in decoding state.
- So in decoding state, if (ir_signal_in == 0) then count low cycles. But we need to detect when the low pulse is complete. But the protocol: The low pulse is always 0.6 ms. So we need to count 6 cycles while the signal is low. But then when the signal goes high, we need to count the high pulse duration.
- But careful: The start of each bit is: signal goes low, then high. But the code in state decoding doesn't mention bit boundaries.
- We need to implement a substate or use the cycle_counter to count the low portion, then count the high portion. Possibly we can use a flag to indicate if we are in the low portion or high portion of a bit.
- Alternatively, we can structure decoding state as follows:
  - Initially, wait for the signal to go low. Once it goes low, start counting low cycles. When low_count reaches 6, then signal should go high. Then count high cycles. If high_count equals 6 then bit=0; if high_count equals 12 then bit=1.
  - After decoding a bit, shift the bit into ir_frame_reg, increment bit_counter.
  - If bit_counter reaches 12, then set decoded flag.
- We'll need a variable "low_count" and "high_count" maybe. But we can reuse cycle_counter if we plan carefully.
- But the code doesn't declare low_count or high_count variables. We can declare them as int maybe.

We can declare additional signals: int bit_low_counter, bit_high_counter; logic [1:0] bit_phase; where bit_phase 0 means low pulse, 1 means high pulse.
- When in decoding state, if (ir_signal_in == 0) and bit_phase==0, then increment bit_low_counter. When bit_low_counter reaches 6, then set bit_phase=1 and reset bit_high_counter=0.
- Then, if (ir_signal_in == 1) and bit_phase==1, then increment bit_high_counter. When bit_high_counter equals 6, then decode bit=0; when equals 12, then decode bit=1; then shift the bit into ir_frame_reg; increment bit_counter; reset bit_low_counter and bit_high_counter; set bit_phase=0; and then wait for next bit.
- But also need to check for invalid timing: if the pulse doesn't match expected durations, then set failed flag and go to idle.
- Also, if signal doesn't go as expected (like if the low pulse never happens, or if the high pulse doesn't complete in time), then mark failure.

- Also, we need to consider that after decoding all 12 bits, we should set decoded flag.
- We have variable "decoded" and "success". In finish state, if success==1, then next_state = frame_space; else remain in finish.
- But what is success? It might be set when we successfully decode the frame and then after output latency of 3 cycles, output the result.

After finish state, we are in frame_space state. In frame_space state, we need to wait for the 45ms space. So we need a counter frame_space_counter. In frame_space state, if (ir_signal_in is high?) Actually, the protocol: after finish, the IR signal goes to space for 45ms. So we expect ir_signal_in to be 0? Actually, the protocol: The frame ends with a 45ms space, which means the IR signal should be LOW for 45ms. But wait, the protocol says: "Frame Space: The frame ends with a 45ms space before the next frame starts." But usually, IR receiver: The IR LED is on when transmitting and off when not transmitting. But in our case, it's ambiguous. The partial code: In finish state, after decoding, we need to assert valid signal and output the decoded data, then wait for frame space.
- So in frame_space state, we wait for the signal to remain low for 45ms (450 cycles) then transition to idle.
- But the code in finish state: "if (success == 1) next_state = frame_space; else next_state = finish;". So success flag is set when we are done processing the frame.
- But also, we need to output the valid signal after 3 clock cycles of latency after finish state. So maybe we use a counter for output latency in finish state.
- The requirement: "Output Latency: The output latency is 3 clock cycles after the 12-bit decoding process is completed. Once the decoding process finishes, the decoded outputs (ir_function_code_out, ir_device_address_out) and the validity signal (ir_output_valid) will be HIGH for one clock cycle." That means after finish state, we wait 3 cycles, then output the result for one cycle, then go to frame_space? But then the code: finish state then transitions to frame_space state if success==1. But then the outputs are not latched until after 3 cycles latency. So we need to incorporate a delay in finish state.
- Possibly, we can have a counter in finish state that counts 3 cycles, then asserts valid signal for one cycle, then clears it, then transitions to frame_space.
- Alternatively, we can do: in finish state, if (success==1) then next_state = frame_space, but also in combinational always block, we set ir_output_valid if we are in finish state and a counter equals some value. But the requirement says: "Once the decoding process finishes, the decoded outputs and the validity signal will be HIGH for one clock cycle" after 3 cycles latency.
- So maybe we need an output register for the decoded values and a validity signal. But the module outputs are combinational outputs? They are declared as output logic. But we can drive them from a register that is updated in finish state after delay.
- We can have a register for function code and device address, and a register for valid signal. But the module outputs are combinational outputs? We can do always_ff with registered outputs if needed.
- We can do: in finish state, once success==1, we latch the decoded frame into ir_frame_out. Then we wait 3 cycles, then output valid signal for one cycle, then clear valid signal.
- But the requirement: "Output latency: 3 clock cycles after decoding process is completed, the outputs are HIGH for one clock cycle." So maybe we need a counter in finish state. Let's say we add a signal "output_delay_counter" and "output_delay_done". But the code doesn't declare such variable. We can declare one: int output_delay_counter; Then in finish state, if success==1, we wait for output_delay_counter to count 3 cycles, then in one cycle, set ir_output_valid and drive outputs, then clear them.
- But the code only has "ir_output_valid" output. It doesn't have registers for ir_function_code_out and ir_device_address_out. But we can drive them from ir_frame_reg. But note: The function code is lower 7 bits, device address is upper 5 bits. But the frame is 12 bits. The table: "ir_function_code_out" is 7 bits, "ir_device_address_out" is 5 bits. So we can do: ir_function_code_out = ir_frame_out[6:0] and ir_device_address_out = ir_frame_out[11:7]. But careful: The bit positions: 12-bit frame: bits 11 downto 0. The upper 5 bits are bits 11 downto 7, and lower 7 bits are bits 6 downto 0.
- But the provided decoding table: For command, it says: The command is the LSB 7-bit information. But the table: "digit 1: 7'b000_0001", etc. So we need to map the command value to a function code output. But the instructions: "Decode a 12-bit frame extracted from FINISH state. Extract function code: lower 7 bits of frame, device address: upper 5 bits of frame." But then there are tables mapping command and address to specific outputs. Wait, check the specification: "Decoding Logic: The module must: Decode a 12-bit frame extracted from FINISH state, Extract: Function Code: The lower 7 bits of the frame (ir_function_code_out), Device Address: The upper 5 bits of the frame (ir_device_address_out)." Then it shows the function decoding table commands: where command is the LSB 7-bit information received in 12-bit frame. So the mapping: if command equals 0 then output 7'b000_0001, if equals 1 then output 7'b000_0010, etc. And similarly for device address: if address equals 0 then output 5'b00001, if equals 1 then output 5'b00010, etc.
- So in finish state, after decoding, we need to extract the command (ir_frame_reg[6:0]) and the device address (ir_frame_reg[11:7]). Then using a combinational block, we map these to outputs. But the requirement says "once the decoding process finishes, the decoded outputs (ir_function_code_out, ir_device_address_out) and the validity signal (ir_output_valid) will be HIGH for one clock cycle." So that means we need to latch the outputs and then after 3 cycles, assert valid for one cycle.
- But then what about invalid frames? The module must handle invalid or incomplete frames. So if a failure occurs, then outputs should be deasserted.
- So in finish state, if success==1, then we latch the frame into ir_frame_out, and then set success flag, and then in finish state we wait 3 cycles (maybe using output_delay_counter) then assert valid for one cycle.
- But then in frame_space state, we wait for the 45ms space. In frame_space state, we count cycles while signal is low? But the protocol says frame space: 45ms space. But what is the IR signal during frame space? Likely the IR LED is off (0). So we should count cycles while ir_signal_in is 0. But wait, the IR signal in idle is 0? Actually, the IR remote control, when not transmitting, the IR LED is off, so the input is 0. But during transmission, it's 1 for start bit and then pulses. So in idle, ir_signal_in should be 0. So in frame_space, we expect ir_signal_in to be 0. But we need to count 450 cycles. But what if the signal goes high unexpectedly? Then we fail.
- So in frame_space state, if (ir_signal_in == 0) then increment frame_space_counter. If frame_space_counter >= 450 then next_state = idle; else remain in frame_space.
- Also, in frame_space state, we need to ensure that outputs are not driven? The outputs remain valid for one cycle after finish state, then go to idle.
- The partial code in always_comb block is incomplete: It ends with "Insert code for decoding and frame space logic here" and then ends. So we need to fill that in.

Let's plan the always_comb block structure:

always_comb begin
    next_state = present_state; // default
    case (present_state)
         idle: begin
             if (ir_signal_in == 1 && started == 0)
                 next_state = start;
             else
                 next_state = idle;
         end
         start: begin
             // In start state, count cycles while ir_signal_in is high.
             if (ir_signal_in == 1) begin
                 // count cycles
                 // But we can't assign cycle_counter in combinational always_comb block; we need sequential always_ff block to update counters.
                 // So maybe we need to update counters in an always_ff block.
                 // But the provided code already has an always_ff block that just updates state.
                 // We need to add additional always_ff blocks for counters maybe.
                 // Alternatively, we can use an always_ff block for state and counters in one always_ff block.
                 // The code has: always_ff @(posedge clk_in or posedge reset_in) begin if (reset_in) present_state <= idle; else present_state <= next_state; end
                 // But we need to update cycle_counter, frame_space_counter, bit_counter, etc.
                 // So we can add an always_ff block for counters.
             end else if (ir_signal_in == 0) begin
                 // Check if the start pulse was valid: cycle_counter should be 24 (2.4ms)
                 if (cycle_counter == 24) begin
                     next_state = decoding;
                     // Clear cycle_counter maybe, but we can leave it.
                 end else begin
                     next_state = idle;
                 end
             end
         end
         decoding: begin
             // In decoding state, we decode 12 bits. Use bit_counter, bit_low_counter, bit_high_counter, bit_phase.
             // We'll need to define these variables as int or logic? They are ints.
             // But they are not declared in the code. We can declare them as int inside always_ff block?
             // We can declare them as int signals outside always_ff block.
             // The code already declares: int cycle_counter, frame_space_counter, bit_counter.
             // We need to declare: int bit_low_counter, bit_high_counter; logic [1:0] bit_phase.
             // But the provided code doesn't declare these. We can add them.
         end
         finish: begin
             // In finish state, wait for output delay then go to frame_space.
             if (success == 1) begin
                 next_state = frame_space;
             end else begin
                 next_state = finish;
             end
         end
         frame_space: begin
             // In frame_space state, wait for 45ms (450 cycles) of IR signal being low.
             if (ir_signal_in == 0)
                 next_state = frame_space; // continue counting
             else
                 next_state = idle; // if signal goes high early, then invalid frame
         end
         default: next_state = idle;
    endcase
end

But note: We cannot update counters in always_comb block. We need sequential always_ff blocks for counters.

We need to add always_ff blocks for counters:
- one always_ff block for cycle_counter and maybe bit counters in start and decoding states.
- one always_ff block for frame_space_counter in frame_space state.
- one always_ff block for output_delay_counter in finish state.

We can add them after the always_ff for state.

Plan: Add an always_ff @(posedge clk_in or posedge reset_in) begin
   if (reset_in) then clear all counters.
   else case (present_state)
         idle: begin
             cycle_counter <= 0; bit_counter <= 0; bit_low_counter <= 0; bit_high_counter <= 0; bit_phase <= 0; frame_space_counter <= 0; output_delay_counter <= 0;
         end
         start: begin
             if (ir_signal_in == 1) begin
                 cycle_counter <= cycle_counter + 1;
             end else begin
                 // pulse ended, check if valid
                 if (cycle_counter != 24) begin
                     failed <= 1;
                     cycle_counter <= 0;
                 end else begin
                     started <= 1; // mark that start was detected
                     cycle_counter <= 0;
                 end
             end
         end
         decoding: begin
             // We decode bit by bit.
             if (bit_counter < 12) begin
                 if (ir_signal_in == 0 && bit_phase == 0) begin
                     bit_low_counter <= bit_low_counter + 1;
                     if (bit_low_counter >= 6) begin
                         bit_phase <= 1;
                         bit_low_counter <= 0;
                     end
                 end else if (ir_signal_in == 1 && bit_phase == 1) begin
                     bit_high_counter <= bit_high_counter + 1;
                     if (bit_high_counter == 6) begin
                         // Bit 0
                         ir_frame_reg[bit_counter] <= 0;
                         bit_counter <= bit_counter + 1;
                         bit_phase <= 0;
                         bit_low_counter <= 0;
                         bit_high_counter <= 0;
                     end else if (bit_high_counter == 12) begin
                         // Bit 1
                         ir_frame_reg[bit_counter] <= 1;
                         bit_counter <= bit_counter + 1;
                         bit_phase <= 0;
                         bit_low_counter <= 0;
                         bit_high_counter <= 0;
                     end
                 end
             end else begin
                 decoded <= 1;
                 // Latch the frame
                 ir_frame_out <= ir_frame_reg;
                 // Mark success
                 success <= 1;
                 // Reset counters for next frame
                 bit_counter <= 0;
                 bit_low_counter <= 0;
                 bit_high_counter <= 0;
                 bit_phase <= 0;
             end
         end
         finish: begin
             // Wait for output delay of 3 cycles
             if (output_delay_counter < 3) begin
                 output_delay_counter <= output_delay_counter + 1;
             end else begin
                 // After delay, assert valid signal for one cycle
                 ir_output_valid <= 1;
                 // Possibly drive outputs from ir_frame_out mapping?
                 // But outputs are combinational? We can drive them here.
                 // We need to map ir_frame_out to function code and device address using lookup.
                 // But the mapping is combinational: 
                 // function code: use case(ir_frame_out[6:0]) mapping, device address: use case(ir_frame_out[11:7]) mapping.
                 // We can compute these in an always_comb block.
                 // So here, we might just set a flag that indicates valid output.
                 // Then after one cycle, clear valid.
                 output_delay_counter <= 0;
             end
         end
         frame_space: begin
             if (ir_signal_in == 0) begin
                 frame_space_counter <= frame_space_counter + 1;
                 if (frame_space_counter >= 450) begin
                     frame_space_counter <= 0;
                     // Clear flags
                     decoded <= 0;
                     failed <= 0;
                     success <= 0;
                     // Clear output valid
                     ir_output_valid <= 0;
                     // Transition to idle
                     // But state transition is done in always_comb block, so we don't do it here.
                 end
             end else begin
                 // If signal goes high unexpectedly, treat as error, go to idle.
                 frame_space_counter <= 0;
             end
         end
         default: begin
             // default: clear counters
             cycle_counter <= 0;
             frame_space_counter <= 0;
             bit_counter <= 0;
             bit_low_counter <= 0;
             bit_high_counter <= 0;
             output_delay_counter <= 0;
         end
    endcase
end

But note: We already have an always_ff block for state. We need to add additional always_ff blocks for counters. But careful: We already have an always_ff for state in the provided code. We can add another always_ff block for counters in the same file. But the provided code already uses always_ff @(posedge clk_in or posedge reset_in) for state update. We can add another always_ff block for counters.

We need to declare additional signals: bit_low_counter, bit_high_counter, bit_phase, output_delay_counter. We'll declare them as int for counters and as logic [1:0] for bit_phase.

Let's check variable declarations: Already declared: int cycle_counter, frame_space_counter, bit_counter; logic [11:0] ir_frame_reg, ir_frame_out; logic stored; Also declared: logic started, decoded, failed, success, frame_full, ir_frame_valid. We'll add: int bit_low_counter, bit_high_counter, output_delay_counter; logic [1:0] bit_phase;

We also need to declare ir_output_valid as output logic. Already declared.

We need to drive ir_function_code_out and ir_device_address_out from ir_frame_out mapping. But these outputs are declared as outputs. We can drive them using combinational logic in an always_comb block. But the requirement says: "Once the decoding process finishes, the decoded outputs and the validity signal will be HIGH for one clock cycle." So that means, in finish state, after delay, for one cycle, we output the mapped values. But then we need to latch them somewhere. We can use registers for them.
We can declare registers: reg [6:0] function_code_reg, device_address_reg; But the module already has output logic [6:0] ir_function_code_out and [4:0] ir_device_address_out. We can drive them with registered assignments in always_ff block maybe.
Alternatively, we can use an always_comb block that maps ir_frame_out to these outputs when ir_output_valid is asserted. But then they won't be registered and won't have latency of 3 cycles. The requirement says "output latency is 3 clock cycles" so we need to register the outputs after delay.
We can do: always_ff @(posedge clk_in or posedge reset_in) begin if (reset_in) {ir_function_code_out, ir_device_address_out, ir_output_valid} <= 0; else if (present_state==finish and output_delay_counter==3 and ... ) then assign outputs for one cycle. But the code already has ir_output_valid as an output logic. But it's not a register? It is declared as output logic, but we can drive it from sequential always_ff block.
We can declare internal registers: reg [6:0] function_code_reg; reg [4:0] device_address_reg; and then drive ir_function_code_out <= function_code_reg; and ir_device_address_out <= device_address_reg; in an always_ff block.
But the provided code doesn't have that. But we can add them.

I propose to add two always_ff blocks: one for state and one for counters and outputs.

We already have one always_ff block for state. We can add another always_ff block for counters and outputs.

Plan for always_ff block for counters and outputs:

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        present_state <= idle;
        cycle_counter <= 0;
        frame_space_counter <= 0;
        bit_counter <= 0;
        bit_low_counter <= 0;
        bit_high_counter <= 0;
        bit_phase <= 0;
        output_delay_counter <= 0;
        ir_frame_reg <= 0;
        decoded <= 0;
        failed <= 0;
        success <= 0;
        ir_output_valid <= 0;
        function_code_reg <= 0;
        device_address_reg <= 0;
    end else begin
        case (present_state)
            idle: begin
                // In idle, clear counters.
                cycle_counter <= 0;
                frame_space_counter <= 0;
                bit_counter <= 0;
                bit_low_counter <= 0;
                bit_high_counter <= 0;
                bit_phase <= 0;
                output_delay_counter <= 0;
                decoded <= 0;
                failed <= 0;
                success <= 0;
                ir_output_valid <= 0;
                // Also, clear function code registers.
                function_code_reg <= 0;
                device_address_reg <= 0;
            end
            start: begin
                if (ir_signal_in == 1) begin
                    cycle_counter <= cycle_counter + 1;
                end else begin
                    // pulse ended
                    if (cycle_counter != 24) begin
                        failed <= 1;
                        cycle_counter <= 0;
                    end else begin
                        started <= 1;
                        cycle_counter <= 0;
                    end
                end
            end
            decoding: begin
                if (bit_counter < 12) begin
                    if (ir_signal_in == 0 && bit_phase == 0) begin
                        bit_low_counter <= bit_low_counter + 1;
                        if (bit_low_counter >= 6) begin
                            bit_phase <= 1;
                            bit_low_counter <= 0;
                        end
                    end else if (ir_signal_in == 1 && bit_phase == 1) begin
                        bit_high_counter <= bit_high_counter + 1;
                        if (bit_high_counter == 6) begin
                            // Bit 0 detected
                            ir_frame_reg[bit_counter] <= 0;
                            bit_counter <= bit_counter + 1;
                            bit_phase <= 0;
                            bit_low_counter <= 0;
                            bit_high_counter <= 0;
                        end else if (bit_high_counter == 12) begin
                            // Bit 1 detected
                            ir_frame_reg[bit_counter] <= 1;
                            bit_counter <= bit_counter + 1;
                            bit_phase <= 0;
                            bit_low_counter <= 0;
                            bit_high_counter <= 0;
                        end
                    end
                end else begin
                    decoded <= 1;
                    ir_frame_out <= ir_frame_reg;
                    success <= 1;
                    // Reset counters for next frame
                    bit_counter <= 0;
                    bit_low_counter <= 0;
                    bit_high_counter <= 0;
                    bit_phase <= 0;
                end
            end
            finish: begin
                if (output_delay_counter < 3) begin
                    output_delay_counter <= output_delay_counter + 1;
                end else begin
                    // After 3 cycles, drive outputs based on ir_frame_out mapping
                    // Map device address (upper 5 bits) and command (lower 7 bits)
                    // Use combinational logic: we can compute them here.
                    // For device address:
                    case (ir_frame_out[11:7])
                        5'b00001: device_address_reg <= 5'b00001; // TV
                        5'b00010: device_address_reg <= 5'b00010; // HDMI1
                        5'b00100: device_address_reg <= 5'b00100; // USB
                        5'b01000: device_address_reg <= 5'b01000; // HDMI2
                        5'b10000: device_address_reg <= 5'b10000; // VCR
                        default: device_address_reg <= 5'b00000;
                    endcase
                    // For function code (command is ir_frame_out[6:0]):
                    case (ir_frame_out[6:0])
                        7'b0000001: function_code_reg <= 7'b0000001; // digit 1
                        7'b0000010: function_code_reg <= 7'b0000010; // digit 2
                        7'b0000011: function_code_reg <= 7'b0000011; // digit 3
                        7'b0000100: function_code_reg <= 7'b0000100; // digit 4
                        7'b0000101: function_code_reg <= 7'b0000101; // digit 5
                        7'b0000110: function_code_reg <= 7'b0000110; // digit 6
                        7'b0000111: function_code_reg <= 7'b0000111; // digit 7
                        7'b0001000: function_code_reg <= 7'b0001000; // digit 8
                        7'b0001001: function_code_reg <= 7'b0001001; // digit 9
                        7'b0000000: function_code_reg <= 7'b0000000; // digit 0
                        7'b0011111: function_code_reg <= 7'b0011111; // channel +
                        7'b0101111: function_code_reg <= 7'b0101111; // channel -
                        7'b0111111: function_code_reg <= 7'b0111111; // volume +
                        7'b1001111: function_code_reg <= 7'b1001111; // volume -
                        7'b1011111: function_code_reg <= 7'b1011111; // mute
                        7'b1101111: function_code_reg <= 7'b1101111; // power
                        7'b1111111: function_code_reg <= 7'b1111111; // pause
                        default: function_code_reg <= 7'b0000000;
                    endcase
                    // Assert valid signal
                    ir_output_valid <= 1;
                    // Then, after one cycle, clear valid signal and output_delay_counter
                    output_delay_counter <= 0;
                end
            end
            frame_space: begin
                if (ir_signal_in == 0) begin
                    frame_space_counter <= frame_space_counter + 1;
                    if (frame_space_counter >= 450) begin
                        frame_space_counter <= 0;
                        // Clear flags for next frame
                        decoded <= 0;
                        failed <= 0;
                        success <= 0;
                        ir_output_valid <= 0;
                        // Also, clear function_code_reg and device_address_reg maybe.
                        function_code_reg <= 0;
                        device_address_reg <= 0;
                    end
                end else begin
                    // If signal goes high unexpectedly, treat as error.
                    frame_space_counter <= 0;
                end
            end
            default: begin
                // default: clear counters
                cycle_counter <= 0;
                frame_space_counter <= 0;
                bit_counter <= 0;
                bit_low_counter <= 0;
                bit_high_counter <= 0;
                output_delay_counter <= 0;
                decoded <= 0;
                failed <= 0;
                success <= 0;
                ir_output_valid <= 0;
                function_code_reg <= 0;
                device_address_reg <= 0;
            end
        endcase
    end
end

Then we need to drive outputs from these registers. We can add always_ff block for outputs:

always_ff @(posedge clk_in or posedge reset_in) begin
    if (reset_in) begin
        ir_function_code_out <= 0;
        ir_device_address_out <= 0;
    end else begin
        ir_function_code_out <= function_code_reg;
        ir_device_address_out <= device_address_reg;
    end
end

But careful: The provided code already has outputs declared. We can drive them from registers.

We also need to declare registers: reg [6:0] function_code_reg; reg [4:0] device_address_reg; We add them.

Also, the always_comb block for state transitions should be updated to include frame_space logic. But we already added that in the sequential always_ff block for counters. But the always_comb block in provided code is incomplete. We need to complete it.

The provided always_comb block is:

always_comb begin
    case (present_state)
        idle: begin
            if (ir_signal_in == 1 && started == 0)
                next_state = start;
            else
                next_state = idle;
        end
        start: begin
            if (ir_signal_in == 0 && started == 1)
                next_state = decoding;
            else if (failed == 1)
                next_state = idle;
            else
                next_state = start;
        end
        decoding: begin
            if (decoded == 1)
                next_state = finish;
            else if (failed == 1)
                next_state = idle;
            else
                next_state = decoding;
        end
        finish: begin
            if (success == 1)
                next_state = frame_space;
            else
                next_state = finish;
        end
        // Insert code for decoding and frame space logic here
    endcase
end

We need to complete the always_comb block with frame_space state. So add:

frame_space: begin
    // In frame_space state, if the frame space duration is complete, go to idle.
    if (/* condition for frame space complete? We check frame_space_counter externally? But we can't read sequential registers in combinational always_comb block. We might assume that frame_space_counter is 450 means complete.
    But since we are driving frame_space_counter in sequential always_ff block, we can't use it in combinational always_comb block. We might need to use a flag.
    We can add a flag "frame_space_done" that is set when frame_space_counter >= 450.
    But we can compute that in combinational always_comb block if we assume frame_space_counter is available.
    But frame_space_counter is updated in sequential always_ff block, so it's registered. But combinational always_comb block can read registered signals if they are declared as logic.
    But frame_space_counter is declared as int, but we can declare it as logic maybe.
    Alternatively, we can use a combinational assignment: if (frame_space_counter == 450) then next_state = idle, else next_state = frame_space.
    But careful: frame_space_counter is updated in always_ff block, so it's not a combinational signal. But we can declare it as logic if needed.
    We can declare frame_space_counter as logic [8:0] maybe, but it's int. We can add a signal: logic frame_space_done;
    We can set frame_space_done <= (frame_space_counter >= 450) in sequential always_ff block, and then use it here.
    Let's add a signal: logic frame_space_done; and update it in sequential always_ff block in frame_space state: if (frame_space_counter >= 450) then frame_space_done <= 1; else frame_space_done <= 0;
    Then in combinational always_comb block, in frame_space state, if (frame_space_done) then next_state = idle; else next_state = frame_space.
    We'll add that signal.
    end
end

So we add signal: logic frame_space_done; and update it in sequential always_ff block in frame_space state: if (ir_signal_in == 0) begin frame_space_counter <= frame_space_counter + 1; if (frame_space_counter >= 450) frame_space_done <= 1; else frame_space_done <= 0; end

But careful: We already use frame_space_counter in sequential always_ff block. We can add frame_space_done as a combinational signal computed from frame_space_counter. But since frame_space_counter is int, we can't directly compare in combinational always_comb block. But we can declare it as logic if we know its maximum value. But we can declare it as int and then in combinational always_comb block, we can't use it because it's not a registered signal unless we declare it as logic. Alternatively, we can declare frame_space_counter as logic [8:0] if we want combinational usage.
Let's change frame_space_counter to logic [8:0] since maximum value 450 fits in 9 bits (2^9=512). But the code declared it as int. We can change it to logic [8:0]. But then our sequential always_ff block comparisons change to "if (frame_space_counter >= 9'd450)".

We also need to declare bit_low_counter and bit_high_counter as logic [3:0] maybe because maximum value 12 fits in 4 bits. But we can keep them as int if we want. But it's better to use logic [3:0] for bit_low_counter and bit_high_counter.
We can declare them as int for simplicity.

Let's do: int bit_low_counter, bit_high_counter, output_delay_counter; and int cycle_counter, frame_space_counter, bit_counter. And then add logic [1:0] bit_phase; and logic frame_space_done.

We then update frame_space_done in sequential always_ff block in frame_space state: if (ir_signal_in == 0) then frame_space_counter <= frame_space_counter + 1; then if (frame_space_counter >= 450) frame_space_done <= 1; else frame_space_done <= 0; but careful: we need to update frame_space_done in sequential always_ff block as well. We can do that in the same always_ff block in frame_space state.

So in sequential always_ff block, in frame_space state, do:
if (ir_signal_in == 0) begin
   frame_space_counter <= frame_space_counter + 1;
   if (frame_space_counter >= 450) begin
       frame_space_done <= 1;
   end else begin
       frame_space_done <= 0;
   end
end else begin
   frame_space_counter <= 0;
   frame_space_done <= 0;
end

Then in combinational always_comb block, in frame_space state: if (frame_space_done) then next_state = idle; else next_state = frame_space.

Now, the always_comb block for state transitions is in the provided code. We need to complete it. So add a branch for frame_space:

frame_space: begin
    if (frame_space_done)
        next_state = idle;
    else
        next_state = frame_space;
end

And then default branch.

Now, we need to declare additional signals at top: int bit_low_counter, bit_high_counter, output_delay_counter; logic [1:0] bit_phase; logic frame_space_done;

We also need to declare registers for function code and device address: reg [6:0] function_code_reg; reg [4:0] device_address_reg;

Now, we need to output the final RTL code as plain text and save to file "rtl/ir_receiver.sv". The response should be plain text without any JSON formatting.

I will produce the complete SystemVerilog code that meets the requirements.

Let's produce the final code:

```
module ir_receiver (
    input  logic        reset_in,               // Active HIGH reset
    input  logic        clk_in,                 // System clock (10 KHz, 100us)
    input  logic        ir_signal_in,           // Input signal (IR)
    output logic [6:0]  ir_function_code_out,   // Decoded output for different functions
    output logic [4:0]  ir_device_address_out,  // "00001": TV, "00010":HDMI1, "00100":USB, "01000":HDMI2, "10000": VCR
    output logic        ir_output_valid         // Indicates validity of the decoded frame
);

    typedef enum logic [2:0] {idle, start, decoding, finish, frame_space} ir_state;
    ir_state present_state, next_state;

    logic started;
    logic decoded;
    logic failed;
    logic success;
    logic frame_full;
    logic ir_frame_valid;

    // Counters for timing
    int cycle_counter;            // For start pulse and decoding timing
    int frame_space_counter;      // For frame space (45ms)
    int bit_counter;              // For counting decoded bits

    // Additional counters for bit decoding
    int bit_low_counter;          // Count low pulse duration (expected 6 cycles = 0.6ms)
    int bit_high_counter;         // Count high pulse duration (6 cycles for 0, 12 cycles for 1)
    int output_delay_counter;     // For output latency (3 cycles)

    // Bit phase: 0 = low pulse, 1 = high pulse
    logic [1:0] bit_phase;

    // Frame register to store decoded 12-bit frame
    logic [11:0] ir_frame_reg;
    logic [11:0] ir_frame_out;

    // Internal registers for decoded outputs
    reg [6:0] function_code_reg;
    reg [4:0] device_address_reg;

    // Flag for frame space completion
    logic frame_space_done;

    // State register update
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in)
            present_state <= idle;
        else
            present_state <= next_state;
    end

    // State transition combinational logic
    always_comb begin
        case (present_state)
            idle: begin
                if (ir_signal_in == 1 && started == 0)
                    next_state = start;
                else
                    next_state = idle;
            end
            start: begin
                if (ir_signal_in == 0 && started == 1)
                    next_state = decoding;
                else if (failed)
                    next_state = idle;
                else
                    next_state = start;
            end
            decoding: begin
                if (decoded)
                    next_state = finish;
                else if (failed)
                    next_state = idle;
                else
                    next_state = decoding;
            end
            finish: begin
                if (success)
                    next_state = frame_space;
                else
                    next_state = finish;
            end
            frame_space: begin
                if (frame_space_done)
                    next_state = idle;
                else
                    next_state = frame_space;
            end
            default: next_state = idle;
        endcase
    end

    // Sequential logic for counters and signal processing
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            present_state        <= idle;
            cycle_counter        <= 0;
            frame_space_counter  <= 0;
            bit_counter          <= 0;
            bit_low_counter      <= 0;
            bit_high_counter     <= 0;
            output_delay_counter <= 0;
            bit_phase            <= 0;
            ir_frame_reg         <= 12'd0;
            decoded              <= 0;
            failed               <= 0;
            success              <= 0;
            ir_output_valid      <= 0;
            function_code_reg    <= 7'd0;
            device_address_reg   <= 5'd0;
            frame_space_done     <= 0;
        end else begin
            case (present_state)
                idle: begin
                    // Clear all counters and flags in idle state
                    cycle_counter        <= 0;
                    frame_space_counter  <= 0;
                    bit_counter          <= 0;
                    bit_low_counter      <= 0;
                    bit_high_counter     <= 0;
                    output_delay_counter <= 0;
                    bit_phase            <= 0;
                    decoded              <= 0;
                    failed               <= 0;
                    success              <= 0;
                    ir_output_valid      <= 0;
                    function_code_reg    <= 7'd0;
                    device_address_reg   <= 5'd0;
                    frame_space_done     <= 0;
                end
                start: begin
                    if (ir_signal_in == 1) begin
                        cycle_counter <= cycle_counter + 1;
                    end else begin
                        // Pulse ended; validate start pulse duration (2.4ms = 24 cycles)
                        if (cycle_counter != 24) begin
                            failed <= 1;
                            cycle_counter <= 0;
                        end else begin
                            started <= 1;
                            cycle_counter <= 0;
                        end
                    end
                end
                decoding: begin
                    if (bit_counter < 12) begin
                        if (ir_signal_in == 0 && bit_phase == 0) begin
                            bit_low_counter <= bit_low_counter + 1;
                            if (bit_low_counter >= 6) begin
                                bit_phase <= 1;
                                bit_low_counter <= 0;
                            end
                        end else if (ir_signal_in == 1 && bit_phase == 1) begin
                            bit_high_counter <= bit_high_counter + 1;
                            if (bit_high_counter == 6) begin
                                // Bit 0 detected
                                ir_frame_reg[bit_counter] <= 0;
                                bit_counter <= bit_counter + 1;
                                bit_phase <= 0;
                                bit_low_counter <= 0;
                                bit_high_counter <= 0;
                            end else if (bit_high_counter == 12) begin
                                // Bit 1 detected
                                ir_frame_reg[bit_counter] <= 1;
                                bit_counter <= bit_counter + 1;
                                bit_phase <= 0;
                                bit_low_counter <= 0;
                                bit_high_counter <= 0;
                            end
                        end
                    end else begin
                        decoded <= 1;
                        ir_frame_out <= ir_frame_reg;
                        success <= 1;
                        // Reset counters for potential next frame
                        bit_counter <= 0;
                        bit_low_counter <= 0;
                        bit_high_counter <= 0;
                        bit_phase <= 0;
                    end
                end
                finish: begin
                    if (output_delay_counter < 3) begin
                        output_delay_counter <= output_delay_counter + 1;
                    end else begin
                        // Map decoded frame to function code and device address
                        // Device Address: upper 5 bits
                        case (ir_frame_out[11:7])
                            5'b00001: device_address_reg <= 5'b00001; // TV
                            5'b00010: device_address_reg <= 5'b00010; // HDMI1
                            5'b00100: device_address_reg <= 5'b00100; // USB
                            5'b01000: device_address_reg <= 5'b01000; // HDMI2
                            5'b10000: device_address_reg <= 5'b10000; // VCR
                            default:  device_address_reg <= 5'd0;
                        endcase
                        // Function Code: lower 7 bits (command)
                        case (ir_frame_out[6:0])
                            7'b0000001: function_code_reg <= 7'b0000001; // digit 1
                            7'b0000010: function_code_reg <= 7'b0000010; // digit 2
                            7'b0000011: function_code_reg <= 7'b0000011; // digit 3
                            7'b0000100: function_code_reg <= 7'b0000100; // digit 4
                            7'b0000101: function_code_reg <= 7'b0000101; // digit 5
                            7'b0000110: function_code_reg <= 7'b0000110; // digit 6
                            7'b0000111: function_code_reg <= 7'b0000111; // digit 7
                            7'b0001000: function_code_reg <= 7'b0001000; // digit 8
                            7'b0001001: function_code_reg <= 7'b0001001; // digit 9
                            7'b0000000: function_code_reg <= 7'b0000000; // digit 0
                            7'b0011111: function_code_reg <= 7'b0011111; // channel +
                            7'b0101111: function_code_reg <= 7'b0101111; // channel -
                            7'b0111111: function_code_reg <= 7'b0111111; // volume +
                            7'b1001111: function_code_reg <= 7'b1001111; // volume -
                            7'b1011111: function_code_reg <= 7'b1011111; // mute
                            7'b1101111: function_code_reg <= 7'b1101111; // power
                            7'b1111111: function_code_reg <= 7'b1111111; // pause
                            default:    function_code_reg <= 7'd0;
                        endcase
                        // Assert valid signal for one cycle
                        ir_output_valid <= 1;
                        output_delay_counter <= 0;
                    end
                end
                frame_space: begin
                    if (ir_signal_in == 0) begin
                        frame_space_counter <= frame_space_counter + 1;
                        if (frame_space_counter >= 450) begin
                            frame_space_done <= 1;
                        end else begin
                            frame_space_done <= 0;
                        end
                    end else begin
                        // If signal goes high unexpectedly, treat as error
                        frame_space_counter <= 0;
                        frame_space_done <= 0;
                    end
                end
                default: begin
                    cycle_counter        <= 0;
                    frame_space_counter  <= 0;
                    bit_counter          <= 0;
                    bit_low_counter      <= 0;
                    bit_high_counter     <= 0;
                    output_delay_counter <= 0;
                    bit_phase            <= 0;
                    decoded              <= 0;
                    failed               <= 0;
                    success              <= 0;
                    ir_output_valid      <= 0;
                    function_code_reg    <= 7'd0;
                    device_address_reg   <= 5'd0;
                    frame_space_done     <= 0;
                end
            endcase
        end
    end

    // Drive outputs from registered decoded values
    always_ff @(posedge clk_in or posedge reset_in) begin
        if (reset_in) begin
            ir_function_code_out <= 7'd0;
            ir_device_address_out<= 5'd0;
        end else begin
            ir_function_code_out <= function_code_reg;