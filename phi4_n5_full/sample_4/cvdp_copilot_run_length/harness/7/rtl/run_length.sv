module outputs the run lengths, the corresponding data values, and validity flags when a valid run length is available. The updated module must meet the following requirements:" and then lists requirements.

We are given original code "rtl/run_length.sv" and must produce a modified code that satisfies requirements. The updated module must have the following:
- Module name: parallel_run_length.
- Parameters: DATA_WIDTH (default = 8) and NUM_STREAMS (default = 4).
- Inputs: clk, reset_n, data_in [NUM_STREAMS-1:0], stream_enable [NUM_STREAMS-1:0].
- Outputs: data_out [NUM_STREAMS-1:0], run_value [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0 ], valid [NUM_STREAMS-1:0].
- Run-Length Calculation: Each stream's run length is tracked independently. If current input equals previous value, then run_length counter increments. If input changes, the current run length is output and run counter resets to 1 for the new value.
- Maximum Run Length Handling: The run-length counter increments until it either encounters a new data value or reaches DATA_WIDTH. When run length reaches DATA_WIDTH, that run length must be immediately output, and the run counter resets to 1 if the same data value continues, effectively starting a new run.
- Validity and Output Generation: The valid output for a stream is asserted whenever a run length is available, either due to reaching DATA_WIDTH or encountering a new data value. When valid[i] is asserted, data_out[i] must hold the corresponding data value for the run that just ended, and run_value must reflect the length of that run.
- On cycles where no run terminates, valid[i] remains low for that stream.
- Stream Enable Behavior: When stream_enable[i] is deasserted, the run-length logic and outputs for that stream must reset or remain at default values. No valid run lengths should be reported for a disabled stream. When stream_enable[i] is reasserted, that stream's run-length logic should resume as if starting fresh.
- Timing Requirements: Operations are synchronous with clock signal, reset behavior is asynchronous.
- Constraints and Edge Cases: input data is binary, boundary conditions: run length saturates at DATA_WIDTH, etc.

Plan: We need to design a module named parallel_run_length. We'll need a parameter NUM_STREAMS. We'll need a parameter DATA_WIDTH. We'll need inputs: clk, reset_n, data_in [NUM_STREAMS-1:0], stream_enable [NUM_STREAMS-1:0]. Outputs: data_out [NUM_STREAMS-1:0], run_value [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0 ], valid [NUM_STREAMS-1:0]. The run_value output is a bus with NUM_STREAMS words, each word is run_length value. But requirement "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" means that each run length is output as a bus with bits [$clog2(DATA_WIDTH):0]. But note: In the original code, run_value was an output reg [$clog2(DATA_WIDTH):0]. So we can assume each stream's run_value is of width ($clog2(DATA_WIDTH)+1) bits. But I want to check: In the original code, run_value width was $clog2(DATA_WIDTH):0, i.e. $clog2(DATA_WIDTH) + 1 bits. So for each stream, we need a similar width. So our run_value bus is an array of NUM_STREAMS values, each of width ($clog2(DATA_WIDTH)+1). But the requirement says: "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" so that is a concatenation of NUM_STREAMS such registers. But we can also declare it as an array of registers. But since we are allowed to use SystemVerilog, we can use "genvar" to generate multiple instances of similar logic.

I can use generate for loop from i=0 to NUM_STREAMS-1. For each stream i, we need to track a run_length register of width ($clog2(DATA_WIDTH)+1) bits. Also, need to track previous data input for that stream. And also have outputs: data_out[i], valid[i], and run_value[i]. Additionally, we must handle stream_enable[i]. So if stream_enable[i] is deasserted, we need to reset the run_length and previous data input and outputs.

Plan for each stream i:
- Registers:
  - reg [$clog2(DATA_WIDTH):0] run_length_i; // run counter for stream i.
  - reg prev_data_i; // previous data for stream i.
