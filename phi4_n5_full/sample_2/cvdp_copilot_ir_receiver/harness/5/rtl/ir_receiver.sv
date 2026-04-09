<think>We are asked: "You are solving an 'RTL Code Completion' problem. To solve this problem correctly, you should only respond with the RTL code generated according to the requirements." And instructions: "Provide me one answer for this request: Complete the given partial SystemVerilog code for an IR receiver module that decodes a 12-bit IR frame transmitted by a Sony remote control. The module must decode the frame, extract the function code and device address, and output their corresponding values and a valid signal. The design must adhere to the Sony IR protocol, handle invalid or incomplete frames, and manage the frame space between consecutive transmissions."

The partial RTL code is given with incomplete state machine and missing code. We have to complete the code to implement the IR receiver module that decodes a 12-bit frame according to the Sony IR protocol. The code has states: idle, start, decoding, finish, frame_space, etc.

Let's re-read the requirements.

We have a module called "ir_receiver". It has the following ports:
- reset_in: active-high reset.
- clk_in: system clock (10KHz, 100us).
- ir_signal_in: input IR signal.
- ir_function_code_out: 7 bits output.
- ir_device_address_out: 5 bits output.
- ir_output_valid: output valid signal.

The state machine uses states: idle, start, decoding, finish, frame_space. There is also code in the always_ff block that updates state on posedge clk or reset.

Inside the always_comb block, there is a case for states: idle, start, decoding, finish. But then incomplete code. We have to complete code for decoding and frame space logic.

We have some signals:
- started, decoded, failed, success, frame_full, ir_frame_valid.
- cycle_counter, frame_space_counter, bit_counter.
- ir_frame_reg, ir_frame_out.
- stored.

We see that the code is incomplete. We need to implement: in state idle: waiting for IR signal to be high for 2.4ms start bit. In state start: we wait for a 0 pulse to confirm the start bit. In decoding: we need to decode 12 bits. Each bit consists of a low pulse and then a high pulse. The durations are either 0.6 ms for both pulses for bit 0 or 0.6 ms for low and 1.2 ms for high for bit 1. The clock is 10KHz, so each clock cycle is 100us. But wait: 2.4ms equals 24 clock cycles, 0.6ms equals 6 cycles, 1.2ms equals 12 cycles, 45ms equals 450 cycles. So we can implement counters for the pulses.

We have to do:
- In idle: if ir_signal_in is high, then we start the start bit detection. But we need to count cycles for start bit. So in idle, we need to count cycles until the start bit is complete (should be 2.4ms high) then transition to start state? But the given code says: in idle, if (ir_signal_in == 1 && started == 0) then next_state = start. But that doesn't incorporate counter. So we need to incorporate counters.

Let's design our state machine with counters. We'll use cycle_counter for start bit detection. But maybe we need separate counters for start, decoding, etc.

Plan:
- We'll use a cycle counter (maybe a reg integer cycle_counter) that counts the number of clock cycles in the current pulse. We'll also use bit_counter to count the number of bits decoded.

Define constants:
- START_BIT_DURATION = 24 cycles (2.4ms)
- LOW_PULSE_DURATION = 6 cycles (0.6ms)
- HIGH_PULSE_DURATION_FOR_ZERO = 6 cycles (0.6ms) or for one bit 1: HIGH_PULSE_DURATION = 12 cycles (1.2ms)
- FRAME_SPACE_DURATION = 450 cycles (45ms)

We have states: idle, start, decoding, finish, frame_space. But we might also have substates for decoding each bit? Possibly we can combine into decoding state with subcounters.

We can use counters:
- In idle: count cycles while ir_signal_in is high. Once count reaches START_BIT_DURATION, then we transition to start state. Also, if signal goes low before that, then consider failure.
- In start: after start bit, we expect a low pulse of 6 cycles. So in state start, we wait for ir_signal_in to go low (should be low) and then count cycles. If low pulse is not of correct duration, then set failed = 1. If low pulse completes (6 cycles), then transition to decoding state.
- In decoding: For each bit, we need to count a low pulse of 6 cycles, then a high pulse of either 6 cycles (for 0) or 12 cycles (for 1). So we need a bit-level counter that counts low and high pulses. So in decoding, we need a bit counter and a subcounter for pulse duration. But we can design state machine as: decoding state, then use a local counter that resets to 0 and then counts low pulse. After low pulse, record bit value? Actually, we need to decode each bit as follows: The IR signal should alternate: low then high. So the decoding process: For each bit, the IR signal goes low for 6 cycles, then high for either 6 cycles (bit 0) or 12 cycles (bit 1). But how to differentiate? We can count the high pulse. So we can have a "bit_low" and "bit_high" substate inside decoding. But our state machine is simple: states: idle, start, decoding, finish, frame_space. We can incorporate subcounters in always_comb block? Alternatively, we can use a nested state machine. But since we have a single always_comb block, we can incorporate additional signals that represent substate of decoding.

