module. We are asked to modify the design to handle multiple streams. We must produce the modified code in "rtl/run_length.sv" file. Our answer should be plain text code with no markdown formatting. The file must be named parallel_run_length.sv? Wait, requirement: "The module must be named parallel_run_length." but then it says "Your response will be saved directly to: rtl/run_length.sv." This is contradictory: The instructions say "Your response will be saved directly to: rtl/run_length.sv", but then the module name is "parallel_run_length". But we follow the instruction "Your response will be saved directly to: rtl/run_length.sv", so we output file name as "rtl/run_length.sv"? But the instructions require module name "parallel_run_length". So maybe we will generate file "rtl/run_length.sv" but inside that file, we create module "parallel_run_length", as described.

Let's check instructions: "You are solving an 'RTL Code Modification' problem. To solve this problem correctly, you should only respond with the modified RTL code according to the requirements." And then "Provide me one answer for this request: The current run_length module serves as the foundation for single-stream run-length encoding. It encapsulates the logic for tracking the length of consecutive identical values in a single binary data stream. This module is parametrized to allow flexibility in defining the maximum run length (DATA_WIDTH)."

Then modification requirements: We need to modify RTL design to handle multiple streams. Each stream has separate run-length tracking. Requirements:

- Module name: parallel_run_length.
- Parameters: DATA_WIDTH (default = 8, >=1), NUM_STREAMS (default = 4).
- Inputs:
  - clk, reset_n,
  - data_in [NUM_STREAMS-1:0],
  - stream_enable [NUM_STREAMS-1:0].
