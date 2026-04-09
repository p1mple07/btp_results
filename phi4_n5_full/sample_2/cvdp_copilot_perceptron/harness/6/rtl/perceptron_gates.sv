<think>We are given a file "rtl/perceptron_gates.sv" that is an RTL code module, and we need to modify it to add two microcode ROM control units: Training and Testing. The provided description is long and detailed. The solution must be provided as plain text, and the response must be saved as "rtl/perceptron_gates.sv" (i.e., the file name is the same). So our answer is the modified RTL code. It is expected to be plain text without JSON formatting.

We are asked: "Provide me one answer for this request: Modify the RTL module `perceptron_gates` to enhance its functionality by integrating two separate microcode ROM control units for Training and Testing." It is an RTL code modification problem. We need to incorporate additional signals, microcode ROM arrays for testing, and logic to choose between training and testing. The specification says: "the Training control unit adjusts the perceptron's weights and bias based on the perceptron learning rule, while the Testing control unit validates the trained model against predefined test vectors. The module supports gate-specific training and testing for AND, OR, NAND, and NOR operations, providing a complete pipeline for model training and verification."

We need to include two microcode ROM control units: one for training and one for testing. They are integrated into the module perceptron_gates. The design specification states: "The modified perceptron_gates module introduces enhancements: Testing Control Unit, Testing Vector Integration, Additions and Enhancements." Let's list what outputs we need to add:

Outputs signals to track the working of Testing operation performed by the microcode control unit:
- test_percep_present_state: 4-bit (logic [3:0])
- expected_percep_output: 4-bit signed ([3:0])
- test_percep_output: 4-bit signed ([3:0])
- test_percep_result: 4-bit signed ([3:0])
- test_percep_done: 4-bit signed ([3:0]) maybe? But the spec says test_percep_done is 4-bit signed ([3:0]) but maybe it is a logic vector? The specification says "test_percep_done(4-bit,signed,[3:0]): Indicates the completion of Testing operation". But in the original code, stop is 1-bit. But now we have a new signal test_percep_done.
- test_percep_x1: 4-bit signed ([3:0])
- test_percep_x2: 4-bit signed ([3:0])

We also need to add new arrays for testing vectors:
- test_inputs_x1: array of 16 elements, each 4-bit signed.
- test_inputs_x2: array of 16 elements, each 4-bit signed.
- test_expected_outputs: array of 16 elements, each 4-bit signed.

We also need a test microcode ROM for testing control unit. It says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." So maybe we add a new ROM for testing or we modify training ROM to include testing instructions? The spec says "integrate two separate microcode ROM control units", so likely we have two arrays: one for training and one for testing. The training ROM is already there, but we need to add a testing ROM. But then the design says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." So it might be that the training microcode ROM has instructions that, when stop condition is reached, then it transitions to testing. Alternatively, we can create a separate testing microcode ROM. The spec says "integrating two separate microcode ROM control units for Training and Testing", so I think we need to define a new ROM for testing, e.g. "logic [15:0] testing_rom [0:5]" or something similar.

But the spec says "The Testing microcode abstract algorithm: 
- Initialize all status variables (test_percep_done, test_percep_result, test_percep_output) to zero.
- Set test_percep_index to a predefined starting point based on the value of gate_select (0, 4, 8, or 12).
- Use the current test_percep_index to fetch inputs (test_percep_x1, test_percep_x2) and the expected_output from their respective arrays.
- Compute test_calc using the formula: percep_w1 * test_percep_x1 + percep_w2 * test_percep_x2 + percep_bias.
- Set test_percep_output to 1 if test_calc > threshold; set to 0 if test_calc is between -threshold and threshold; otherwise, set it to -1.
- Compare test_percep_output with expected_percep_output: if match, increment test_percep_result.
- Mark test_percep_done if test_percep_index reaches its terminal value associated with a gate.

We also need to add additional outputs: test_percep_present_state, expected_percep_output, test_percep_output, test_percep_result, test_percep_done, test_percep_x1, test_percep_x2, and test_percep_index.

We need to add a new always block for testing control unit. The training block uses always_ff @(posedge clk or negedge rst_n) for training. We can add a new always_ff block for testing control unit which is triggered when stop condition is true maybe, or we need a separate control signal that selects training or testing phase. The specification says "when a stop condition is achieved, then testing is performed." So likely we have a flag that indicates that training is done (stop==1) and then we begin testing. So we can use "if (stop)" then enter testing state. But careful: the training process already uses "stop" signal. But we need to differentiate between training and testing.

Maybe we add an extra state flag "test_mode". But the specification does not mention that. It says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." So maybe we modify the training microcode to check if stop==1 then execute testing instructions. But then that would mix training and testing in the same always block. Alternatively, we can add a new always_ff block that is enabled when stop is asserted, and then it executes the testing sequence.