- On reset, if reset_n is low, then set run_length_i to 0, prev_data_i to 0, valid[i] to 0, data_out[i] to 0.
- On clock rising edge and if reset_n is high:
  - If stream_enable[i] is asserted:
    - if current data_in[i] equals prev_data_i, then:
         - run_length_i = run_length_i + 1
         - But if run_length_i equals DATA_WIDTH (i.e. maximum run length), then we need to output run_value and valid, but then if data_in[i] is same as prev_data_i, we reset run_length_i to 1. But note: The requirement says: "When run length reaches DATA_WIDTH, that run length must be immediately output, and the run counter must reset to 1 if the same data value continues, effectively starting a new run." So in this branch, if (run_length_i == DATA_WIDTH) then we output valid and run_value, then set run_length_i to 1? But careful: If run_length_i == DATA_WIDTH, then we must output it. But what if run_length_i is less than DATA_WIDTH? Then no valid output is produced until a change happens. But if run_length_i increments to DATA_WIDTH, then we output valid. But what if run_length_i is less than DATA_WIDTH and remains so? Then no valid output. But the description says: "When valid[i] is asserted, data_out[i] must hold the corresponding data value for the run that just ended, and run_value must reflect the length of that run." So the moment we detect a termination condition (either a change in data or run_length equals DATA_WIDTH), we should assign valid, data_out, and run_value registers with the run_length value and previous data. And then reset run_length to 1 if the same value continues, but if a new value is detected, then run_length resets to 1. But wait: It says: "If the input value changes, the current run length is output, and the counter resets to 1 for the new value." So in both cases, after output, we reset run_length to 1. But the tricky part is: if run_length becomes DATA_WIDTH, then we output valid and run_value, then if the same input continues, run_length resets to 1. But what if the same input does not continue? Well, if input changes, then we output run_value and valid, then run_length resets to 1. But if input stays same and run_length becomes DATA_WIDTH, then we output valid and run_value, then if input remains same, then run_length resets to 1.
    - Else if data_in[i] != prev_data_i:
         - then output run_value and valid, then reset run_length_i to 1 and update prev_data_i to data_in[i].
  - Else if stream_enable[i] is not asserted:
         - then we want to reset run_length_i to 0, prev_data_i to 0, valid[i] to 0, data_out[i] to 0. But careful: The description says: "When stream_enable[i] is deasserted, the run-length logic and outputs for that stream must reset or remain at default values." So we can choose to simply not update run_length. But to be safe, we can do a synchronous reset of that stream's logic if stream_enable is low. But wait, but the requirement says: "When stream_enable[i] is deasserted, no valid run lengths should be reported." So we can simply not update valid[i] if stream_enable[i] is low. But what about if stream_enable was high and then becomes low? It says: "When stream_enable[i] is deasserted, the run-length logic and outputs for that stream must reset or remain at default values." So I can simply if (!stream_enable[i]) then assign run_length_i = 0, prev_data_i = 0, valid[i] = 0, data_out[i] = 0. But careful: Should we do it synchronous? The reset is asynchronous, but stream_enable changes synchronous. So we can do: if (!stream_enable[i]) begin ... assign default values.