Maybe we can add a new signal "bit_phase" that can be 0 or 1: bit_phase 0 means low pulse, bit_phase 1 means high pulse. Then in decoding, if bit_phase == 0, count cycles for low pulse. Once count equals LOW_PULSE_DURATION (6 cycles), then record bit value? Actually, for decoding, we can't record bit value until we see the high pulse length. The bit value is determined by the duration of the high pulse. But we can store the bit temporarily? Actually, the protocol: each bit: low pulse (6 cycles) then high pulse (6 cycles for 0, 12 cycles for 1). So we can count the low pulse, then count the high pulse. But then we need to determine the bit value from the high pulse length. But the high pulse length is determined after the low pulse is finished. So we can do: in decoding state, if bit_phase==0 (low pulse), count cycles until 6 cycles, then set bit_phase = 1, and reset counter. Then in bit_phase==1, count cycles. If count equals 6 then bit=0, if count equals 12 then bit=1, else error. But wait, what if the pulse length is not exactly 6 or 12? We can consider a margin? But the problem doesn't specify margin, so we assume exact durations. So we need a counter that counts cycles for the current pulse. And a signal bit_phase that indicates which pulse we are in for the current bit.

Plan: 
Define signals:
- reg [5:0] pulse_counter; (6 bits enough for up to 12 cycles)
- reg [5:0] bit_counter; (for 12 bits)
- reg [1:0] bit_phase; // 0 for low pulse, 1 for high pulse.
- reg [11:0] ir_frame_reg; // will store decoded bits in order? The order: first bit goes to MSB? But spec: "The module must decode a 12-bit IR frame extracted from FINISH state" but the function code is lower 7 bits and device address is upper 5 bits. So the frame bits: bit[11:7] = device address, bit[6:0] = function code? But the examples: Example 1: 12'b001000010110. Let's check: 001000010110, device address = first 5 bits = 00100 (which is 4 decimal, corresponding to VCR) but expected output is ir_device_address_out = 5'b10000 which is VCR. Wait check: Example 1: expected output: ir_function_code_out = 7'b1111111 and ir_device_address_out = 5'b10000. But the frame bits: 001000010110, if we split: MSB 5 bits: 00100 = 4 decimal, but expected output is 5'b10000, which is 16 decimal. So maybe the device address is not simply the upper 5 bits, but maybe we need to decode using a lookup table? Actually, check the Address Decoding Table: Address is the MSB 5-bit information received in 12-bit frame. The table:
Address | Device    | ir_device_address_out
0       | TV        | 5'b00001
1       | HDMI1     | 5'b00010
2       | USB       | 5'b00100
3       | HDMI2     | 5'b01000
4       | VCR       | 5'b10000