- Outputs:
  - data_out [NUM_STREAMS-1:0]
  - run_value: bit width = (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0. But careful: each stream's run_value is a number that goes from 0 to DATA_WIDTH, so it needs to be $clog2(DATA_WIDTH) bits plus 1 bit for representation. But the output run_value is a bus with NUM_STREAMS concatenated bits? Actually requirement says "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]". But then "Outputs the run length for each stream." Possibly it means each stream's run_value is stored in one set of bits. But then the output is a vector with each stream's run_value. But the width is ambiguous. Let's check: "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]". But if we think each stream's run value is a value from 0 to DATA_WIDTH, then it requires ($clog2(DATA_WIDTH)+1) bits. So each stream's run_value is represented by that many bits. And then they are concatenated together in order. But then the code is not typical to have a vector of streams output, but rather a vector of run_value for each stream. But then we have to be careful with the indexing.

Wait, the instructions: "Outputs: run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]". That means the output is a wide vector containing run_value for each stream, concatenated. But then "data_out [NUM_STREAMS-1:0]" and "valid [NUM_STREAMS-1:0]". So we have three outputs: data_out, run_value, valid. But run_value is a wide bus with each stream's run_value. But then the code might be easier if we define internal arrays for each stream. But since SystemVerilog supports arrays, we can use generate loops. But the problem statement says "Your response will be saved directly to: rtl/run_length.sv". So we want to generate the module file as "rtl/run_length.sv" with the new code.

We need to implement multi-stream logic. Requirements:

For each stream i in [0:NUM_STREAMS-1]:
- There's an internal register for run_length, previous data value, and run_value, valid, etc.
- When reset, initialize run_length = 0, run_value = 0, valid = 0, and maybe previous data = 0.
- On each clock cycle:
  - If stream_enable[i] is high:
    - Compare data_in[i] with prev_data[i]. If equal, then:
       - if run_length == DATA_WIDTH then output run_length and then if same data, reset run_length to 1.
       - else increment run_length if less than DATA_WIDTH.
    - Else if data_in[i] != prev_data[i]:
       - then output run_length, and reset run_length to 1.
    - Then update prev_data[i] = data_in[i].
  - If stream_enable[i] is low:
    - then reset run_length = 0, run_value = 0, valid = 0, and prev_data = 0.
    - But if re-enabled, then resume as if starting fresh.

Wait, but careful: "When stream_enable[i] is deasserted, the run-length logic and outputs for that stream must reset or remain at default values. No valid run lengths should be reported for a disabled stream." So if stream_enable[i] is low, we can simply reset the registers for that stream. But if it's re-enabled, then we treat it as fresh.

Wait, "stream_enable" is an input signal. So on every cycle, if stream_enable[i] is low, we want to clear registers? But what if stream_enable toggles? The requirement "when stream_enable[i] is reasserted, that stream’s run-length logic should resume as if starting fresh" means that if previously it was disabled, then when it becomes enabled, it should start with run_length = 1 if data_in is valid? But then maybe we need to check if data_in is stable? Actually, the requirement: "When stream_enable[i] is deasserted, the run-length logic and outputs for that stream must reset or remain at default values." So maybe we want to continuously reset the registers for that stream if stream_enable[i] is not high.

But careful: if stream_enable[i] is low, then we don't track run-length, so we can simply set run_length = 0, run_value = 0, valid = 0, and prev_data = 0. But then if stream_enable[i] is reasserted, it should start as if starting fresh, i.e., run_length = 1, prev_data = data_in[i]. But then how to determine that? Because if stream_enable was low, then we want to ignore the previous value, so on the cycle where stream_enable becomes high, we want to initialize the registers with the new input value as the starting value. But if we simply reset registers on disable, then when re-enabled, the registers remain 0. So we need to handle transition from disabled to enabled. But requirement "When stream_enable[i] is reasserted, that stream’s run-length logic should resume as if starting fresh." So that means that when stream_enable[i] becomes high, we should set run_length = 1, prev_data = data_in[i], and output? But then what about output? The requirement "When valid[i] is asserted, data_out[i] must hold the corresponding data value for the run that just ended, and run_value must reflect the length of that run." So maybe when stream_enable is reasserted, we want to consider that as a new run starting. But we only output a run when the run terminates. So maybe we want to check: if stream_enable[i] was low, then in the cycle where it becomes high, we want to initialize run_length to 1 and set prev_data = data_in[i]. But then we should not output valid immediately because the run hasn't ended. But maybe we want to update run_value to 1? But the requirement "On cycles where no run terminates, valid[i] remains low for that stream." So when stream_enable is reasserted, the run hasn't terminated yet. But then what if the input changes immediately? That is a run termination, then we output valid.

Thus, for each stream, we need two always blocks: one to update run_length and run_value, and one to update valid and data_out. But we can combine them if needed.

We can use generate for loops over streams. I propose using SystemVerilog generate loop with for(i = 0; i < NUM_STREAMS; i++) begin: gen_stream, then instantiate a block of code for each stream.

We have two always blocks per stream originally in the original module. But we can combine them into one always block that handles both, or use two always blocks. But careful: The original code had two always blocks with the same sensitivity list. But now we need to generate similar structure for each stream. We want to update registers: run_length[i], prev_data[i], and then update output signals valid[i], data_out[i], and run_value bits. But run_value is a wide bus. But we can store each stream's run_value in a separate register and then assign it to a slice of run_value output vector. But the requirement says: "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" which is a concatenated bus. But we can also do generate: declare an array of registers for run_value for each stream. But then we need to assign them to the output vector. Alternatively, we can declare an output array of type logic [NUM_STREAMS-1:0] for run_value, but the width is not uniform? The requirement says "run_value" is a bus of width NUM_STREAMS * ($clog2(DATA_WIDTH)+1). But that suggests that each stream's run_value is a vector of ($clog2(DATA_WIDTH)+1) bits. But then it is not a bit vector of streams but a concatenation of these values. I can declare an internal array of registers of type logic [$clog2(DATA_WIDTH):0] for each stream's run_value. But then assign them to the output bus. But careful: The requirement says "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" meaning that the least significant bits are for stream 0, then stream 1, etc. But the order is not specified. We can assume that run_value[($clog2(DATA_WIDTH)+1)-1:0] is for stream 0, then next bits for stream 1, etc. But then we need to assign each stream's run_value to the correct slice of the run_value output bus. But that might be complicated. Alternatively, we can declare run_value as an array of registers. But the requirement explicitly says it is one wide bus. But we can do something like: output logic [NUM_STREAMS*(($clog2(DATA_WIDTH)+1))-1:0] run_value; and then inside the generate, assign run_value[(i+1)*($clog2(DATA_WIDTH)+1)-1 -: ($clog2(DATA_WIDTH)+1)] = run_value_reg[i]. But need to be careful with indexing.

I can compute "run_val_width = $clog2(DATA_WIDTH)+1". Let me denote it as parameter RUN_WIDTH = $clog2(DATA_WIDTH) + 1. But note that $clog2 is a function that returns the number of bits needed to represent DATA_WIDTH. But careful: DATA_WIDTH is the maximum run length, so if DATA_WIDTH = 8, then $clog2(8) = 3, so RUN_WIDTH = 4. But the original code used "output reg [$clog2(DATA_WIDTH):0] run_value" which is 3+1 = 4 bits. So that's consistent.

So I'll define: parameter RUN_WIDTH = $clog2(DATA_WIDTH) + 1. But careful: $clog2 is a SystemVerilog function that is available in SystemVerilog. But I'll assume it's available.

Then for each stream, we need registers: run_length[i] of type logic [DATA_WIDTH-1:0]? But in original code, run_length is [$clog2(DATA_WIDTH):0]. But wait, the original code: "reg [$clog2(DATA_WIDTH):0] run_length;" That means run_length is a value that can represent numbers from 0 to DATA_WIDTH. But DATA_WIDTH is 8, so $clog2(8) = 3 bits plus one bit, so 4 bits total. But it's actually used as a counter that increments until it equals DATA_WIDTH. But if DATA_WIDTH is 8, then run_length can go from 0 to 8, which requires 4 bits. But it is declared as "reg [$clog2(DATA_WIDTH):0] run_length;". But that's a bit ambiguous because $clog2(DATA_WIDTH) returns the number of bits needed to represent DATA_WIDTH, but then adding one bit gives the correct width for run_length. So I'll do the same: run_length[i] will be declared as logic [$clog2(DATA_WIDTH):0] for each stream. And prev_data[i] is logic (1 bit). And then run_value[i] is logic [$clog2(DATA_WIDTH):0] as well. But note that in the original code, run_value is also declared as reg [$clog2(DATA_WIDTH):0]. So I'll do that.

But the output run_value is a wide bus, but we can internally store it in an array. I can create an array: logic [NUM_STREAMS-1:0][RUN_WIDTH-1:0] run_value_array; But then assign output run_value as concatenation of run_value_array for each stream. But the requirement explicitly states run_value is a single bus of width (NUM_STREAMS * RUN_WIDTH) bits. I can generate that by concatenating the array. But I'll do: assign run_value = {run_value_array[NUM_STREAMS-1], run_value_array[NUM_STREAMS-2], ... run_value_array[0]}; But careful with concatenation order. It's easier to generate a for loop in a generate block that assigns slices of run_value output.

I propose to declare internal arrays: logic [$clog2(DATA_WIDTH):0] run_length [NUM_STREAMS-1:0]; logic prev_data [NUM_STREAMS-1:0]; logic [$clog2(DATA_WIDTH):0] run_value_reg [NUM_STREAMS-1:0]; logic valid_reg [NUM_STREAMS-1:0]; But then outputs: data_out, valid, and run_value bus. But then I'll create a generate loop over streams. But then I need to update these registers in a clocked always block. But since we have multiple streams, we can use a for loop in an always block that iterates over all streams, but then we need separate sensitivity list for each stream? But they share the same clock and reset. But then the code becomes a for loop over streams. But then the code can be vectorized if the signals are arrays. But SystemVerilog supports for loops in always blocks. But careful: The original code had two always blocks. But we can combine them into one always block if we want.

I propose to have one always block with sensitivity @(posedge clk or negedge reset_n) begin if (!reset_n) then for each stream, reset registers. Else for each stream i: if (stream_enable[i]) then do run-length logic else reset registers to default. But then update valid and data_out accordingly. But note: "valid" is asserted when a run terminates, i.e., when input changes or run_length equals DATA_WIDTH. But then in the original code, valid is asserted in the second always block. But we can combine them.

I need to consider each stream independently:
For each stream i:
- On reset: run_length[i] = 0, run_value[i] = 0, prev_data[i] = 0, valid[i] = 0, data_out[i] = 0.
- On clock edge:
   if (!reset_n) then reset.
   Else:
      if (stream_enable[i]) then:
         if (data_in[i] == prev_data[i]) then:
            if (run_length[i] == DATA_WIDTH) then:
                run_value[i] = run_length[i] (which equals DATA_WIDTH) and then if (data_in[i] == prev_data[i]) then run_length[i] becomes 1? But the original code: 
                "if(run_length == (DATA_WIDTH)) begin
                    run_value  <= run_length;
                end
                if (run_length < (DATA_WIDTH)) begin
                    run_length <= run_length + 1'b1;
                end
                else begin
                    run_length <= 1'b1;"
                But note: The code is a bit weird because the "if" and "else" structure is not mutually exclusive because they are separate if statements. Let's re-read the original code:

                always @(posedge clk or negedge reset_n) begin
                    if (!reset_n) begin
                        run_length <= 0;
                        run_value <= 0;
                        prev_data_in <= 0;
                    end else begin
                        if (data_in == prev_data_in) begin
                            if(run_length == (DATA_WIDTH)) begin
                                run_value <= run_length;
                            end
                            if (run_length < (DATA_WIDTH)) begin
                                run_length <= run_length + 1;
                            end
                            else begin
                                run_length <= 1;
                            end
                        end else begin
                            run_value <= run_length;
                            run_length <= 1;
                        end
                        prev_data_in <= data_in;
                    end
                end

                And then in the second always block, valid and data_out are updated:
                if (run_length == (DATA_WIDTH) || data_in != prev_data_in) begin
                    valid <= 1;
                    data_out <= prev_data_in;
                end else begin
                    valid <= 0;
                    data_out <= 0;
                end

                But note: The original code uses two always blocks. But I can combine them. But careful: The original code logic: if the run_length equals DATA_WIDTH, then run_value is updated to run_length (which is DATA_WIDTH) and then run_length is reset to 1 if the same data continues. But then valid is asserted if run_length equals DATA_WIDTH OR data_in != prev_data. But then in that case, data_out is set to prev_data_in.

                But wait: There's a subtle bug: In the original code, the run_value is updated in one always block and then used in the second always block. But the second always block uses "if (run_length == (DATA_WIDTH) || data_in != prev_data_in)" then valid and data_out are updated. But then the run_length is not used in the second always block? It is used in the condition. But then if run_length equals DATA_WIDTH, then valid is asserted. But then if data_in != prev_data_in, then valid is asserted.

                I want to mimic that behavior for each stream. But I'm thinking: It might be simpler to do two always blocks, one for updating run_length and run_value, and one for valid and data_out. But then I can use generate loops for each stream.

                Alternatively, I can combine them into one always block per stream, but then I'd need to use a for loop over streams. But careful: The logic is sequential. But I can use a for loop over i in an always block if the registers are declared as arrays. But then I need to be careful with non-blocking assignments. But I think it's fine if I do "for (int i = 0; i < NUM_STREAMS; i++) begin" inside an always block. But then I'd be writing to each stream's registers. But then I have to handle the condition "if (stream_enable[i])" for each i. But then also if (!stream_enable[i]) then reset registers for that stream.

                But then the outputs data_out[i] and valid[i] should be assigned accordingly. But then run_value for each stream, I want to update run_value[i] only when a run terminates. But the requirement says: "When a run terminates, output run_value = run_length." So I want to assign run_value[i] = run_length[i] when run terminates.

                But then the logic: For each stream i:
                  if (stream_enable[i] is false) then:
                      run_length[i] <= 0; run_value[i] <= 0; prev_data[i] <= 0; valid[i] <= 0; data_out[i] <= 0.
                  else:
                      if (data_in[i] == prev_data[i]) then:
                          if (run_length[i] == DATA_WIDTH) then:
                              run_value[i] <= run_length[i]; // which equals DATA_WIDTH
                              run_length[i] <= 1; // reset counter to 1
                          else:
                              run_length[i] <= run_length[i] + 1;
                      else:
                          run_value[i] <= run_length[i];
                          run_length[i] <= 1;
                      end if
                      prev_data[i] <= data_in[i];

                      // Then valid and data_out: valid[i] <= 1 if (run_length[i] reached DATA_WIDTH OR data_in[i] != prev_data[i] in previous cycle?) But careful: In the original code, valid is updated based on run_length==DATA_WIDTH or data_in != prev_data_in. But note that in the sequential always block, prev_data is updated at the end. So the condition "data_in != prev_data" is checking the previous cycle's data compared to current cycle's data, but then prev_data is updated after. So in our combined always block, we want to check: if (previous run terminated) then valid[i] <= 1 and data_out[i] <= prev_data (which is the run value). But then what is the condition for run termination? It is: if (run_length[i] was updated to DATA_WIDTH) or if (data_in[i] != prev_data[i]) before updating prev_data[i]. But we can capture the condition in a variable. Alternatively, we can compute a flag "terminated" for each stream:
                           terminated = ( (run_length[i] == DATA_WIDTH) before update ) OR (data_in[i] != prev_data[i] in this cycle)? But careful: In the original code, they check "if (run_length == DATA_WIDTH) OR (data_in != prev_data_in)" in the second always block. But note that in the second always block, they use the old value of run_length and prev_data_in, because they are updated in the first always block. So the condition is based on the state before update.

                      We can do something like:
                          logic run_terminated; 
                          if (stream_enable[i]) begin
                              if (data_in[i] != prev_data[i]) then run terminated = 1; else if (run_length[i] was DATA_WIDTH in previous cycle) then run terminated = 1.
                          But wait, we need to check: In the first always block, we update run_value[i] when termination occurs. But then in the second always block, we check if run_length[i] equals DATA_WIDTH OR data_in[i] != prev_data[i] using the old values. But we already updated prev_data[i] in the first always block. So we need to capture the old value of prev_data[i] and old run_length[i] before updating.

                      I propose to use two always blocks: one always block for the run-length tracking (run_length, run_value, prev_data) and one always block for valid and data_out. But then combine them using generate loops. But then we need to store intermediate signals. But we can use two always blocks per stream.

                      Alternatively, we can use two always blocks at the top level with generate loops that iterate over streams. But then the code might be more complicated because the two always blocks need to be synchronized. But that's fine.

                      I'll do: generate for (i = 0; i < NUM_STREAMS; i++) begin : gen_stream
                          // always block for run-length tracking:
                          always @(posedge clk or negedge reset_n) begin
                              if (!reset_n) begin
                                  run_length[i] <= 0;
                                  run_value[i] <= 0;
                                  prev_data[i] <= 0;
                              end else begin
                                  if (stream_enable[i]) begin
                                      if (data_in[i] == prev_data[i]) begin
                                          if (run_length[i] == DATA_WIDTH) begin
                                              run_value[i] <= run_length[i]; // equals DATA_WIDTH
                                              run_length[i] <= 1;
                                          end else begin
                                              run_length[i] <= run_length[i] + 1;
                                          end
                                      end else begin
                                          run_value[i] <= run_length[i];
                                          run_length[i] <= 1;
                                      end
                                      prev_data[i] <= data_in[i];
                                  end else begin
                                      // stream disabled: reset registers
                                      run_length[i] <= 0;
                                      run_value[i] <= 0;
                                      prev_data[i] <= 0;
                                  end
                              end
                          end

                          // always block for valid and data_out:
                          always @(posedge clk or negedge reset_n) begin
                              if (!reset_n) begin
                                  valid[i] <= 0;
                                  data_out[i] <= 0;
                              end else begin
                                  if (stream_enable[i]) begin
                                      // Check if run terminated. 
                                      // Termination condition: either run_length reached DATA_WIDTH (which we set in the previous block) OR data changed.
                                      // But careful: in the previous always block, we update run_value and run_length, and then update prev_data.
                                      // The condition in the original code was: if (run_length == DATA_WIDTH || data_in != prev_data_in) then valid <= 1 and data_out <= prev_data_in.
                                      // But note that in our always block for valid and data_out, prev_data[i] is the updated value from the previous always block.
                                      // So we need to check the condition based on the previous cycle's values. 
                                      // We can replicate the same logic: if (run_length[i] was DATA_WIDTH in previous cycle) OR (data_in[i] != prev_data[i] in previous cycle) then valid.
                                      // But we don't have the previous cycle's values stored separately.
                                      // Alternatively, we can infer that run terminated if run_value[i] is updated (nonzero) and then we latch valid.
                                      // But that might cause multiple cycles of valid assertion.
                                      // The original design: valid is asserted in the same cycle where the run terminates.
                                      // Let's try to mimic that: In the run-length always block, when termination occurs, we update run_value[i]. Then in the valid always block, if run_value[i] != 0, then valid is asserted and data_out is set to prev_data[i] (which is the run value).
                                      // But what if run_value[i] remains nonzero for multiple cycles? 
                                      // In the original design, valid is deasserted if no termination occurs.
                                      // So I propose: if (run_value[i] != 0) then valid[i] <= 1, data_out[i] <= prev_data[i]; else valid[i] <= 0, data_out[i] <= 0.
                                      // But this might assert valid continuously until run_value is consumed externally.
                                      // The requirement says: "On cycles where no run terminates, valid[i] remains low for that stream."
                                      // So valid should be high only in the cycle when a termination occurs.
                                      // But we don't have a mechanism to clear run_value after one cycle. 
                                      // Perhaps we can use a flag that indicates termination just occurred.
                                      // We can introduce an intermediate signal terminated that is high only in the cycle where termination condition is met.
                                      // In the run-length always block, we can set a flag terminated[i] when termination occurs.
                                      // Then in the valid always block, valid[i] <= terminated[i] and data_out[i] <= prev_data[i] (the value that was run).
                                      // And then clear terminated[i] in the next cycle.
                                      // Let's do that.
                                      // We'll declare a reg terminated[i] inside the generate block.
                                  end else begin
                                      valid[i] <= 0;
                                      data_out[i] <= 0;
                                  end
                              end
                          end
                      end
                      // But we need to declare terminated signal for each stream.
                      // We can declare it as logic terminated [NUM_STREAMS-1:0] inside the module.
                      // And then in the run-length always block, when termination condition is met, set terminated[i] <= 1.
                      // And then in the valid always block, if terminated[i] is high, then valid[i] <= 1 and data_out[i] <= prev_data[i], and then clear terminated[i].
                      // But careful: if the stream is continuously enabled and data never changes, then terminated will never be asserted.
                      // But if data changes, terminated will be asserted.
                      // But what about the case when run_length reaches DATA_WIDTH? Then terminated should be asserted.
                      // So in the run-length always block, add: if (data_in[i] == prev_data[i]) begin ... if(run_length[i] == DATA_WIDTH) then set terminated[i] <= 1; else ... end else begin ... set terminated[i] <= 1; end.
                      // But then in the valid always block, if terminated[i] is high then valid[i] <= 1, data_out[i] <= prev_data[i], and then clear terminated[i].
                      // But careful: if stream_enable[i] is deasserted, we also want to clear terminated.
                      // So in the run-length always block, if stream_enable[i] is false, then also clear terminated[i].
                      // I'll add that.
                          // I need to declare reg terminated[i] for each stream.
                      endgenerate

                      // But then I'll have to declare terminated as an array of regs.
                      // I'll declare: logic terminated [NUM_STREAMS-1:0];
                      // And then inside the generate block for each stream, use terminated[i].

                      // So overall, I'll have two always blocks inside a generate loop, one for run-length and one for valid.
                      // And then I'll declare terminated as an array.
                      // Also, I'll declare arrays for run_length, run_value, prev_data, valid, data_out.
                      // But note: data_out and valid are outputs, so they must be declared as output logic [NUM_STREAMS-1:0].
                      // And run_value output is a wide bus. But I can declare an internal array run_value_reg, and then assign to run_value output using concatenation.
                      // Let's do that.

                      // So final structure:
                      // module parallel_run_length
                      // #(
                      //   parameter DATA_WIDTH = 8,
                      //   parameter NUM_STREAMS = 4
                      // )
                      // (
                      //   input logic clk,
                      //   input logic reset_n,
                      //   input logic [NUM_STREAMS-1:0] data_in,
                      //   input logic [NUM_STREAMS-1:0] stream_enable,
                      //   output logic [NUM_STREAMS-1:0] data_out,
                      //   output logic [NUM_STREAMS*(($clog2(DATA_WIDTH)+1))-1:0] run_value,
                      //   output logic [NUM_STREAMS-1:0] valid
                      // );
                      //
                      //   localparam RUN_WIDTH = $clog2(DATA_WIDTH) + 1;
                      //
                      //   // Internal arrays
                      //   logic [$clog2(DATA_WIDTH):0] run_length [NUM_STREAMS-1:0];
                      //   logic run_value_reg [NUM_STREAMS-1:0][RUN_WIDTH-1:0];
                      //   logic prev_data [NUM_STREAMS-1:0];
                      //   logic terminated [NUM_STREAMS-1:0];
                      //   logic valid_reg [NUM_STREAMS-1:0];
                      //
                      //   // Assign outputs: data_out and valid are directly assigned from valid_reg.
                      //   assign data_out = valid_reg; // but careful: valid_reg is an array of bits, so that's fine.
                      //   // For run_value, we need to concatenate run_value_reg for each stream.
                      //   // We'll do this with a generate loop or a concatenation.
                      //   // I can do: assign run_value = {run_value_reg[NUM_STREAMS-1], run_value_reg[NUM_STREAMS-2], ... run_value_reg[0]};
                      //   // But concatenation order: The LSB of run_value corresponds to run_value_reg[0][0].
                      //   // I'll use a for loop in a continuous assignment block? SystemVerilog doesn't allow for loop in continuous assignment.
                      //   // Alternatively, I can use a generate block to assign slices.
                      //   // I can declare an intermediate wire array.
                      //   // I'll do: genvar i; then for (i = 0; i < NUM_STREAMS; i++) assign run_value[i*RUN_WIDTH +: RUN_WIDTH] = run_value_reg[i];
                      //   // But continuous assignment with generate is possible.
                      //
                      //   genvar i;
                      //   generate
                      //   for (i = 0; i < NUM_STREAMS; i++) begin : gen_run_value_assign
                      //       assign run_value[i*RUN_WIDTH +: RUN_WIDTH] = run_value_reg[i];
                      //   end
                      //   endgenerate
                      //
                      //   // Now generate blocks for each stream's logic.
                      //   generate
                      //   for (i = 0; i < NUM_STREAMS; i++) begin : gen_stream
                      //       always @(posedge clk or negedge reset_n) begin
                      //           if (!reset_n) begin
                      //               run_length[i] <= 0;
                      //               run_value_reg[i] <= '0; // RUN_WIDTH bits zero
                      //               prev_data[i] <= 0;
                      //               terminated[i] <= 0;
                      //           end else begin
                      //               if (stream_enable[i]) begin
                      //                   if (data_in[i] == prev_data[i]) begin
                      //                       if (run_length[i] == DATA_WIDTH) begin
                      //                           run_value_reg[i] <= run_length[i]; // equals DATA_WIDTH
                      //                           run_length[i] <= 1;
                      //                           terminated[i] <= 1;
                      //                       end else begin
                      //                           run_length[i] <= run_length[i] + 1;
                      //                           terminated[i] <= 0;
                      //                       end
                      //                   end else begin
                      //                       run_value_reg[i] <= run_length[i];
                      //                       run_length[i] <= 1;
                      //                       terminated[i] <= 1;
                      //                   end
                      //                   prev_data[i] <= data_in[i];
                      //               end else begin
                      //                   // stream disabled, reset registers
                      //                   run_length[i] <= 0;
                      //                   run_value_reg[i] <= '0;
                      //                   prev_data[i] <= 0;
                      //                   terminated[i] <= 0;
                      //               end
                      //           end
                      //       end
                      //
                      //       always @(posedge clk or negedge reset_n) begin
                      //           if (!reset_n) begin
                      //               valid_reg[i] <= 0;
                      //           end else begin
                      //               if (stream_enable[i]) begin
                      //                   if (terminated[i]) begin
                      //                       valid_reg[i] <= 1;
                      //                   end else begin
                      //                       valid_reg[i] <= 0;
                      //                   end
                      //               end else begin
                      //                   valid_reg[i] <= 0;
                      //               end
                      //           end
                      //       end
                      //   end
                      //   endgenerate
                      //
                      // endmodule