I propose the following approach: We'll add a new signal "test_mode" which is a logic that indicates if the module is in testing mode. When training stops (stop==1) and not already in test mode, then set test_mode=1 and initialize testing variables. Then, in a separate always_ff block triggered by clock, if test_mode==1, then execute testing microcode steps. The testing microcode ROM may be integrated as a separate ROM array "logic [15:0] testing_rom [0:5]" with instructions for testing. But the specification gives an abstract testing algorithm, not explicit microcode instructions. We can implement that algorithm in an always_comb block or always_ff block. Let's do it in an always_ff block. We'll need new registers: test_percep_index (4-bit), test_percep_result (4-bit signed), test_percep_done (logic? but spec says 4-bit signed, but I'll treat it as 1-bit maybe? It says 4-bit signed, but could be logic? But I'll use logic signed [3:0] for test_percep_done maybe or logic [3:0] test_percep_done; but then it's 4-bit, but it's used as done flag. Alternatively, we can use logic test_percep_done; but spec says 4-bit signed [3:0]. Let's follow spec exactly: output logic signed [3:0] test_percep_done. But then value 1 means done? We can use "1" as done. But then it's signed. I'll do that.)
- test_percep_present_state: 4-bit, maybe logic [3:0] (but spec says signed, but I'll use logic [3:0] because it's an address.)
- expected_percep_output: logic signed [3:0].
- test_percep_output: logic signed [3:0].
- test_percep_x1: logic signed [3:0].
- test_percep_x2: logic signed [3:0].

We also need arrays for test vectors:
- logic signed [3:0] test_inputs_x1 [0:15];
- logic signed [3:0] test_inputs_x2 [0:15];
- logic signed [3:0] test_expected_outputs [0:15];