Plan: We'll use a generate loop for each stream i from 0 to NUM_STREAMS-1. But careful: We need to declare run_value as an array of NUM_STREAMS elements each with width $clog2(DATA_WIDTH)+1. But the requirement says "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" so it's a concatenated bus. But easier is to declare it as a reg array: reg [$clog2(DATA_WIDTH):0] run_value [NUM_STREAMS-1:0]. But then in the port list we want run_value as an array bus. But the requirement says: "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]" which is a bus. But if we declare as an array, then the port declaration is run_value output reg [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]. But then we need to assign each slice properly. But that might be tricky. Alternatively, we can declare an array of registers and then assign them to the bus. But since we want the output to be a bus, we might want to declare a reg array with a vector type. But SystemVerilog allows array ports if using the "packed" type. Alternatively, we can declare it as: output reg [($clog2(DATA_WIDTH)+1)-1:0] run_value [NUM_STREAMS-1:0]; but then the port declaration would be different from the requirement. The requirement explicitly says: "run_value [(NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0]". That is a concatenation of NUM_STREAMS registers, each of width ($clog2(DATA_WIDTH)+1). I can declare it as: output reg [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value; and then in the code, for each stream i, assign run_value [i*($clog2(DATA_WIDTH)+1)+:($clog2(DATA_WIDTH)+1)] = run_length_i. That is acceptable.

I can also declare data_out and valid as arrays. But the requirement says: "data_out [NUM_STREAMS-1:0]" and "valid [NUM_STREAMS-1:0]". I can declare them as arrays of bits. I can declare them as output reg [NUM_STREAMS-1:0] data_out and output reg valid [NUM_STREAMS-1:0]. But that means each valid is 1 bit. But the requirement says "valid [NUM_STREAMS-1:0]" which is an array of bits, I think that's fine.

I'll declare the module as:

module parallel_run_length
#(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)
(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

Inside, I'll use generate loop for each stream index i. But careful: We need to generate for i from 0 to NUM_STREAMS-1. But then the outputs data_out[i], valid[i] are separate registers. But run_value is a bus that is concatenation of each stream's run_length value. I can either use generate loop to create an array of registers for run_length and prev_data, and then assign them to run_value bus. But since run_value is a bus, I can do a concatenation assignment in an always block at the end.

I can do something like:

genvar i;
generate
   for (i = 0; i < NUM_STREAMS; i = i + 1) begin : stream_gen
       reg [$clog2(DATA_WIDTH):0] run_length_i;
       reg prev_data_i;
       always @(posedge clk or negedge reset_n) begin
           if (!reset_n) begin
               run_length_i <= 'b0;
               prev_data_i <= 1'b0;
           end else begin
               if (stream_enable[i]) begin
                   if (data_in[i] == prev_data_i) begin
                       // increment run_length_i
                       run_length_i <= run_length_i + 1'b1;
                       if (run_length_i == DATA_WIDTH) begin
                           // run_length reached maximum, output run value
                           // then reset to 1 if same data continues.
                           run_length_i <= 1'b1;
                       end
                   end else begin
                       // data changed, output current run length and reset
                       run_length_i <= 1'b1;
                   end
                   prev_data_i <= data_in[i];
               end else begin
                   // stream disabled, reset logic
                   run_length_i <= 'b0;
                   prev_data_i <= 1'b0;
               end
           end
       end
   end
endgenerate

But careful: We need to output valid and data_out only when a run terminates. But the logic is: if the run terminates (i.e. if data changed OR if run_length_i becomes DATA_WIDTH), then output valid, data_out and run_value. But in our always block above, we are doing run_length_i update, but we don't output valid signals. We need separate always block to handle outputs for each stream. But since we are using generate loop, we can create separate always blocks for outputs for each stream.

I can do something like:
generate
   for (i = 0; i < NUM_STREAMS; i = i + 1) begin : out_gen
       always @(posedge clk or negedge reset_n) begin
           if (!reset_n) begin
               data_out[i] <= 1'b0;
               valid[i] <= 1'b0;
           end else begin
               if (stream_enable[i]) begin
                   if ( (data_in[i] != prev_data_i) || (run_length_i == DATA_WIDTH) ) begin
                       // run terminated, output run value and valid flag
                       data_out[i] <= prev_data_i;
                       valid[i] <= 1'b1;
                   end else begin
                       valid[i] <= 1'b0;
                   end
               end else begin
                   // stream disabled, no valid output
                   data_out[i] <= 1'b0;
                   valid[i] <= 1'b0;
               end
           end
       end
   end
endgenerate

But careful: In the always block for outputs, I'm reading prev_data_i and run_length_i which are declared inside the generate loop for the same i. But they are declared in the same generate block if I use a separate generate block. But then I need to reference them. But in SystemVerilog, if I declare a generate block, the variables inside are local to that block. But if I want to reference them in a separate always block inside the same generate block, they might not be visible if they are declared in a different always block. So I might need to declare them outside the always block, but then use them in always block. But I can declare them in a generate block and then use them inside always block in the same block. But it's better to declare them as regs in the module scope and then use generate loop to create the logic for each stream. But then I'll have to declare arrays for run_length and prev_data. Alternatively, I can nest the always block inside the same generate block where I declare run_length_i and prev_data_i. But then I'll have two always blocks in the same generate block. But that's allowed in SystemVerilog. But then I need to declare run_length_i and prev_data_i outside the always block. I'll do that.

I can do something like:

genvar i;
generate
   for (i = 0; i < NUM_STREAMS; i = i + 1) begin : stream_logic
       reg [$clog2(DATA_WIDTH):0] run_length_i;
       reg prev_data_i;
       always @(posedge clk or negedge reset_n) begin
           if (!reset_n) begin
               run_length_i <= 'b0;
               prev_data_i <= 1'b0;
           end else begin
               if (stream_enable[i]) begin
                   if (data_in[i] == prev_data_i) begin
                       run_length_i <= run_length_i + 1'b1;
                       if (run_length_i == DATA_WIDTH) begin
                           run_length_i <= 1'b1; // reset to 1 after max reached
                       end
                   end else begin
                       run_length_i <= 1'b1;
                   end
                   prev_data_i <= data_in[i];
               end else begin
                   run_length_i <= 'b0;
                   prev_data_i <= 1'b0;
               end
           end
       end

       // Output logic for each stream
       always @(posedge clk or negedge reset_n) begin
           if (!reset_n) begin
               data_out[i] <= 1'b0;
               valid[i] <= 1'b0;
           end else begin
               if (stream_enable[i]) begin
                   // Check if run terminated: either data changed or run_length reached DATA_WIDTH.
                   if ((data_in[i] != prev_data_i) || (run_length_i == DATA_WIDTH)) begin
                       data_out[i] <= prev_data_i;
                       valid[i] <= 1'b1;
                   end else begin
                       valid[i] <= 1'b0;
                   end
               end else begin
                   data_out[i] <= 1'b0;
                   valid[i] <= 1'b0;
               end
           end
       end
   end
endgenerate

Then I need to assign the run_value bus. run_value is a bus that concatenates each stream's run_length. I can do that in an always block that runs on posedge clk, or I can do a continuous assignment. But since run_length_i is a register updated on clock, I can assign run_value using a loop in an always block. But I need to assign run_value bus as a vector. I can do something like:

always @(*) begin
    // assign run_value bus from each stream's run_length_i
    integer j;
    for (j = 0; j < NUM_STREAMS; j = j + 1) begin
         run_value[j * ($clog2(DATA_WIDTH)+1) +: ($clog2(DATA_WIDTH)+1)] = run_length[j];
    end
end

But wait, run_length[j] is not declared as an array. I declared run_length_i inside generate block. I can declare an array to hold them. Alternatively, I can use generate loop to assign each segment of run_value bus. But then I need to reference run_length_i from each generate instance. But since they are declared in a generate block, I can reference them in a continuous assignment outside the generate block. But that might be tricky because they are not declared as an array. But I can declare an array of regs in the module, then instantiate the generate loop to assign them. But the requirement says "Your response will be saved directly to: rtl/run_length.sv." So I must output a file named run_length.sv with the modified code.

I can declare arrays for run_length and prev_data at module level, then use generate loops for each stream. That might be simpler. I'll do that:

module parallel_run_length
#(
    parameter DATA_WIDTH = 8,
    parameter NUM_STREAMS = 4
)
(
    input wire clk,
    input wire reset_n,
    input wire [NUM_STREAMS-1:0] data_in,
    input wire [NUM_STREAMS-1:0] stream_enable,
    output reg [NUM_STREAMS-1:0] data_out,
    output reg [ (NUM_STREAMS * ($clog2(DATA_WIDTH)+1)) - 1:0] run_value,
    output reg [NUM_STREAMS-1:0] valid
);

   // Declare arrays for run_length and prev_data for each stream
   reg [$clog2(DATA_WIDTH):0] run_length [NUM_STREAMS-1:0];
   reg prev_data [NUM_STREAMS-1:0];

   integer i;

   // Combinational assignment for run_value bus from run_length array
   // We can do this in an always block
   integer j;
   always @(*) begin
       for (j = 0; j < NUM_STREAMS; j = j + 1) begin
           run_value[j * ($clog2(DATA_WIDTH)+1) +: ($clog2(DATA_WIDTH)+1)] = run_length[j];
       end
   end

   // Sequential logic for each stream
   always @(posedge clk or negedge reset_n) begin
       if (!reset_n) begin
           // Reset all streams
           for (i = 0; i < NUM_STREAMS; i = i + 1) begin
               run_length[i] <= 'b0;
               prev_data[i]  <= 1'b0;
           end
       end else begin
           for (i = 0; i < NUM_STREAMS; i = i + 1) begin
               if (stream_enable[i]) begin
                   if (data_in[i] == prev_data[i]) begin
                       run_length[i] <= run_length[i] + 1'b1;
                       if (run_length[i] == DATA_WIDTH) begin
                           run_length[i] <= 1'b1; // reset counter after max reached
                       end
                   end else begin
                       run_length[i] <= 1'b1;
                   end
                   prev_data[i] <= data_in[i];
               end else begin
                   // stream disabled, reset the stream logic
                   run_length[i] <= 'b0;
                   prev_data[i]  <= 1'b0;
               end
           end
       end
   end

   // Output logic for data_out and valid for each stream
   always @(posedge clk or negedge reset_n) begin
       if (!reset_n) begin
           for (i = 0; i < NUM_STREAMS; i = i + 1) begin
               data_out[i] <= 1'b0;
               valid[i]    <= 1'b0;
           end
       end else begin
           for (i = 0; i < NUM_STREAMS; i = i + 1) begin
               if (stream_enable[i]) begin
                   if ((data_in[i] != prev_data[i]) || (run_length[i] == DATA_WIDTH)) begin
                       data_out[i] <= prev_data[i];
                       valid[i]    <= 1'b1;
                   end else begin
                       valid[i] <= 1'b0;
                   end
               end else begin
                   data_out[i] <= 1'b0;
                   valid[i]    <= 1'b0;
               end
           end
       end
   end

endmodule