So if the upper 5 bits are 00100, that corresponds to USB (which is 5'b00100), but expected output for Example 1 is 5'b10000 (VCR). So maybe the frame bits order is reversed? Let's re-read: "Extract the function code and device address." It says: "The module must decode a 12-bit IR frame extracted from FINISH state. Extract: Function Code: lower 7 bits, Device Address: upper 5 bits." So if frame is 12 bits, then bit positions: bits 11:7 are device address, bits 6:0 are function code. So for Example 1: frame: 001000010110. Then bits 11:7 = 00100 which is 4 decimal, so device address should be 5'b10000 (VCR) if the mapping is: 4 -> VCR. Yes, that fits: 4 maps to VCR (5'b10000). And function code: bits 6:0 = 000110, which is 6 decimal, but expected output is 7'b1111111? Wait, expected output for Example 1: function code = 7'b1111111. That is 127 decimal. But the table for function decoding: Command is LSB 7-bit information. For command 127, function is "pause" but table says for command 22, pause is 7'b1111111. But our bits 6:0 for frame 001000010110 = 000110 which is 6 decimal, not 22. There's a discrepancy.

Let's re-read the examples: 
Example 1: Input: valid IR signal with a 2.4 ms start bit, followed by 12 valid data bits (12'b001000010110). Expected Output: ir_function_code_out = 7'b1111111, ir_device_address_out = 5'b10000, ir_output_valid = 1.
Example 2: Input: valid IR signal with a 2.4 ms start bit, followed by 12 valid data bits (12'b000000010000). Expected Output: ir_function_code_out = 7'b0011111, ir_device_address_out = 5'b00001, ir_output_valid = 1.

Let's analyze Example 2: frame = 000000010000. Split: MSB 5 bits = 00000, function code = 000010. According to table, if command is 2, digit 3? Wait, check function decoding table: For command 2, digit 3, function code is 7'b0000011. But expected is 7'b0011111. That doesn't match either.

Maybe the frame bits order is reversed: maybe the first bit received is function code, then device address? But then Example 1: 12'b001000010110: function code (first 7 bits) = 0010000 which is 8 decimal, but expected is 7'b1111111 which is 127 decimal. So not that.

Maybe the mapping is not a direct mapping of bits to command. Perhaps we need to apply a function decoding table mapping command number (which is the decimal value of the lower 7 bits) to a fixed output. For Example 1, the lower 7 bits are 000110 (which is 6 decimal), but expected function code output is 7'b1111111. That corresponds to command 22 from table: "pause" is 7'b1111111. So maybe the frame bits are reversed: The command is actually the MSB 7 bits and device address is the LSB 5 bits? Let's try that: For Example 1: frame = 001000010110. If we split as command = 0010000 (7 bits) and device address = 10110 (5 bits). 7-bit command = 0x28 decimal 40, but table doesn't have 40. For Example 2: frame = 000000010000, command = 0000001 (7 bits) = 1, expected function code output is 7'b0011111, but table says for command 1, function code is 7'b0000010. That doesn't match either.

Maybe the expected outputs are given as examples and the frame bits need to be manipulated further? Let's re-read the problem statement carefully:

"Complete the given partial SystemVerilog code for an IR receiver module that decodes a 12-bit IR frame transmitted by a Sony remote control. The module must decode the frame, extract the function code and device address, and output their corresponding values and a valid signal. The design must adhere to the Sony IR protocol, handle invalid or incomplete frames, and manage the frame space between consecutive transmissions."

"Decoding Logic: The module must: Decode a 12-bit frame extracted from FINISH state. Extract: Function Code: The lower 7 bits of the frame (ir_function_code_out). Device Address: The upper 5 bits of the frame (ir_device_address_out). Output a valid signal (ir_output_valid) indicating successful decoding."

So the frame is 12 bits, with the lower 7 bits representing the command (which then is mapped via the function decoding table) and the upper 5 bits representing the device address (which is then mapped via the address decoding table). But then the examples: 
Example 1: 12'b001000010110. Lower 7 bits = 0010000 (binary) = 40 decimal, but table: command 16: channel + is 7'b0011111, command 17: channel - is 7'b0101111, command 18: volume + is 7'b0111111, command 19: volume - is 7'b1001111, command 20: mute is 7'b1011111, command 21: power is 7'b1101111, command 22: pause is 7'b1111111. 40 decimal is not in table. 
Alternatively, if we consider lower 7 bits = 0010001? Because if we take the last 7 bits of 001000010110, that would be 0010001 = 17 decimal. And then device address = first 5 bits = 00100 = 4 decimal, which maps to VCR (5'b10000). And expected output for Example 1: function code = 7'b1111111, which is 127 decimal, which corresponds to command 22 (pause). So maybe there's an error in the splitting? Let's try: if we take lower 7 bits as bits [6:0] (starting from LSB) then for frame 001000010110, bits [6:0] = 010110 = 22 decimal. And bits [11:7] = 00100 = 4 decimal. That fits! So the correct interpretation: The IR frame is 12 bits, where the function code is the lower 7 bits (bits 6:0) and the device address is the upper 5 bits (bits 11:7). So we need to extract that accordingly. So our decoding state machine should accumulate 12 bits in order, and then in finish state, we assign:
ir_function_code_out = function_code (mapped from command value) using table.
ir_device_address_out = device_address (mapped from address value) using table.

So our decoding process: We accumulate 12 bits in ir_frame_reg. The bit ordering: the first bit received goes into bit[0] or bit[11]? Usually, the first received bit is the start bit, but we already consumed the start bit separately. Then we decode 12 bits. But the protocol: The start bit is a 2.4ms pulse, then the data bits come. But the protocol table says 12 data bits, each bit encoded as low pulse then high pulse. So we need to decode 12 bits. The order: The first bit decoded is bit0? But then the function code is lower 7 bits, which means bits 0..6. But then device address is upper 5 bits, which are bits 7..11. But then the order of reception is: first bit received becomes bit0, then bit1, ... then bit11. But then lower 7 bits are bits 0..6, and upper 5 bits are bits 7..11. But then Example 1: frame 001000010110, if bit0 = 0, bit1 = 0, bit2 = 1, bit3 = 0, bit4 = 0, bit5 = 0, bit6 = 1, bit7 = 0, bit8 = 1, bit9 = 1, bit10 = 0, bit11 = ? Wait, 12'b001000010110 = bits: bit11=0, bit10=1, bit9=1, bit8=0, bit7=1, bit6=0, bit5=0, bit4=0, bit3=1, bit2=0, bit1=0, bit0=0. Then lower 7 bits (bit0..bit6) = 0,0,1,0,0,0,1 = binary 0010001 = 17 decimal, not 22. Hmm, let's re-read the expected outputs: Example 1 expected: function code = 7'b1111111 (which is 127 decimal) and device address = 5'b10000 (which is 16 decimal). That means the lower 7 bits should be 1111111 (127) and the upper 5 bits should be 10000 (16). So the full frame should be: upper 5 bits = 10000, lower 7 bits = 1111111. Concatenated, that's 12'b1000011111111, but that is 13 bits. Wait, 5+7=12. So the frame bits should be: bits[11:7] = 10000 (16) and bits[6:0] = 1111111 (127). That gives 12'b10000 1111111 = 12'b100001111111. In binary, that is 1 0000 1111111 = which is 1*2^11 + 0*2^10 + ... That equals 2048 + 127 = 2175 decimal. But the provided frame in Example 1 is 12'b001000010110 which is 12 bits with leading 0. So there is a discrepancy. Possibly the examples are arbitrary and do not match the bit extraction. Let's try Example 2: 12'b000000010000. If we split into upper 5 bits = 00000 (0) and lower 7 bits = 000010 (2 decimal). But expected function code is 7'b0011111 (which is 31 decimal) and device address is 5'b00001 (TV). So the mapping is not direct. It might be that the IR protocol has a fixed function code mapping for certain commands. The function decoding table provided is:
Command (decimal) | Function   | ir_function_code_out
0: digit 1 -> 7'b000_0001
1: digit 2 -> 7'b000_0010
2: digit 3 -> 7'b000_0011
3: digit 4 -> 7'b000_0100
4: digit 5 -> 7'b000_0101
5: digit 6 -> 7'b000_0110
6: digit 7 -> 7'b000_0111
7: digit 8 -> 7'b000_1000
8: digit 9 -> 7'b000_1001
9: digit 0 -> 7'b000_0000
16: channel + -> 7'b001_1111
17: channel - -> 7'b010_1111
18: volume + -> 7'b011_1111
19: volume - -> 7'b100_1111
20: mute -> 7'b101_1111
21: power -> 7'b110_1111
22: pause -> 7'b111_1111

Now, Example 1: command (lower 7 bits) should map to pause (7'b1111111) which corresponds to command 22. So the lower 7 bits should be 22 decimal, which in binary 7 bits is 00010110? Actually 22 decimal in 7 bits is 00010110. And device address: upper 5 bits should map to VCR which is 5'b10000 (which is 16 decimal). So the full frame should be: upper 5 bits = 10000 (16) and lower 7 bits = 00010110 (22). That gives 12'b10000 00010110 = 12'b1000000010110, but that's 13 bits. Let's recalc: 5 bits for address, then 7 bits for command. 5 bits can represent 0 to 31, 7 bits can represent 0 to 127. So the full frame is 12 bits total. The address is bits [11:7] and command is bits [6:0]. For command = 22, binary (7 bits) = 00010110? Actually 22 decimal in 7 bits: 22 = 16 + 6, so bits: 0,0,0,1,0,1,0? Let's compute: 22 in binary: 16 (2^4) + 4 (2^2) + 2 (2^1) = 10110, but need 7 bits: 00010110 is 8 bits though. Wait, 22 decimal in binary is 10110 (5 bits). But we need 7 bits, so it becomes 00010110. But that's 8 bits. Let's do it properly: 22 in 7 bits: 22 = 16 + 4 + 2 = 10110, but 7-bit representation: 00010110 is actually 8 bits because 10110 is 5 bits. Actually, 22 in 7 bits: it should be 00010110? Wait, 22 in binary is "10110". To represent it in 7 bits, you pad to left: "00010110" is 8 bits. Let's recalc: 22 in 7 bits: The highest bit is bit6. 22 < 64, so bit6=0. Then bit5=0, bit4=0, bit3=1 (16), bit2=0, bit1=1 (2), bit0=0. That gives 00010110 but that's 8 bits? Let's count: bit6, bit5, bit4, bit3, bit2, bit1, bit0. So 0,0,0,1,0,1,0. That is indeed 7 bits: 0,0,0,1,0,1,0. So the command is 0001010, but wait, that's 6 bits if we drop the leading zero. Let's write it properly: bit6=0, bit5=0, bit4=0, bit3=1, bit2=0, bit1=1, bit0=0. So that's 0001010, but that is 7 bits: count them: 0,0,0,1,0,1,0 -> that's 7 digits. So then the full frame becomes: address (5 bits) = for VCR, address is 4 (which in 5-bit representation is 00100?) Wait, table: VCR: 5'b10000 (which is 16 decimal). So address bits = 10000. And command bits = 0001010 (which is 10 decimal, not 22). So that doesn't match. Alternatively, if command is 22, in 7 bits, it is 00010110? Let's recalc: 22 in binary with 7 bits: The highest value is 64. 22 = 16 + 4 + 2 = 10110. To get 7 bits, we need to represent it as 00010110 if we assume the leftmost bit is bit6. But 00010110 is 8 bits because it has 8 digits: 0,0,0,1,0,1,1,0. Let's recalc: 22 / 2^6 = 22/64 = 0 remainder 22, so bit6=0; then 22/2^5=22/32 = 0, remainder 22; then 22/2^4=22/16 = 1, remainder 6; then 6/2^3=6/8=0, remainder 6; then 6/2^2=6/4=1, remainder 2; then 2/2^1=1, remainder 0; then 0/2^0=0. So bits: bit6=0, bit5=0, bit4=1, bit3=0, bit2=1, bit1=1, bit0=0. So that is 00010110. That is 8 bits. Wait, check: 7 bits means indices 6 to 0, that's 7 bits. So bit6, bit5, bit4, bit3, bit2, bit1, bit0. For 22, bit6=0, bit5=0, bit4=1, bit3=0, bit2=1, bit1=1, bit0=0. That gives binary: 0 0 1 0 1 1 0, which is 22 indeed. So the command is 0001010? Let's write it with 7 digits: 0,0,0,1,0,1,0. That is 0001010. But we want to display it as 7'b0001010, but that's 7 bits. But our expected output for Example 1 is 7'b1111111. So maybe the mapping table is not used to extract the command from the bit stream but instead the command number is used to index the function code output. The table: for command 22, function code output is 7'b1111111. So we need to take the lower 7 bits as a number (0 to 127), and then use a combinational block to map that number to the function code output according to the table. And similarly, take the upper 5 bits as a number (0 to 31) and map that to the device address output according to the table.

Given the function decoding table, we can implement a combinational block that does a case on the command value. But note that the table has specific values for commands 0-9, 16-22. For other commands, maybe default to 0.

Similarly, address decoding table: for address 0, output 5'b00001, for 1, output 5'b00010, for 2, output 5'b00100, for 3, output 5'b01000, for 4, output 5'b10000. And for other addresses, maybe default to 0.

Now, also the output valid signal: It is high for one clock cycle after decoding is finished, with 3 clock cycle latency. So we need a register that latches the decoded data and then outputs them for one cycle, and then goes low.

We also need to handle invalid or incomplete frames. So if the decoding fails at any point, we need to reset state machine to idle and clear outputs.

We also need to manage frame space: after finish, in state frame_space, we wait for 45ms (450 cycles) of no IR signal? Actually, frame space is defined as: "The frame ends with a 45ms space before the next frame starts." So in frame_space, we wait until the IR signal is low for 450 cycles. But careful: The protocol: The IR signal goes high for the frame and then goes low for 45ms, then next frame. So in frame_space, we wait for the IR signal to remain low for 450 cycles, then return to idle.

Now, the partial code includes "always_comb" block with case for states idle, start, decoding, finish. It says "Insert code for decoding and frame space logic here" at the end of the always_comb block. So we need to complete that always_comb block. But also we need to implement the always_ff blocks that handle state transitions and counters.

We see that the always_ff block currently only updates present_state. We need additional always_ff blocks or always_comb blocks to update counters and outputs.

Plan: We'll add registers for cycle_counter, frame_space_counter, bit_counter, pulse_counter, bit_phase, etc.

We can use always_ff @(posedge clk_in or posedge reset_in) begin ... end blocks for state machine and counters.

We need to implement different behaviors for each state.

Let's design state transitions and counter updates:

Let's define constants:
- parameter START_BIT_DURATION = 24; // cycles for start bit high
- parameter LOW_DURATION = 6; // cycles for low pulse for each bit
- parameter ZERO_HIGH_DURATION = 6; // cycles for high pulse for bit 0
- parameter ONE_HIGH_DURATION = 12; // cycles for high pulse for bit 1
- parameter FRAME_SPACE_DURATION = 450; // cycles for frame space

We need registers:
- reg [5:0] pulse_counter; // for counting pulse durations
- reg [5:0] bit_counter; // count bits decoded
- reg [1:0] bit_phase; // 0 for low pulse, 1 for high pulse

We also have "started" flag maybe to indicate that start bit was detected. And "decoded" flag maybe to indicate that one bit is decoded. And "failed" flag to indicate error. And "success" flag to indicate frame fully decoded.

We also have "ir_frame_reg" to store the 12-bit frame. And "stored" flag maybe to indicate that frame is stored.

We also have "ir_output_valid" output. And "ir_function_code_out" and "ir_device_address_out" outputs.

We also need to implement a combinational block for decoding the function code from the command (lower 7 bits) and device address from the address (upper 5 bits). We can implement that using a combinational always_comb block that takes ir_frame_out (which is the stored frame) and produces outputs.

We also need to implement a one-cycle pulse for valid signal with 3 clock cycles latency after finish. So we can use a register "output_valid_reg" that gets asserted in finish state after delay, then goes low in next cycle.

Plan structure:

We have a state machine that runs on posedge clk_in or reset_in. We'll update present_state based on next_state. And we'll update counters and signals based on state.

We have states: idle, start, decoding, finish, frame_space.

Let's design transitions:

State: idle:
- When in idle, if ir_signal_in is high, then we start counting the start bit. We'll set a counter "start_counter" maybe.
- If ir_signal_in goes low before reaching 24 cycles, then frame is invalid, so set failed = 1 and remain in idle.
- Alternatively, if start bit is not detected properly, then state remains idle.

We already see in always_comb block: 
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

But this is incomplete. We need to add frame_space state in the always_comb block as well.

Let's add frame_space: in frame_space, if frame_space_counter >= FRAME_SPACE_DURATION, then next_state = idle, else remain in frame_space.

Now, what counters do we need? We need a counter for the start bit in idle. But the code doesn't show that. We can use cycle_counter for that. In idle, if ir_signal_in is high and started==0, then we start counting cycles. We can set started flag and use cycle_counter. If cycle_counter reaches START_BIT_DURATION, then we consider start bit valid and move to start state. But the provided code in idle: if (ir_signal_in == 1 && started == 0) then next_state = start; but that doesn't check duration. So we need to modify that.

Maybe we do: In idle, if ir_signal_in is high, then set started flag and start counting cycle_counter. If cycle_counter equals START_BIT_DURATION, then clear cycle_counter and set started flag? But then transition to start? But the provided code in idle does "if (ir_signal_in == 1 && started == 0) next_state = start;" which is not checking duration. We need to incorporate duration.

I propose to use a separate counter for the start bit, e.g., "start_counter". But the partial code uses "cycle_counter". Let's repurpose cycle_counter for the start bit in idle.

Plan:
- In idle: if (ir_signal_in == 1 && started == 0), then start counting: set cycle_counter = 0 and started = 1.
- If cycle_counter < START_BIT_DURATION, then remain in idle.
- If cycle_counter == START_BIT_DURATION, then go to start state.
- Also, if ir_signal_in goes low before reaching START_BIT_DURATION, then mark failure and reset cycle_counter and started.

Now, state start:
- In state start, we expect a low pulse of duration LOW_DURATION (6 cycles). So when entering start, we expect ir_signal_in to be 0. So we set pulse_counter = 0 and bit_phase = 0 (low phase for the first bit).
- If ir_signal_in is low, then increment pulse_counter. If pulse_counter reaches LOW_DURATION, then we have completed the low pulse. Then transition to decoding state, and set bit_phase to 1 for the next bit's high pulse. Also, bit_counter remains 0 because we haven't stored a bit yet.
- If ir_signal_in goes high prematurely or if pulse_counter > LOW_DURATION, then mark failure.

State decoding:
- In decoding state, we are in the middle of decoding a bit. We use pulse_counter and bit_phase.
- If bit_phase == 0 (low pulse), then we expect ir_signal_in to be low. We count pulses. When pulse_counter equals LOW_DURATION, then we have completed the low pulse. At that moment, we transition to bit_phase = 1 and reset pulse_counter. Also, we latch the bit? But the bit value is determined by the high pulse length. So we don't latch the bit yet.
- If bit_phase == 1 (high pulse), then we expect ir_signal_in to be high. We count pulses. If pulse_counter equals ZERO_HIGH_DURATION (6 cycles), then the bit is 0. If pulse_counter equals ONE_HIGH_DURATION (12 cycles), then the bit is 1. If pulse_counter is between these values or not equal, then error.
- After processing a bit (either low pulse completed or high pulse completed), we increment bit_counter. And if bit_counter == 12 (all bits received), then mark success and transition to finish state.
- Also, if ir_signal_in does not match expected (e.g., in low pulse, if signal goes high, error), then mark failure.

We need to store the bit in ir_frame_reg. But the order: the first bit goes to bit0, then bit1, etc. But then later, function code is lower 7 bits and device address is upper 5 bits. So ir_frame_reg[6:0] = command, ir_frame_reg[11:7] = device address. So when we decode a bit, we shift it into the register. But careful: the first bit we receive should be stored in bit0. So we can do: ir_frame_reg <= {ir_frame_reg[10:0], received_bit} if we are shifting in LSB first. But then later, the lower 7 bits are command. But then the upper 5 bits are device address. But then the mapping is: device_address = ir_frame_reg[11:7] and command = ir_frame_reg[6:0]. But the examples: Example 1: expected device address = 5'b10000 and function code = 7'b1111111. That means command (ir_frame_reg[6:0]) should be 127 (0x7F) and device address (ir_frame_reg[11:7]) should be 16 (0x10). So the frame would be: bits 11:7 = 10000 and bits 6:0 = 1111111. That is 12 bits: 10000 1111111 = 0x807F? Let's check: 10000 (binary) = 16, and 1111111 (binary) = 127, so frame = (16 << 7) | 127 = (16*128 + 127) = 2048 + 127 = 2175 decimal. But the given example frame in Example 1 is 12'b001000010110, which is 402 decimal. So the examples don't match the bit splitting. I think we should follow the spec: lower 7 bits = function code, upper 5 bits = device address. And then use the decoding tables. So I'll assume the bit extraction is as specified.

So in decoding state, we shift in bits. We'll use a shift register of 12 bits. When a bit is decoded, we do: ir_frame_reg <= {ir_frame_reg[10:0], decoded_bit}.

We need to decide what is the expected pulse: in low pulse, ir_signal_in should be low, in high pulse, ir_signal_in should be high. So in decoding state:
if (bit_phase == 0) then if (ir_signal_in != 0) then error, else count pulse_counter.
if (bit_phase == 1) then if (ir_signal_in != 1) then error, else count pulse_counter.
After pulse is complete, if low pulse complete, then set bit_phase = 1, reset pulse_counter.
After high pulse complete, then determine bit value:
if (pulse_counter == ZERO_HIGH_DURATION) then bit = 0.
if (pulse_counter == ONE_HIGH_DURATION) then bit = 1.
Else error.
Then shift in the bit.
Increment bit_counter.
If bit_counter == 12 then mark success and transition to finish.

We also need to handle reset and failure: if error detected, set failed = 1, reset counters, and go to idle.

Now, state finish:
- In finish state, we have successfully decoded the frame. We then latch the frame into ir_frame_out, and then assert output valid signal after a 3-cycle latency. We might need a counter for output latency.
- We also need to output the decoded function code and device address using combinational logic. But the spec says "The output latency is 3 clock cycles after the 12-bit decoding process is completed. Once the decoding process finishes, the decoded outputs (ir_function_code_out, ir_device_address_out) and the validity signal (ir_output_valid) will be HIGH for one clock cycle." So we can implement a pipeline stage: In finish state, we set a register "decoded_data_valid" that will be high for one cycle after 3 cycles. We can use a register "latency_counter" that counts 3 cycles. When latency_counter == 3, then output valid is high and then on next cycle, it goes low.

Maybe we can do: always_ff @(posedge clk_in or posedge reset_in) begin if (reset_in) latency_counter <= 0; else if (present_state == finish) then latency_counter <= latency_counter + 1; else latency_counter <= 0; end
And then ir_output_valid <= (present_state == finish && latency_counter == 3) ? 1'b1 : 1'b0;
But the spec says "HIGH for one clock cycle", so maybe we need to latch the data for one cycle then clear.

Alternatively, we can use a register "output_valid_reg" that is set in finish state and then goes low in next cycle. But then 3 cycle latency means that we wait 3 cycles after finish before asserting valid.

Plan: We'll have a register "output_latency" that counts cycles in finish state. When finish state is entered, set output_latency = 0. Then in finish state, increment output_latency each cycle. When output_latency reaches 3, then assert ir_output_valid for one cycle and then go back to idle. But careful: the spec says "output latency is 3 clock cycles after the decoding process is completed", which means that the outputs appear 3 cycles after finish state. And they are high for one cycle. So we can do: if (present_state == finish) then output_latency++; if (output_latency == 3) then set ir_output_valid to 1 and then transition to idle? But then the outputs should be latched for one cycle. But then the outputs should be derived from the decoded frame. We can compute function code and device address from ir_frame_out in combinational logic and then latch them when valid.

We have outputs: ir_function_code_out, ir_device_address_out. We can compute them using combinational always_comb block that takes ir_frame_out. For example:
function_code = decode_command(ir_frame_out[6:0]); device_address = decode_address(ir_frame_out[11:7]);
We then assign these outputs only when ir_output_valid is high.

But the spec says "the decoded outputs will be HIGH for one clock cycle." So maybe we need to store them in registers that are updated in finish state and then held for one cycle. Alternatively, we can simply assign them continuously and only assert valid when they are updated. But then they might not be stable for one cycle. However, the spec says "output latency is 3 clock cycles" and "HIGH for one clock cycle". So we can design: when finish state is active, we update a register "decoded_data" that holds the computed function code and device address. Then we have a register "output_valid" that is asserted in the next cycle after 3 cycles. But then it is high for one cycle. Then we clear the register.

We can do: always_ff @(posedge clk_in or posedge reset_in) begin if (reset_in) begin ir_function_code_out <= 7'b0; ir_device_address_out <= 5'b0; ir_output_valid <= 1'b0; end else begin case (present_state) finish: begin if (output_latency == 3) begin ir_function_code_out <= computed_function; ir_device_address_out <= computed_address; ir_output_valid <= 1'b1; end else begin ir_function_code_out <= ir_function_code_out; ir_device_address_out <= ir_device_address_out; ir_output_valid <= 1'b0; end; if (present_state == finish) output_latency <= output_latency + 1; else output_latency <= 0; end; end case; end

But we need to compute computed_function and computed_address from ir_frame_out. We can do that in combinational always_comb block that uses a case statement on ir_frame_out[6:0] and ir_frame_out[11:7]. But then we need to store ir_frame_out in a register that gets updated in finish state.

We already have ir_frame_reg and ir_frame_out. So we can assign ir_frame_out <= ir_frame_reg in finish state. But ir_frame_reg is updated in decoding state. So in finish state, we can latch it.

Let's plan the always_ff blocks:

We need one always_ff block for state machine update:
always_ff @(posedge clk_in or posedge reset_in) begin
   if (reset_in) begin
      present_state <= idle;
      // reset counters and flags
      cycle_counter <= 0;
      pulse_counter <= 0;
      bit_counter <= 0;
      bit_phase <= 0;
      failed <= 0;
      success <= 0;
      output_latency <= 0;
      started <= 0;
      decoded <= 0;
      stored <= 0;
      ir_frame_reg <= 12'b0;
   end else begin
      present_state <= next_state;
      case (present_state)
         idle: begin
            // in idle, if start condition detected, count cycles
            if (ir_signal_in == 1 && started == 0) begin
                started <= 1;
                cycle_counter <= cycle_counter + 1;
                if (cycle_counter >= START_BIT_DURATION)
                    // valid start bit detected, move to next state in next clock
                    ; // next_state will be set in combinational block
            end else if (ir_signal_in == 0 && started == 1) begin
                // if signal goes low before start bit duration, error
                failed <= 1;
                started <= 0;
                cycle_counter <= 0;
            end else begin
                cycle_counter <= 0;
            end
         end
         start: begin
            // in start, expect low pulse for 6 cycles
            if (ir_signal_in == 0) begin
                pulse_counter <= pulse_counter + 1;
                if (pulse_counter >= LOW_DURATION) begin
                    // low pulse complete, now transition to decoding
                    bit_phase <= 1; // now expecting high pulse
                    pulse_counter <= 0;
                    // do not increment bit_counter because no bit is stored yet.
                end
            end else begin
                failed <= 1;
            end
         end
         decoding: begin
            if (bit_phase == 0) begin
                // low pulse phase
                if (ir_signal_in == 0) begin
                    pulse_counter <= pulse_counter + 1;
                    if (pulse_counter >= LOW_DURATION) begin
                        // complete low pulse, move to high pulse phase
                        bit_phase <= 1;
                        pulse_counter <= 0;
                    end
                end else begin
                    failed <= 1;
                end
            end else if (bit_phase == 1) begin
                // high pulse phase
                if (ir_signal_in == 1) begin
                    pulse_counter <= pulse_counter + 1;
                    if (pulse_counter == ZERO_HIGH_DURATION) begin
                        // bit 0 detected
                        ir_frame_reg <= {ir_frame_reg[10:0], 1'b0};
                        bit_phase <= 0;
                        pulse_counter <= 0;
                        bit_counter <= bit_counter + 1;
                        decoded <= 1; // one bit decoded
                        if (bit_counter == 12) begin
                           success <= 1;
                        end
                    end else if (pulse_counter == ONE_HIGH_DURATION) begin
                        // bit 1 detected
                        ir_frame_reg <= {ir_frame_reg[10:0], 1'b1};
                        bit_phase <= 0;
                        pulse_counter <= 0;
                        bit_counter <= bit_counter + 1;
                        decoded <= 1;
                        if (bit_counter == 12) begin
                           success <= 1;
                        end
                    end else if (pulse_counter > ONE_HIGH_DURATION) begin
                        // error: high pulse too long
                        failed <= 1;
                    end
                end else begin
                    failed <= 1;
                end
            end
         end
         finish: begin
            // Latch the frame
            ir_frame_out <= ir_frame_reg;
            stored <= 1;
            // Reset output latency counter
            output_latency <= 0;
         end
         frame_space: begin
            // In frame_space, wait for 45ms (450 cycles) of no IR signal (ir_signal_in should be 0)
            if (ir_signal_in == 0) begin
                frame_space_counter <= frame_space_counter + 1;
                if (frame_space_counter >= FRAME_SPACE_DURATION) begin
                    frame_space_counter <= 0;
                    // transition to idle
                end
            end else begin
                frame_space_counter <= 0;
            end
         end
         default: begin
            // default reset
            failed <= 0;
            success <= 0;
            started <= 0;
            decoded <= 0;
            stored <= 0;
            cycle_counter <= 0;
            pulse_counter <= 0;
            bit_counter <= 0;
            bit_phase <= 0;
            ir_frame_reg <= 12'b0;
         end
      endcase
   end
end

We need to define registers: cycle_counter, pulse_counter, bit_counter, output_latency, frame_space_counter. And signals: failed, success, started, decoded, stored.
We also need to update next_state in combinational always_comb block. That block currently has case for idle, start, decoding, finish, and we need to add frame_space.

We already have:
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
      frame_space: begin
         if (frame_space_counter >= FRAME_SPACE_DURATION)
             next_state = idle;
         else
             next_state = frame_space;
      end
      default: next_state = idle;
   endcase
end

We need to add signals: cycle_counter, pulse_counter, bit_counter, output_latency, frame_space_counter.
We need to declare them as integer registers. But in SystemVerilog, integer is allowed but maybe we want to use reg [5:0] for pulse_counter and bit_counter, and reg [8:0] for frame_space_counter since 450 cycles require 9 bits (2^9=512).
cycle_counter: maximum 24, so 6 bits is enough.
bit_counter: maximum 12, so 4 bits is enough.
pulse_counter: maximum 12, so 4 bits is enough.
output_latency: maximum 3, so 2 bits is enough.
frame_space_counter: maximum 450, so 9 bits is enough.

Let's declare them:
reg [5:0] cycle_counter;
reg [3:0] bit_counter;
reg [3:0] pulse_counter;
reg [1:0] output_latency;
reg [8:0] frame_space_counter;

Also, we need signals: started, decoded, failed, success, stored. They are declared as logic. We'll use logic for them.

Now, about the combinational block for decoding the function code and device address from ir_frame_out.
We can write an always_comb block that computes:
ir_function_code_out <= decode_command(ir_frame_out[6:0]);
ir_device_address_out <= decode_address(ir_frame_out[11:7]);
But these outputs should only be active when output is valid.
We can do:
always_comb begin
   // default assignments
   function_code = 7'b0;
   device_addr = 5'b0;
   case (ir_frame_out[6:0]) // command
      7'd0: function_code = 7'b000_0001;
      7'd1: function_code = 7'b000_0010;
      7'd2: function_code = 7'b000_0011;
      7'd3: function_code = 7'b000_0100;
      7'd4: function_code = 7'b000_0101;
      7'd5: function_code = 7'b000_0110;
      7'd6: function_code = 7'b000_0111;
      7'd7: function_code = 7'b000_1000;
      7'd8: function_code = 7'b000_1001;
      7'd9: function_code = 7'b000_0000;
      7'd16: function_code = 7'b001_1111;
      7'd17: function_code = 7'b010_1111;
      7'd18: function_code = 7'b011_1111;
      7'd19: function_code = 7'b100_1111;
      7'd20: function_code = 7'b101_1111;
      7'd21: function_code = 7'b110_1111;
      7'd22: function_code = 7'b111_1111;
      default: function_code = 7'b0;
   endcase
   case (ir_frame_out[11:7]) // address
      5'd0: device_addr = 5'b00001;
      5'd1: device_addr = 5'b00010;
      5'd2: device_addr = 5'b00100;
      5'd3: device_addr = 5'b01000;
      5'd4: device_addr = 5'b10000;
      default: device_addr = 5'b0;
   endcase
end

But we need to connect these computed values to ir_function_code_out and ir_device_address_out, but only when output is valid. We can use registers to latch them when output_latency == 3 in finish state.

We can do: always_ff @(posedge clk_in or posedge reset_in) begin
   if (reset_in) begin
      ir_function_code_out <= 7'b0;
      ir_device_address_out <= 5'b0;
      ir_output_valid <= 1'b0;
   end else begin
      case (present_state)
         finish: begin
            if (output_latency == 3) begin
               // latch outputs
               ir_function_code_out <= computed_function;
               ir_device_address_out <= computed_address;
               ir_output_valid <= 1'b1;
            end else begin
               ir_output_valid <= 1'b0;
            end
         end
         default: begin