We also need to define the starting index based on gate_select. The specification says: "Set test_percep_index to a predefined starting point based on the value of gate_select (0, 4, 8, or 12)". So if gate_select is 2'b00 (AND) then index=0, if 2'b01 (OR) then index=4, if 2'b10 (NAND) then index=8, if 2'b11 (NOR) then index=12.
We can compute test_percep_index initial value: maybe use a combinational always block that sets test_percep_index = (gate_select == 2'b00 ? 4'd0 : (gate_select == 2'b01 ? 4'd4 : (gate_select == 2'b10 ? 4'd8 : 4'd12))).

We need to update test_percep_index in testing phase. The specification says: "Mark test_percep_done if the test_percep_index reaches its terminal value associated with a gate." But what is the terminal value? Possibly, for AND gate, terminal value = 4? But the spec says "based on the value of gate_select (0,4,8, or 12)". So maybe the test vector array has 16 elements, and the terminal index is 16? But the spec says "reaches its terminal value associated with a gate". For AND gate, maybe the test vectors for AND gate are stored in test_inputs_x1[0:3] and test_expected_outputs[0:3]. For OR gate, test vectors for OR gate are stored in test_inputs_x1[4:7] and test_expected_outputs[4:7]. For NAND, test_inputs_x1[8:11] and test_expected_outputs[8:11]. For NOR, test_inputs_x1[12:15] and test_expected_outputs[12:15]. So the terminal index would be 4 for AND gate, 8 for OR gate, 12 for NAND gate, and 16 for NOR gate. But the spec said starting point is 0,4,8,12. And then terminal values would be 4,8,12,16 respectively. So I'll implement that: if gate_select==00, then terminal index = 4; if 01 then terminal index = 8; if 10 then terminal index = 12; if 11 then terminal index = 16.

So in testing always block, we'll do something like:
- if (test_mode==1 and not test_percep_done) then:
   - if test_percep_index < terminal, then:
         - test_percep_x1 <= test_inputs_x1[test_percep_index]
         - test_percep_x2 <= test_inputs_x2[test_percep_index]
         - expected_percep_output <= test_expected_outputs[test_percep_index]
         - test_calc = percep_w1 * test_percep_x1 + percep_w2 * test_percep_x2 + percep_bias (compute multiplication, but note that in SystemVerilog multiplication of signed 4-bit numbers yields a result of maybe 8 bits? But we can assume it's 4-bit arithmetic, but we might need to extend. We can do: logic signed [7:0] test_calc; then assign test_calc = $signed(percep_w1) * $signed(test_percep_x1) + $signed(percep_w2) * $signed(test_percep_x2) + $signed(percep_bias); but then compare test_calc with threshold. But threshold is 4-bit signed, so we need to compare test_calc with threshold. But threshold is 4-bit, but test_calc might be 8-bit. We can compare test_calc with threshold extended to 8 bits maybe. Let's do: if (test_calc > {4'd0, threshold}) then test_percep_output = 1; else if (test_calc >= {4'd0, -threshold} && test_calc <= {4'd0, threshold}) then test_percep_output = 0; else test_percep_output = -1.
         - if (test_percep_output == expected_percep_output) then test_percep_result++.
         - test_percep_present_state <= test_percep_index (or maybe the ROM address, but I'll use test_percep_index for now).
         - test_percep_index++.
   - else:
         - test_percep_done <= 1 (or test_percep_done = 1, but spec says 4-bit signed, so assign test_percep_done = 1).
         - test_mode remains 1? Or maybe then we can deassert test_mode.
- And if stop==1 and not test_mode, then set test_mode=1 and initialize testing registers.

We need to add a new signal test_mode. So add: logic test_mode; and then in always_ff @(posedge clk or negedge rst_n) block, if not rst_n then test_mode <= 0, else if (stop==1 and test_mode==0) then test_mode <= 1, and initialize test registers.

We need to add new registers for testing: test_percep_index (logic [3:0]), test_percep_result (logic signed [3:0]), test_percep_done (logic signed [3:0]) maybe, test_percep_present_state (logic [3:0]).

We need to add arrays for test vectors. We can initialize them in an initial block. For each gate, we need to have test vectors. But specification says "predefined vectors for inputs and expected outputs stored as arrays (each array has a depth of 16, with each location storing a 4-bit value)". But then "provides support for gate-specific testing scenarios (gate_select)". So maybe we need to initialize the arrays with test vectors for each gate. We can create arrays like:

logic signed [3:0] test_inputs_x1 [0:15];
logic signed [4:0]? No, 4-bit. Similarly for test_inputs_x2 and test_expected_outputs.

We can fill them with some example values. The example waveform for OR gate: test_inputs_x1: [4'd1, -4'd1, 4'd1, -4'd1] for OR gate? Actually the waveform shows test_percep_x1 wave: "0......3456.....", data: ["4'd1","-4'd1","4'd1","-4'd1"]. And test_inputs_x2: similar. And expected_percep_output: ["4'd1","4'd1","4'd1","-4'd1"]. But that's for OR gate? The spec said for OR gate, expected output = 4'd1 for most cases, except maybe one negative. But the example waveform for OR gate: gate_select = 2'b01, test_expected_outputs: "4'd1","4'd1","4'd1","-4'd1". But then test_percep_result: increments from 4'd1 to 4'd2, etc.

We can define the arrays with 16 elements each, but only 4 elements are used per gate. We can fill the unused ones with 0. But to keep it simple, I'll fill them with some test vectors for each gate. But the specification doesn't give explicit values for all 16 entries, so I'll fill them with some default values. For example, for AND gate (gate_select=00): test_inputs_x1[0..3] could be: 4'd1, 4'd1, -4'd1, -4'd1; test_inputs_x2[0..3] could be: 4'd1, 4'd1, -4'd1, -4'd1; test_expected_outputs[0..3] could be: 4'd1, 4'd1, -4'd1, -4'd1.
For OR gate (gate_select=01): test_inputs_x1[4..7] could be: 4'd1, -4'd1, 4'd1, -4'd1; test_inputs_x2[4..7] could be: 4'd1, 4'd1, -4'd1, -4'd1; test_expected_outputs[4..7] could be: 4'd1, 4'd1, 4'd1, -4'd1.
For NAND gate (gate_select=10): test_inputs_x1[8..11] could be: 4'd1, -4'd1, 4'd1, -4'd1; test_inputs_x2[8..11] could be: 4'd1, 4'd1, -4'd1, -4'd1; test_expected_outputs[8..11] could be: -4'd1, -4'd1, -4'd1, 4'd1; (because NAND is inverse of AND)
For NOR gate (gate_select=11): test_inputs_x1[12..15] could be: 4'd1, -4'd1, 4'd1, -4'd1; test_inputs_x2[12..15] could be: 4'd1, 4'd1, -4'd1, -4'd1; test_expected_outputs[12..15] could be: -4'd1, -4'd1, -4'd1, 4'd1; (NOR is inverse of OR)

But the spec doesn't explicitly require us to fill arrays with test vectors for all 16 entries, but it says "depth of 16". So I'll fill the arrays with zeros for unused indices, and then fill the ones for each gate. But then we need to know which indices to use for each gate. We can compute starting index and terminal index as described. So for AND gate, starting index = 0 and terminal index = 4. For OR gate, starting index = 4 and terminal index = 8. For NAND gate, starting index = 8 and terminal index = 12. For NOR gate, starting index = 12 and terminal index = 16.

So I'll add new arrays:
   logic signed [3:0] test_inputs_x1 [0:15];
   logic signed [3:0] test_inputs_x2 [0:15];
   logic signed [3:0] test_expected_outputs [0:15];

And then in an initial block, I'll initialize them. I can fill them with some default values. For instance:
   initial begin
      // AND gate vectors (indices 0-3)
      test_inputs_x1[0] = 4'd1; test_inputs_x1[1] = 4'd1; test_inputs_x1[2] = -4'd1; test_inputs_x1[3] = -4'd1;
      test_inputs_x2[0] = 4'd1; test_inputs_x2[1] = 4'd1; test_inputs_x2[2] = -4'd1; test_inputs_x2[3] = -4'd1;
      test_expected_outputs[0] = 4'd1; test_expected_outputs[1] = 4'd1; test_expected_outputs[2] = -4'd1; test_expected_outputs[3] = -4'd1;
      // OR gate vectors (indices 4-7)
      test_inputs_x1[4] = 4'd1; test_inputs_x1[5] = -4'd1; test_inputs_x1[6] = 4'd1; test_inputs_x1[7] = -4'd1;
      test_inputs_x2[4] = 4'd1; test_inputs_x2[5] = 4'd1; test_inputs_x2[6] = -4'd1; test_inputs_x2[7] = -4'd1;
      test_expected_outputs[4] = 4'd1; test_expected_outputs[5] = 4'd1; test_expected_outputs[6] = 4'd1; test_expected_outputs[7] = -4'd1;
      // NAND gate vectors (indices 8-11)
      test_inputs_x1[8] = 4'd1; test_inputs_x1[9] = -4'd1; test_inputs_x1[10] = 4'd1; test_inputs_x1[11] = -4'd1;
      test_inputs_x2[8] = 4'd1; test_inputs_x2[9] = 4'd1; test_inputs_x2[10] = -4'd1; test_inputs_x2[11] = -4'd1;
      test_expected_outputs[8] = -4'd1; test_expected_outputs[9] = -4'd1; test_expected_outputs[10] = -4'd1; test_expected_outputs[11] = 4'd1;
      // NOR gate vectors (indices 12-15)
      test_inputs_x1[12] = 4'd1; test_inputs_x1[13] = -4'd1; test_inputs_x1[14] = 4'd1; test_inputs_x1[15] = -4'd1;
      test_inputs_x2[12] = 4'd1; test_inputs_x2[13] = 4'd1; test_inputs_x2[14] = -4'd1; test_inputs_x2[15] = -4'd1;
      test_expected_outputs[12] = -4'd1; test_expected_outputs[13] = -4'd1; test_expected_outputs[14] = -4'd1; test_expected_outputs[15] = 4'd1;
   end

Now, we need to add new outputs in the module port list. The original module has ports:
module perceptron_gates (
   input  logic clk, input  logic rst_n, input  logic signed [3:0] x1, input  logic signed [3:0] x2, input  logic learning_rate, input  logic signed [3:0] threshold, input  logic [1:0] gate_select, output logic signed [3:0] percep_w1, output logic signed [3:0] percep_w2, output logic signed [3:0] percep_bias, output logic [3:0] present_addr, output logic stop, output logic [2:0] input_index, output logic signed [3:0] y_in, output logic signed [3:0] y, output logic signed [3:0] prev_percep_wt_1, output logic signed [3:0] prev_percep_wt_2, output logic signed [3:0] prev_percep_bias
);

We need to add additional outputs for testing:
- output logic [3:0] test_percep_present_state,
- output logic signed [3:0] expected_percep_output,
- output logic signed [3:0] test_percep_output,
- output logic signed [3:0] test_percep_result,
- output logic signed [3:0] test_percep_done,
- output logic signed [3:0] test_percep_x1,
- output logic signed [3:0] test_percep_x2.

We also need to add a new output for test_percep_index maybe? But spec says: "test_percep_index[3:0]" is used in waveform. So add output logic [3:0] test_percep_index.

So new port list becomes:

module perceptron_gates (
   input  logic clk,
   input  logic rst_n,
   input  logic signed [3:0] x1,
   input  logic signed [3:0] x2,
   input  logic learning_rate,
   input  logic signed [3:0] threshold,
   input  logic [1:0] gate_select,
   output logic signed [3:0] percep_w1,
   output logic signed [3:0] percep_w2,
   output logic signed [3:0] percep_bias,
   output logic [3:0] present_addr,
   output logic stop,
   output logic [2:0] input_index,
   output logic signed [3:0] y_in,
   output logic signed [3:0] y,
   output logic signed [3:0] prev_percep_wt_1,
   output logic signed [3:0] prev_percep_wt_2,
   output logic signed [3:0] prev_percep_bias,
   // Testing outputs
   output logic [3:0] test_percep_present_state,
   output logic signed [3:0] expected_percep_output,
   output logic signed [3:0] test_percep_output,
   output logic signed [3:0] test_percep_result,
   output logic signed [3:0] test_percep_done,
   output logic signed [3:0] test_percep_x1,
   output logic signed [3:0] test_percep_x2,
   output logic [3:0] test_percep_index
);

We must also add internal registers for testing:
logic test_mode; // 0: training, 1: testing
logic [3:0] test_percep_index_reg; // register for test index
logic signed [3:0] test_percep_result_reg;
logic signed [3:0] test_percep_done_reg; // though done is 4-bit signed, but we can use reg logic signed [3:0] test_percep_done_reg.
logic [3:0] test_percep_present_state_reg;

We also need a terminal index register for testing. But we can compute terminal index based on gate_select. We can do a combinational block that sets terminal index:
logic [3:0] test_terminal_index;
assign test_terminal_index = (gate_select == 2'b00) ? 4'd4 : (gate_select == 2'b01) ? 4'd8 : (gate_select == 2'b10) ? 4'd12 : 4'd16;

Now, for the training part, we have existing always_ff blocks. We need to modify them to incorporate testing if stop is asserted. But careful: The training always_ff block is:

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
   end else begin
      present_addr <= next_addr;
      microcode_addr <= present_addr;
   end
end

We need to modify this block to also check if stop is asserted and then set test_mode to 1 and initialize testing registers. But careful: The training always_ff block is synchronous. We can add in else if (stop) then set test_mode = 1 and initialize testing registers. But that might interfere with training. Alternatively, we can have a separate always_ff block for testing. But then how do we switch from training to testing? We can add an if (stop && !test_mode) in the training always_ff block, then set test_mode = 1 and initialize testing registers. But training block is already used for training. But it's acceptable to combine.

I propose: In the always_ff block for training, if (!rst_n) then clear registers. Else, if (stop && !test_mode) then set test_mode = 1 and initialize testing registers. But then what about training registers? They remain as they are. But then training block's functionality: present_addr <= next_addr; microcode_addr <= present_addr; remains for training if not in test mode. But if test_mode becomes 1, then training stops? But the spec says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." That suggests that when training stops, then the module automatically transitions to testing. So we can do that in the same always_ff block: if (stop && !test_mode) begin test_mode <= 1; initialize testing registers (test_percep_index_reg = computed starting index, test_percep_result_reg = 0, test_percep_done_reg = 0, etc.). Else if (test_mode) then do testing sequence. But then the training always_ff block already has an else branch that does present_addr <= next_addr, etc. So we need to branch: if (test_mode) then skip updating training registers, else update training registers.

We can do something like:
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      // reset training registers
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
      test_mode <= 1'b0;
      test_percep_index_reg <= 4'd0;
      test_percep_result_reg <= 4'd0;
      test_percep_done_reg <= 4'd0;
      test_percep_present_state_reg <= 4'd0;
   end else begin
      if (stop && !test_mode) begin
         test_mode <= 1'b1;
         // initialize testing registers
         test_percep_index_reg <= (gate_select == 2'b00) ? 4'd0 : (gate_select == 2'b01) ? 4'd4 : (gate_select == 2'b10) ? 4'd8 : 4'd12;
         test_percep_result_reg <= 4'd0;
         test_percep_done_reg <= 4'd0;
         test_percep_present_state_reg <= 4'd0;
      end else if (test_mode) begin
         // perform testing sequence
         // Compute test_calc = percep_w1 * test_inputs_x1[test_percep_index_reg] + percep_w2 * test_inputs_x2[test_percep_index_reg] + percep_bias
         // We'll need a temporary variable, but we can compute it in combinational always block maybe.
         // But since it's sequential, we can compute it and update test_percep_output.
         // Let's declare a local variable: logic signed [7:0] test_calc;
         // But in always_ff, we can't declare local variables. We can use an intermediate register.
         // Alternatively, we can do the computation in an always_comb block that drives test_percep_output.
         // Let's do that: We'll compute test_calc in an always_comb block and then update test registers in always_ff.
         // But then we need to update test_percep_index_reg in always_ff.
         // For simplicity, I'll do the testing sequence in an always_ff block that is sensitive to clk.
         // We'll compute test_calc in an always_comb block separately.
         // So in always_ff, if (test_mode) then:
         if (test_percep_index_reg < test_terminal_index) begin
            // update test registers with current test vector
            test_percep_x1_reg <= test_inputs_x1[test_percep_index_reg];
            test_percep_x2_reg <= test_inputs_x2[test_percep_index_reg];
            expected_percep_output_reg <= test_expected_outputs[test_percep_index_reg];
            // test_calc is computed in combinational block, so test_percep_output will be driven by that block.
            test_percep_index_reg <= test_percep_index_reg + 4'd1;
            if (test_percep_output == expected_percep_output_reg)
               test_percep_result_reg <= test_percep_result_reg + 4'd1;
         end else begin
            test_percep_done_reg <= 4'd1; // mark done
         end
      end else begin
         // Normal training mode
         present_addr <= next_addr;
         microcode_addr <= present_addr;
      end
   end
end

But careful: We already have an always_ff block for training in the original code. We need to merge testing functionality into that block. But then the training always_ff block already exists. We need to modify it. We can combine the training always_ff block with testing always_ff block into one always_ff block that checks if test_mode is asserted. But then the training always_ff block is sequential. But then the testing always_ff block is also sequential. We can combine them if we use if-else if structure.

But note: The original always_ff block for training uses "always_ff @(posedge clk or negedge rst_n) begin ... end" and then inside it, there is an if (!rst_n) else begin present_addr <= next_addr; microcode_addr <= present_addr; end. We want to add test_mode handling.

We can do something like:

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
      test_mode <= 1'b0;
      test_percep_index_reg <= 4'd0;
      test_percep_result_reg <= 4'd0;
      test_percep_done_reg <= 4'd0;
      test_percep_present_state_reg <= 4'd0;
   end else begin
      if (stop && !test_mode) begin
         // Transition to testing mode
         test_mode <= 1'b1;
         // Initialize testing registers based on gate_select
         test_percep_index_reg <= (gate_select == 2'b00) ? 4'd0 : (gate_select == 2'b01) ? 4'd4 : (gate_select == 2'b10) ? 4'd8 : 4'd12;
         test_percep_result_reg <= 4'd0;
         test_percep_done_reg <= 4'd0;
         test_percep_present_state_reg <= 4'd0;
      end else if (test_mode) begin
         // Testing phase: use test microcode algorithm
         if (test_percep_index_reg < test_terminal_index) begin
            test_percep_x1_reg <= test_inputs_x1[test_percep_index_reg];
            test_percep_x2_reg <= test_inputs_x2[test_percep_index_reg];
            expected_percep_output_reg <= test_expected_outputs[test_percep_index_reg];
            test_percep_index_reg <= test_percep_index_reg + 4'd1;
            if (test_percep_output == expected_percep_output_reg)
               test_percep_result_reg <= test_percep_result_reg + 4'd1;
         end else begin
            test_percep_done_reg <= 4'd1;
         end
      end else begin
         // Normal training operation
         present_addr <= next_addr;
         microcode_addr <= present_addr;
      end
   end
end

But then we need to declare registers for testing that are updated in always_ff. So add:
logic [3:0] test_percep_index_reg;
logic signed [3:0] test_percep_result_reg;
logic signed [3:0] test_percep_done_reg;
logic [3:0] test_percep_present_state_reg;
logic signed [3:0] test_percep_x1_reg;
logic signed [3:0] test_percep_x2_reg;
logic signed [3:0] expected_percep_output_reg;

We already have test_inputs_x1, test_inputs_x2, test_expected_outputs arrays defined as initial values.

Now, the combinational block for testing output calculation:
We need to compute test_calc = percep_w1 * test_inputs_x1[test_percep_index_reg] + percep_w2 * test_inputs_x2[test_percep_index_reg] + percep_bias.
But note that in the training always_ff block, test_percep_index_reg is updated, but then combinational block uses the old value? We want to compute test_calc using the current test vector that has just been loaded into registers? But in the always_ff block above, we load test_percep_x1_reg and test_percep_x2_reg from arrays using test_percep_index_reg, then we update test_percep_index_reg. So the test vector for the current iteration is in registers test_percep_x1_reg and test_percep_x2_reg, but the combinational block should use those registers. So we can do:
always_comb begin
   // Compute test_calc using current test vector registers
   // We'll declare a local variable logic signed [7:0] test_calc;
   // test_calc = percep_w1 * test_percep_x1_reg + percep_w2 * test_percep_x2_reg + percep_bias;
   // Then compare test_calc with threshold.
   // But threshold is 4-bit signed, need to extend it to 8 bits.
   // We'll do: if (test_calc > {4'd0, threshold}) then test_percep_output = 1, else if (test_calc >= {4'd0, -threshold} && test_calc <= {4'd0, threshold}) then test_percep_output = 0, else test_percep_output = -1.
   // But note: threshold is signed [3:0]. We can do: if (test_calc > {4'd0, threshold}) ...
   // But I'm not 100% on syntax, but I'll assume it's correct.
   // We'll also drive expected_percep_output, but that is coming from register expected_percep_output_reg.
   // Also drive test_percep_present_state as test_percep_index_reg.
   test_percep_present_state = test_percep_index_reg;
   // Compute test_calc
   logic signed [7:0] test_calc;
   test_calc = percep_w1 * test_percep_x1_reg + percep_w2 * test_percep_x2_reg + percep_bias;
   if (test_calc > {4'd0, threshold})
      test_percep_output = 4'd1;
   else if (test_calc >= {4'd0, -threshold} && test_calc <= {4'd0, threshold})
      test_percep_output = 4'd0;
   else
      test_percep_output = -4'd1;
   expected_percep_output = expected_percep_output_reg; // drive expected output from register
end

But careful: In SystemVerilog, we cannot declare a local variable inside an always_comb block if it's not declared outside. But we can declare it inside the block. But we need to declare it as "logic signed [7:0] test_calc;" inside always_comb block. That's allowed in SystemVerilog.

We then need to connect the outputs of testing always_comb block to the output ports: test_percep_present_state, expected_percep_output, test_percep_output. And also drive test_percep_result, test_percep_done, test_percep_x1, test_percep_x2, and test_percep_index.

We already have registers for these, so we can assign them to outputs:
assign test_percep_present_state = test_percep_present_state_reg;
assign expected_percep_output = expected_percep_output_reg;
assign test_percep_x1 = test_percep_x1_reg;
assign test_percep_x2 = test_percep_x2_reg;
assign test_percep_index = test_percep_index_reg;
assign test_percep_result = test_percep_result_reg;
assign test_percep_done = test_percep_done_reg;

Now, what about the training microcode ROM and its always_comb block? The training always_comb block is as given. We need to integrate it with testing. But the training always_comb block is already present. It uses "case (train_action)" with cases 0,1,2,3,4,5, default. We may need to modify the default case to include testing? But specification says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." That suggests that when stop is asserted, the microcode ROM should perform testing instructions. But our design now transitions to testing mode using the always_ff block. So we don't need to modify the training always_comb block. We can leave it as is.

But wait, the training always_comb block uses "case (train_action)" and then "assign percep_w1 = percep_wt_1_reg; assign percep_w2 = percep_wt_2_reg; assign percep_bias = percep_bias_reg;". That remains the same.

We also have a gate_target submodule that remains unchanged.

We need to integrate the testing microcode control unit. But our design now uses a separate always_ff block for testing. We already integrated it in the always_ff block that handles both training and testing. But then the training always_ff block is replaced by a unified always_ff block that handles training and testing. But originally, there was an always_ff block for training. We can combine them. But careful: the original training always_ff block does:
always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
   end else begin
      present_addr <= next_addr;
      microcode_addr <= present_addr;
   end
end

We want to add test_mode handling in this block. So we can modify it to:

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
      test_mode <= 1'b0;
      test_percep_index_reg <= 4'd0;
      test_percep_result_reg <= 4'd0;
      test_percep_done_reg <= 4'd0;
      test_percep_present_state_reg <= 4'd0;
      test_percep_x1_reg <= 4'd0;
      test_percep_x2_reg <= 4'd0;
      expected_percep_output_reg <= 4'd0;
   end else begin
      if (stop && !test_mode) begin
         // Transition to testing mode
         test_mode <= 1'b1;
         test_percep_index_reg <= (gate_select == 2'b00) ? 4'd0 : (gate_select == 2'b01) ? 4'd4 : (gate_select == 2'b10) ? 4'd8 : 4'd12;
         test_percep_result_reg <= 4'd0;
         test_percep_done_reg <= 4'd0;
         test_percep_present_state_reg <= 4'd0;
         test_percep_x1_reg <= 4'd0;
         test_percep_x2_reg <= 4'd0;
         expected_percep_output_reg <= 4'd0;
      end else if (test_mode) begin
         if (test_percep_index_reg < test_terminal_index) begin
            test_percep_x1_reg <= test_inputs_x1[test_percep_index_reg];
            test_percep_x2_reg <= test_inputs_x2[test_percep_index_reg];
            expected_percep_output_reg <= test_expected_outputs[test_percep_index_reg];
            test_percep_index_reg <= test_percep_index_reg + 4'd1;
            if (test_percep_output == expected_percep_output_reg)
               test_percep_result_reg <= test_percep_result_reg + 4'd1;
         end else begin
            test_percep_done_reg <= 4'd1;
         end
      end else begin
         // Normal training operation
         present_addr <= next_addr;
         microcode_addr <= present_addr;
      end
   end
end

But wait, there's an issue: The training always_comb block uses "next_addr" which is derived from microinstruction. And that always_comb block is separate. So our unified always_ff block now covers both training and testing. But then what about the training always_comb block? It remains unchanged, but now it might be executed concurrently with testing always_ff block? But our design now has two always_ff blocks: one for training control (the unified one) and one for testing always_comb block. But the unified always_ff block we wrote is supposed to handle both training and testing. But then the training always_comb block is still there, but it doesn't interact with test_mode. But that's fine because training always_comb block is combinational and always_ff block is sequential. They don't conflict.

However, we need to be careful: The unified always_ff block now is replacing the original training always_ff block. But the original training always_ff block is in the original code:

always_ff @(posedge clk or negedge rst_n) begin
   if (!rst_n) begin
      present_addr <= 4'd0;
      microcode_addr <= 4'd0;
      percep_wt_1_reg <= 4'd0;
      percep_wt_2_reg <= 4'd0;
      percep_bias_reg <= 4'd0;
      input_index <= 2'd0;
      stop <= 1'b0;
   end else begin
      present_addr <= next_addr;
      microcode_addr <= present_addr;
   end
end

We want to extend it to include testing. So we modify it as above.

Also, the unified always_ff block now uses test_terminal_index. We haven't defined test_terminal_index. We can define it as a combinational assignment:
assign test_terminal_index = (gate_select == 2'b00) ? 4'd4 : (gate_select == 2'b01) ? 4'd8 : (gate_select == 2'b10) ? 4'd12 : 4'd16;

Now, one more thing: The combinational always_comb block for testing output calculation. It should use registers test_percep_x1_reg and test_percep_x2_reg to compute test_calc and then set test_percep_output. But note: The always_ff block for testing updates test_percep_x1_reg and test_percep_x2_reg from arrays. But then the always_comb block should use those registers. But careful: The always_comb block will be evaluated every time, and its outputs are driven to the ports. That is fine.

We need to declare the registers for testing: test_percep_index_reg, test_percep_result_reg, test_percep_done_reg, test_percep_present_state_reg, test_percep_x1_reg, test_percep_x2_reg, expected_percep_output_reg. We already declared them in our unified always_ff block.

Now, what about the existing training always_comb block? It is as given. It uses case (train_action) with cases 0,1,2,3,4,5, default. We don't need to modify that because training functionality remains the same. But maybe we want to add a case for testing? But the spec says "Extended the Training microcode ROM to perform testing when a stop condition is achieved." That is handled by our unified always_ff block.

We also need to update the output assignments for testing:
assign test_percep_present_state = test_percep_present_state_reg;
assign expected_percep_output = expected_percep_output_reg;
assign test_percep_x1 = test_percep_x1_reg;
assign test_percep_x2 = test_percep_x2_reg;
assign test_percep_index = test_percep_index_reg;
assign test_percep_result = test_percep_result_reg;
assign test_percep_done = test_percep_done_reg;

And the combinational block for test_percep_output is as described.

I must also update the module header to include the new ports.

I must ensure that the new code is plain text with no JSON formatting.

I must output the entire modified code as a plain text file, and the file name will be rtl/perceptron_gates.sv.

I'll produce the modified code.

I'll produce the code with modifications. I'll try to preserve the original structure as much as possible, but add the new functionality.

I'll produce the code in plain text.

I'll produce the code with modifications. I'll try to maintain the same indentation style.

I'll produce the code as follows:

```
module perceptron_gates (
   input  logic clk,
   input  logic rst_n,
   input  logic signed [3:0] x1,
   input  logic signed [3:0] x2,
   input  logic learning_rate,
   input  logic signed [3:0] threshold,
   input  logic [1:0] gate_select,
   output logic signed [3:0] percep_w1,
   output logic signed [3:0] percep_w2,
   output logic signed [3:0] percep_bias,
   output logic [3:0] present_addr,
   output logic stop,
   output logic [2:0] input_index,
   output logic signed [3:0] y_in,
   output logic signed [3:0] y,
   output logic signed [3:0] prev_percep_wt_1,
   output logic signed [3:0] prev_percep_wt_2,
   output logic signed [3:0] prev_percep_bias,
   // Testing outputs
   output logic [3:0] test_percep_present_state,
   output logic signed [3:0] expected_percep_output,
   output logic signed [3:0] test_percep_output,
   output logic signed [3:0] test_percep_result,
   output logic signed [3:0] test_percep_done,
   output logic signed [3:0] test_percep_x1,
   output logic signed [3:0] test_percep_x2,
   output logic [3:0] test_percep_index
);

   // Original registers and wires
   logic [15:0] microcode_rom [0:5];
   logic [3:0]  next_addr;
   logic [3:0]  train_action;
   logic [3:0]  microcode_addr;
   logic [15:0] microinstruction;
   logic signed [3:0] t1, t2, t3, t4;
   
   gate_target dut (
       .gate_select(gate_select),
       .o_1(t1),
       .o_2(t2),
       .o_3(t3),
       .o_4(t4)
   );

   logic signed [3:0] percep_wt_1_reg;
   logic signed [3:0] percep_wt_2_reg;
   logic signed [3:0] percep_bias_reg;

   logic signed [3:0] target;
   logic signed [3:0] prev_wt1_update;
   logic signed [3:0] prev_wt2_update;
   logic signed [3:0] prev_bias_update;
   
   logic signed [3:0] wt1_update;
   logic signed [3:0] wt2_update;
   logic signed [3:0] bias_update;
   logic [7:0] epoch_counter;
   
   assign  prev_percep_wt_1 = prev_wt1_update;
   assign  prev_percep_wt_2 = prev_wt2_update;
   assign  prev_percep_bias = prev_bias_update;

   initial begin 
      microcode_rom[0] = 16'b0001_0000_0000_0000; 
      microcode_rom[1] = 16'b0010_0001_0000_0000; 
      microcode_rom[2] = 16'b0011_0010_0000_0000; 
      microcode_rom[3] = 16'b0100_0011_0000_0000; 
      microcode_rom[4] = 16'b0101_0100_0000_0000; 
      microcode_rom[5] = 16'b0000_0101_0000_0000; 
   end  
   
   always_comb begin
      microinstruction = microcode_rom[microcode_addr];
      next_addr        = microinstruction[15:12];
      train_action     = microinstruction[11:8];
   end

   // Combined always_ff block for training and testing
   // Declare testing registers
   logic test_mode; // 0: training, 1: testing
   logic [3:0] test_percep_index_reg;
   logic signed [3:0] test_percep_result_reg;
   logic signed [3:0] test_percep_done_reg;
   logic [3:0] test_percep_present_state_reg;
   logic signed [3:0] test_percep_x1_reg;
   logic signed [3:0] test_percep_x2_reg;
   logic signed [3:0] expected_percep_output_reg;
   
   // Terminal index for testing based on gate_select
   logic [3:0] test_terminal_index;
   assign test_terminal_index = (gate_select == 2'b00) ? 4'd4 :
                                (gate_select == 2'b01) ? 4'd8 :
                                (gate_select == 2'b10) ? 4'd12 : 4'd16;
   
   always_ff @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
         present_addr <= 4'd0;
         microcode_addr <= 4'd0;
         percep_wt_1_reg <= 4'd0;
         percep_wt_2_reg <= 4'd0;
         percep_bias_reg <= 4'd0;
         input_index <= 2'd0;
         stop <= 1'b0;
         test_mode <= 1'b0;
         test_percep_index_reg <= 4'd0;
         test_percep_result_reg <= 4'd0;
         test_percep_done_reg <= 4'd0;
         test_percep_present_state_reg <= 4'd0;
         test_percep_x1_reg <= 4'd0;
         test_percep_x2_reg <= 4'd0;
         expected_percep_output_reg <= 4'd0;
      end else begin
         if (stop && !test_mode) begin
            // Transition to testing mode
            test_mode <= 1'b1;
            test_percep_index_reg <= (gate_select == 2'b00) ? 4'd0 :
                                     (gate_select == 2'b01) ? 4'd4 :
                                     (gate_select == 2'b10) ? 4'd8 : 4'd12;
            test_percep_result_reg <= 4'd0;
            test_percep_done_reg <= 4'd0;
            test_percep_present_state_reg <= 4'd0;
            test_percep_x1_reg <= 4'd0;
            test_percep_x2_reg <= 4'd0;
            expected_percep_output_reg <= 4'd0;
         end else if (test_mode) begin
            // Testing phase: process test vectors
            if (test_percep_index_reg < test_terminal_index) begin
               test_percep_x1_reg <= test_inputs_x1[test_percep_index_reg];
               test_percep_x2_reg <= test_inputs_x2[test_percep_index_reg];
               expected_percep_output_reg <= test_expected_outputs[test_percep_index_reg];
               test_percep_index_reg <= test_percep_index_reg + 4'd1;
               if (test_percep_output == expected_percep_output_reg)
                  test_percep_result_reg <= test_percep_result_reg + 4'd1;
            end else begin
               test_percep_done_reg <= 4'd1;
            end
         end else begin
            // Normal