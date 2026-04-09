<think>We are asked to produce one answer for the request: "Complete the module named pipelined_skid_buffer in SystemVerilog" but the text includes also modules for register and skid_buffer. But instructions says: "You are solving an 'RTL Code Completion' problem. To solve this problem correctly, you should only respond with the RTL code generated according to the requirements."

So I must produce a single answer with the complete code in a file that is saved to rtl/pipelined_skid_buffer.sv. We must produce only the RTL code, plain text.

The structure: The file includes three modules: pipelined_skid_buffer, register, skid_buffer. They must be in a file rtl/pipelined_skid_buffer.sv. The code should meet the specs.

We need to design pipelined_skid_buffer module. It uses an input skid buffer, a register, a second skid buffer, and then a register. But the question says: "The design should include: An input skid buffer (skid_0) for data input and initial buffering. A register (reg1) to store and forward data after the first buffer. A second skid buffer (skid_2) for intermediate buffering. Another register (reg3) at the end to finalize the data pipeline." So the pipelined structure is:

Input stage: skid buffer (skid_0) using the module skid_buffer. Then register reg1. Then second skid buffer (skid_2) using module skid_buffer. Then register reg3.

But then, wait, check the I/O signals: The module pipelined_skid_buffer has interface: inputs: clock, rst, data_i[3:0], valid_i, ready_i; outputs: data_o[3:0], valid_o, ready_o. So we need to implement the pipeline: The data flows from data_i to skid buffer (skid_0), then to reg1, then to skid buffer (skid_2), then to reg3, and then to outputs.

But wait, the interface of skid_buffer is: 
- Inputs: clk, reset, i_data, i_valid, i_ready. 
- Outputs: o_data, o_valid, o_ready.
The interface of register is:
- Inputs: clk, rst, data_in, valid_in, ready_in.
- Outputs: data_out, valid_out, ready_out.
But note: The ready signal naming is reversed: In register, input ready_in is used to accept new data, output ready_out is the register's readiness to accept new data. And for skid_buffer, input i_ready is the readiness of downstream logic to accept data, and output o_ready is the readiness of the skid buffer to accept new input data.

So the pipeline connections: 
- Stage 1: skid_buffer stage: 
   Connect: data_i, valid_i, and ready? The input ready_i is for the pipelined system? Actually, careful: The module pipelined_skid_buffer has interface: data_i, valid_i, ready_i. The ready_i signal is provided as input to the module pipelined_skid_buffer? Wait, check the interface: "input ready_i" in pipelined_skid_buffer. But then output ready_o is provided. Possibly, ready_i is the readiness of the first stage to accept data from upstream? Actually, re-read the interface: 
  - Input signals: clock, rst, data_i, valid_i, ready_i. 
  - Output signals: data_o, valid_o, ready_o.
  So ready_i is input to pipelined_skid_buffer. But then in the pipeline, the first stage is skid_buffer skid_0. It expects input ready? But the skid_buffer expects input i_ready as the readiness of downstream logic to accept data. So the first stage's i_ready should be connected to the output ready of reg1? Wait, let's plan the pipeline:

We have pipeline stages:

Stage 1: skid buffer skid_0.
- Inputs: clock, rst, i_data = data_i, i_valid = valid_i, i_ready = ? 
  The skid buffer module interface: input i_ready is "input ready" of downstream logic. So in the pipeline, the first stage is connected to the next stage (register reg1). But then the register module expects input ready_in which is "downstream ready". So we connect skid_buffer's output o_ready to register's input ready_in? But careful: The register's interface: input ready_in is used to indicate readiness of downstream logic to accept data. So in the pipeline, the first stage's output is fed into register reg1. 
  So for stage 1 (skid_buffer), i_ready should be connected to reg1's ready_in? But then reg1's ready_in is an input that when high, means the register is ready to accept data? But in a handshake, the register's ready_in should be asserted by downstream stage. 
  Wait, the pipeline: Stage 1 (skid buffer) outputs to register reg1. So the register reg1 is downstream of skid buffer. So we want to connect: skid_buffer's i_ready = reg1.ready_in? But reg1.ready_in is an input signal to register, but reg1 is a module instance. However, in our pipelined_skid_buffer, we don't have a ready_i for reg1's ready_in? Wait, re-read the module interface: 
  - pipelined_skid_buffer has input ready_i. That signal is likely the readiness of the downstream block of pipelined_skid_buffer. So pipelined_skid_buffer's output ready_o is the readiness of pipelined register to receive data from upstream blocks. So then the pipeline inside pipelined_skid_buffer is connecting: 
  Stage 1: skid_buffer: input: i_data = data_i, i_valid = valid_i, i_ready = ? 
  Since pipelined_skid_buffer has an input ready_i which is the readiness of the downstream block. But wait, the interface: 
  "input ready_i: To indicate downstream readiness." 
  So ready_i is the readiness of the module's output? Actually, it's ambiguous. It says: "input ready_i: To indicate downstream readiness." That is a bit ambiguous, but likely it means that the module's output (data_o, valid_o, ready_o) is connected to a downstream block, and that block asserts ready_i to accept data. But then the module itself should drive ready_o, which indicates that the pipelined register is ready to receive data from upstream blocks. So the pipelined module is in the middle. It receives data from upstream modules through data_i and valid_i, and then it drives data_o and valid_o to downstream modules, and it accepts a ready_i from the downstream modules to indicate they are ready to accept data. The module also outputs ready_o to indicate that the pipelined register is ready to accept new data from upstream blocks.

  So how do we connect ready signals?
  In a pipeline, the first stage's i_ready is connected to the second stage's ready_in. So the pipeline stages:
  Stage 1: skid_buffer: 
     i_data = data_i, i_valid = valid_i, i_ready = ? 
  Stage 2: register reg1:
     data_in = skid_buffer.o_data, valid_in = skid_buffer.o_valid, ready_in = ? 
  Stage 3: skid_buffer (skid_2):
     i_data = reg1.data_out, i_valid = reg1.valid_out, i_ready = ? 
  Stage 4: register reg3:
     data_in = skid_buffer2.o_data, valid_in = skid_buffer2.o_valid, ready_in = ? 
  And then the outputs of the pipeline are: data_o = reg3.data_out, valid_o = reg3.valid_out, and the input to the pipeline is ready_i, which should be connected to stage 4's ready_in, because stage 4 is the last stage and its downstream is the pipelined module's output. But then what is ready_o? The module's ready_o is supposed to indicate readiness of pipelined register to receive data from upstream blocks. That would be stage 1's ready input? But stage 1's i_ready is not explicitly present. In skid_buffer, the output is o_ready. So maybe pipelined_skid_buffer's ready_o should be connected to the input of stage 1? But stage 1 is the first stage and its input ready is i_ready. But the skid_buffer module's port is i_ready. So we can connect pipelined_skid_buffer.ready_o to skid_buffer0.i_ready. But then what about ready_i? The pipelined_skid_buffer has input ready_i, which is the readiness of the downstream block to accept data. That should be connected to stage 4's ready_in (the last register reg3's ready_in). But then also the last stage (skid_buffer2) outputs o_ready to reg3's ready_in? But careful: The pipeline chain is: skid_buffer0 -> reg1 -> skid_buffer2 -> reg3 -> output.

  Let's map the ports:
  Module pipelined_skid_buffer:
    Inputs: clock, rst, data_i, valid_i, ready_i.
    Outputs: data_o, valid_o, ready_o.
  
  We want to instantiate:
    skid_buffer skid_0 (
         .clk(clock),
         .reset(rst),
         .i_data(data_i),
         .i_valid(valid_i),
         .i_ready( ??? ), // this should be connected to reg1's ready_in? But reg1 is downstream.
         .o_data( ... ),
         .o_valid( ... ),
         .o_ready( ??? ) // This will be connected to reg1's ready_in? But careful: The ready input of skid_buffer is i_ready, and its output ready is o_ready.
    );
  
  But wait, the skid_buffer module has i_ready as an input. That means that the module expects a signal from downstream logic saying "I am ready to accept data." So for the first stage, the downstream logic is reg1. So we want to connect reg1.ready_in to skid_buffer's i_ready. But then what does reg1.ready_in represent? In the register module, ready_in is an input that indicates that downstream logic is ready to accept data. So we can connect skid_buffer0.o_ready to reg1.ready_in. But then what is the connection for skid_buffer0.i_ready? The skid_buffer module's i_ready is input from downstream logic. But for the first stage, there is no downstream logic; it's the first stage in the pipeline. So maybe we want to tie skid_buffer0.i_ready to 1 (or to pipelined_skid_buffer.ready_o)? But then ready_o is supposed to indicate readiness of pipelined register to receive data from upstream blocks. That would be the input of the pipeline, so it should be driven by skid_buffer0.o_ready? Actually, let's re-read the spec for pipelined_skid_buffer:
  "An input skid buffer (skid_0) for data input and initial buffering. A register (reg1) to store and forward data after the first buffer. A second skid buffer (skid_2) for intermediate buffering. Another register (reg3) at the end to finalize the data pipeline."
  
  So the stages are in series. The handshake between stages:
  - Stage 1 (skid_0) has inputs: i_data, i_valid, and i_ready. Its output: o_data, o_valid, and o_ready.
  - Stage 2 (reg1) takes the output of skid_0 as input. Its input ready_in should be connected to skid_0.o_ready? But wait, check register module interface: It has inputs: data_in, valid_in, ready_in, and outputs: data_out, valid_out, ready_out. In a typical handshake, the module's ready_in is asserted by the downstream block. So for reg1, the downstream block is skid_buffer2. So we connect reg1.ready_in to skid_buffer2.o_ready.
  - Stage 3 (skid_buffer2) takes reg1 as input, so its i_data = reg1.data_out, i_valid = reg1.valid_out, and i_ready = ? The downstream block for skid_buffer2 is reg3. So we connect skid_buffer2.o_ready to reg3.ready_in.
  - Stage 4 (reg3) is the last stage. Its input ready_in should be connected to pipelined_skid_buffer.ready_i, because pipelined_skid_buffer receives a ready_i signal from the downstream block. And its output is data_o and valid_o.
  
  Now, what about the pipelined_skid_buffer's ready_o? That should be the input ready signal for the first stage (skid_0). So pipelined_skid_buffer.ready_o = skid_0.i_ready.
  
  So connections:
  skid_0:
    .clk(clock)
    .reset(rst)
    .i_data(data_i)
    .i_valid(valid_i)
    .i_ready(pipelined_skid_buffer.ready_o)  // but we haven't defined that yet. We'll assign pipelined_skid_buffer.ready_o to skid_0.i_ready.
    .o_data(skid0_out)
    .o_valid(skid0_valid)
    .o_ready(reg1.ready_in)  // But reg1.ready_in is an input, but we want to drive it with skid_0.o_ready.
  
  reg1:
    .clk(clock)
    .rst(rst)
    .data_in(skid0_out)
    .valid_in(skid0_valid)
    .ready_in(skid_buffer2.o_ready)  // from stage 3's o_ready
    .data_out(reg1_data)
    .valid_out(reg1_valid)
    .ready_out(skid_buffer2.ready? But actually, register's ready_out is the module's readiness to accept new input. But in our pipeline, the output of reg1 is fed to stage 3. But the handshake: stage 3 expects input ready signal? Actually, check skid_buffer interface: it has i_ready as input from downstream logic. So for stage 3, its i_ready should come from reg1.ready_out? No, wait, we already connected reg1.ready_in to skid_buffer2.o_ready. So reg1.ready_out is not used here.
  
  Actually, let's re-read the register module spec:
  - The register module has handshake:
    Input: valid_in, ready_in.
    Output: valid_out, ready_out.
  So the register's ready_out indicates that it is ready to accept new input. For stage 1, reg1's ready_out should be connected to the input of stage 2 (skid_buffer2)? But stage 2 is a skid_buffer, which expects i_ready from downstream logic. So we connect reg1.ready_out to skid_buffer2.i_ready.
  
  Now stage 3 (skid_buffer2):
    .clk(clock)
    .reset(rst)
    .i_data(reg1.data_out)
    .i_valid(reg1.valid_out)
    .i_ready(reg1.ready_out) ? But careful: The skid_buffer2's i_ready should be the readiness of downstream logic. The downstream logic for skid_buffer2 is reg3. So we should connect skid_buffer2.i_ready to reg3.ready_in.
  
  Wait, let's reassign:
  
  Actually, pipeline stages:
  Stage 1: skid_buffer (skid_0)
    Inputs: data_i, valid_i, i_ready.
    Output: o_data, o_valid, o_ready.
  Stage 2: register (reg1)
    Inputs: data_in = skid_0.o_data, valid_in = skid_0.o_valid, ready_in = ? 
    Output: data_out, valid_out, ready_out.
  Stage 3: skid_buffer (skid_2)
    Inputs: data_in = reg1.data_out, valid_in = reg1.valid_out, i_ready = ? 
    Output: o_data, o_valid, o_ready.
  Stage 4: register (reg3)
    Inputs: data_in = skid_2.o_data, valid_in = skid_2.o_valid, ready_in = ? 
    Output: data_out, valid_out, ready_out.
  
  And then, pipelined_skid_buffer interface:
    - ready_i is provided as input, which should be connected to stage 4's ready_in? But register module ready_in is an input signal that indicates that downstream logic is ready. So for stage 4, ready_in = pipelined_skid_buffer.ready_i.
    - The pipelined_skid_buffer outputs: data_o = reg3.data_out, valid_o = reg3.valid_out.
    - The pipelined_skid_buffer also outputs ready_o, which should be connected to the input ready of stage 1, i.e., skid_0.i_ready.
  
  Now, how do we connect between stages? The handshake:
  For a valid/ready handshake, the output ready of a stage should be connected to the input ready of the next stage.
  
  So:
  skid_0.o_ready -> reg1.ready_in.
  reg1.ready_out -> skid_2.i_ready.
  skid_2.o_ready -> reg3.ready_in.
  
  And then:
  pipelined_skid_buffer.ready_o = skid_0.i_ready.
  pipelined_skid_buffer.ready_i is an input to the module, and it should be connected to reg3.ready_in? But careful: reg3 is stage 4, its ready_in is an input signal that indicates that downstream logic is ready to accept data from reg3. So we connect pipelined_skid_buffer.ready_i to reg3.ready_in.
  
  So final connections:
  pipelined_skid_buffer module instantiates:
  
  wire [3:0] skid0_data;
  wire skid0_valid;
  wire skid0_ready; // output from skid_0
  // For skid_0, i_ready = pipelined_skid_buffer.ready_o (to be driven by module output).
  
  skid_buffer skid_0 (
      .clk(clock),
      .reset(rst),
      .i_data(data_i),
      .i_valid(valid_i),
      .i_ready(ready_o),   // assign pipelined_skid_buffer.ready_o to skid_0.i_ready
      .o_data(skid0_data),
      .o_valid(skid0_valid),
      .o_ready( reg1_ready_in )   // But reg1_ready_in is an input to reg1, so we need to drive it from skid_0.o_ready. We can connect directly: reg1_inst.ready_in = skid_0.o_ready.
  );
  
  Next, instantiate register reg1:
  wire [3:0] reg1_data;
  wire reg1_valid;
  wire reg1_ready_out;
  // reg1: inputs: data_in = skid0_data, valid_in = skid0_valid, ready_in = ???.
  // The ready_in of reg1 should come from the output of stage 1's o_ready, which we already connected to reg1.ready_in.
  // So we can instantiate as:
  register reg1 (
      .clk(clock),
      .rst(rst),
      .data_in(skid0_data),
      .valid_in(skid0_valid),
      .ready_in(skid_0.o_ready),  // but we already used skid_0.o_ready as signal, so we can wire it.
      .data_out(reg1_data),
      .valid_out(reg1_valid),
      .ready_out(reg1_ready_out)
  );
  
  However, note: We already connected skid_0.o_ready to reg1.ready_in in the instantiation of skid_0. But we cannot use the same signal twice? Actually, we can declare a wire for skid_0.o_ready and then connect it to reg1.ready_in.
  
  Let's do:
  wire skid0_o_ready;
  Then instantiate skid_0 with:
      .o_ready(skid0_o_ready);
  And then instantiate reg1 with:
      .ready_in(skid0_o_ready);
  
  Next, stage 3: skid_buffer skid_2:
  wire [3:0] skid2_data;
  wire skid2_valid;
  wire skid2_o_ready;
  Instantiate skid_buffer skid_2 with:
      .clk(clock),
      .reset(rst),
      .i_data(reg1_data),
      .i_valid(reg1_valid),
      .i_ready(reg1_ready_out),  // Because reg1.ready_out is the readiness of reg1 to accept new input, but wait, that's not correct. Actually, stage 3's i_ready is the input from reg1. But we want the handshake: reg1.ready_out indicates that reg1 is ready to accept new input from stage 2, not stage 3. Let's re-check handshake: 
         Stage 2 (reg1) outputs: data_out, valid_out, ready_out. ready_out indicates that reg1 is ready to accept new data. That should be connected to stage 3's i_ready? But stage 3 is a skid_buffer, which expects i_ready from downstream logic. But wait, let's re-read skid_buffer spec: "i_ready: Indicates the readiness of downstream logic to accept data." So for stage 3, the downstream logic is reg3, so its i_ready should be connected to reg3.ready_in. So we connect reg1.ready_out to skid_2.i_ready? But then what is reg1.ready_out's meaning? Actually, in a pipeline, the output ready of one stage is connected to the input ready of the next stage. So stage 2's ready_out should be connected to stage 3's i_ready. But stage 2 is reg1, so reg1.ready_out goes to skid_2.i_ready.
  
  So instantiate skid_2 with:
      .i_data(reg1_data),
      .i_valid(reg1_valid),
      .i_ready(reg1_ready_out), // from reg1
      .o_data(skid2_data),
      .o_valid(skid2_valid),
      .o_ready( skid2_o_ready );
  
  Next, stage 4: register reg3:
  wire [3:0] reg3_data;
  wire reg3_valid;
  wire reg3_ready_out;
  Instantiate register reg3 with:
      .clk(clock),
      .rst(rst),
      .data_in(skid2_data),
      .valid_in(skid2_valid),
      .ready_in(pipelined_skid_buffer.ready_i), // connect pipelined_skid_buffer.ready_i to reg3.ready_in
      .data_out(reg3_data),
      .valid_out(reg3_valid),
      .ready_out(reg3_ready_out);
  
  Then assign pipelined_skid_buffer outputs:
      data_o = reg3_data,
      valid_o = reg3_valid,
      ready_o = ??? 
  But ready_o is supposed to indicate that the pipelined register is ready to receive data from upstream blocks. That is stage 1's input. So we want ready_o to be driven by skid_0.i_ready. But we already connected skid_0.i_ready to pipelined_skid_buffer.ready_o. So we simply assign ready_o = 1? No, we need to generate a signal that indicates if the pipeline is ready to accept new data. That is typically the first stage's input ready. But we want to drive that from the module's output. But we can simply assign ready_o = 1 if no data is being buffered? But the spec says: "ready_o: to signal readiness of pipelined register to receive data from upstream blocks." That means that if the first stage is ready to accept data, then ready_o should be high. And since we are connecting pipelined_skid_buffer.ready_o to skid_0.i_ready, we need to drive that signal. But we don't have an internal logic for that. We could simply assign ready_o = 1? But that might be not synthesizable if we want to implement backpressure.
  
  However, the typical handshake: upstream module drives valid_i and expects the pipelined module to assert ready_o when it can accept data. The pipelined module's internal pipeline is ready to accept data if the first stage is ready. But the first stage (skid_0) has an input i_ready which is driven by pipelined_skid_buffer.ready_o. So we want to set pipelined_skid_buffer.ready_o to 1 if skid_0 is not busy. But how do we know if skid_0 is busy? Possibly, we can check if there is data stored in skid_0. But the spec for skid_buffer: "Use a buffer flag to indicate whether the internal register is storing a value." But that flag is internal to skid_buffer, and not exposed. We could add an output from skid_buffer that indicates if it is busy. But spec does not mention an output for busy. We only have o_valid and o_ready. 
  We can assume that if skid_buffer is not storing data, then it is ready to accept new data. But how to determine that? We could assume that skid_buffer always accepts new data if there's no data stored. But since the spec says: "Temporarily store incoming data when the downstream module indicates it is not ready (i_ready is low)." So if downstream is not ready, then skid_buffer will store the data. And if it already has stored data, then it will not accept new data. But this logic is internal to the skid_buffer module. But we are free to implement skid_buffer module as we want.
  
  So we need to implement the skid_buffer module with an internal register and a flag "buffer" that indicates if data is stored. And then the logic: if i_valid and i_ready is high, then pass data directly. If i_valid is high but i_ready is low, then store data in internal register and assert o_valid = 1, and o_ready = 0 because it's busy. Then when i_ready becomes high, forward the stored data.
  
  Similarly, implement register module: It should store data when valid_in and ready_in are asserted, and then hold it until downstream is ready (i.e., valid_out remains high until ready_in is asserted, then drop valid_out).
  
  But the spec for register module: "Maintain current data until downstream logic indicates readiness to accept it (ready_in)". That means that if ready_in is low, the register holds the data and valid_out remains high. When ready_in becomes high, then data is transferred and valid_out becomes low.
  
  So register module implementation: 
  On posedge clk:
      if (rst) then mem <= 0, data_present <= 0.
      else if (valid_in && ready_in) then mem <= data_in, data_present <= 1.
      And valid_out is data_present, and ready_out is always 1? But handshake: ready_out indicates that the register is ready to accept new data. But in a typical register, ready_out is not simply combinational; it might be a combinational output that is high if the register is not busy. But the spec says: "Implement a handshake mechanism using ready and valid signals." So we want: 
         valid_out = data_present.
         ready_out = 1 (or maybe it should be high if no data is stored, but then if data is stored and not accepted, then ready_out should be low because it's busy)? Actually, typical handshake: The register should only accept new data if it is not busy. And if it already has data waiting, then it should not accept new data until the downstream is ready. But then the handshake: if valid_in and ready_in are asserted, then data is transferred and register becomes empty. But if valid_in is asserted and ready_in is not asserted, then register remains holding data. And ready_out should be 0 in that case because the register is not ready to accept new data. So ready_out = !data_present maybe.
  
  But the spec says: "The module should implement a ready-valid handshake protocol:
     - Input signals: valid_in, ready_in.
     - Output signals: valid_out, ready_out."
  And "Use an internal memory register (mem) to store the input data. Track the validity of the stored data using a flag (data_present). On reset, clear the stored data and validity flag. Maintain current data until downstream logic indicates readiness to accept it (ready_in)."
  
  So logic for register:
     always @(posedge clk or posedge rst) begin
         if (rst) begin
             mem <= 4'b0;
             data_present <= 0;
         end else begin
             if (valid_in && ready_in) begin
                 mem <= data_in;
                 data_present <= 1;
             end
             if (valid_in && ready_in) begin
                 data_present <= 0; // when data is accepted, clear valid flag
             end
         end
     end
     
  But careful: The handshake: When valid_in is high and ready_in is high, then data is accepted and register becomes empty. But if valid_in is high and ready_in is low, then register holds data. But then valid_out should be high, and ready_out should be 0 because it's not ready to accept new data. And if register is empty (data_present==0), then ready_out should be 1.
  
  So we can assign:
     valid_out = data_present;
     ready_out = !data_present;
  
  But wait, that might be problematic if valid_in is high and register is empty, then register will accept data. But if register already has data, then ready_out=0, so even if valid_in is high, new data won't be accepted until downstream is ready. That seems correct.
  
  But consider the handshake: The register's input handshake: valid_in and ready_in both need to be high to transfer data. So the combinational logic can be:
     ready_out = !data_present; (assuming register is ready to accept new data only if it is empty)
     valid_out = data_present.
  
  But then what if valid_in is high and register is empty, then valid_in & ready_out will be 1, so data is accepted and register becomes full.
  
  But then how do we clear data_present after transfer? We need to check handshake condition. So in always block:
     if (rst) begin mem=0; data_present=0; end else begin
         if (valid_in && ready_in) begin
             mem <= data_in;
             data_present <= 1;
         end
         if (valid_in && ready_in) begin
             data_present <= 0;
         end
     end
  But this code is ambiguous because both conditions are the same. We can combine them:
         if (valid_in && ready_in) begin
             mem <= data_in;
             data_present <= 1; // accepted data
         end
         if (valid_in && ready_in) begin
             data_present <= 0;
         end
  But that's not synthesizable because they conflict. We want: if (valid_in && ready_in) then transfer data and clear flag, but how do we know when to clear flag? Usually, the handshake: when valid_in and ready_in are asserted concurrently, then data is transferred and valid_out becomes 0. So we can do:
         if (rst) begin ... end else begin
             if (valid_in && ready_in) begin
                 mem <= data_in;
                 data_present <= 1;
             end
             if (valid_in && ready_in) begin
                 data_present <= 0;
             end
         end
  But that doesn't make sense because both conditions are the same. We need to use non-blocking assignments in sequential always block, but then we need a separate always block for combinational logic. Alternatively, we can do:
         always @(posedge clk or posedge rst) begin
             if (rst) begin
                 mem <= 0;
                 data_present <= 0;
             end else if (valid_in && ready_in) begin
                 mem <= data_in;
                 data_present <= 1;
             end else if (valid_in && ready_in) begin
                 data_present <= 0;
             end
         end
  But that is not possible because the condition is the same.
  
  Let's think: In a typical register, the handshake is: if valid_in is high and ready_in is high, then transfer data, and valid_out becomes low. But in our register, valid_out is just data_present, so when data is accepted, we want to set data_present to 1, but then when downstream is ready, we want to clear it. But the spec says "Maintain current data until downstream logic indicates readiness to accept it (ready_in)". That implies that valid_out remains high until the downstream module asserts ready_in, at which point data is accepted and valid_out becomes low. So the register should capture data on the rising edge if valid_in is high and ready_in is high, but then it should not clear data_present until ready_in is high again? Wait, that doesn't work.
  
  Let's re-read the spec for register:
  "Use an internal memory register (mem) to store the input data.
   Track the validity of the stored data using a flag (data_present).
   On reset, clear the stored data and validity flag.
   Maintain current data until downstream logic indicates readiness to accept it (ready_in)."
  
  So the register holds data when valid_in is high and ready_in is low. And when ready_in becomes high (and valid_in is still high), then data is transferred, and the register becomes empty. So the behavior is:
  - If valid_in is high and ready_in is high, then transfer data: mem gets new data, and data_present becomes 1, and then immediately clear data_present to 0? But then valid_out becomes 0, meaning the register is empty.
  - If valid_in is high and ready_in is low, then data remains in mem and data_present stays 1.
  - If valid_in is low, then data_present becomes 0 regardless? But then if valid_in becomes high later, the register can accept new data.
  
  So the sequential logic for register:
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          mem <= 4'b0;
          data_present <= 0;
      end else begin
          if (valid_in && ready_in) begin
              mem <= data_in;
              data_present <= 1; // capture new data
          end
          if (valid_in && ready_in) begin
              data_present <= 0; // transfer data and clear flag
          end
          // But these two conditions are the same. We need to combine them.
          // Actually, in a handshake, the transfer happens simultaneously. 
          // We can do:
          if (valid_in && ready_in) begin
              mem <= data_in;
              data_present <= 0; // after transfer, register is empty.
          end
          else if (valid_in && !ready_in) begin
              // hold data
              data_present <= 1;
          end
          else begin
              data_present <= 0;
          end
      end
  end
  
  But then, what if valid_in is high and ready_in is high, then we want to capture data and then clear flag? But then the register would be empty immediately, which means the data is transferred to downstream. That makes sense.
  
  So final register always block:
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          mem <= 4'b0;
          data_present <= 0;
      end else begin
          if (valid_in && ready_in) begin
              mem <= data_in;
              data_present <= 0; // transfer and clear
          end else if (valid_in && !ready_in) begin
              // hold data
              data_present <= 1;
          end else begin
              data_present <= 0;
          end
      end
  end
  
  And assign:
  data_out = mem;
  valid_out = data_present;
  ready_out = !data_present; // register is ready to accept new data if empty.
  
  That seems plausible.
  
  Now, skid_buffer module implementation:
  It has a single register (data_reg) and a flag (buffer) that indicates if data is stored.
  
  The behavior: 
  - If i_valid is high and i_ready is high, then pass data through: o_data = i_data, o_valid = i_valid, and buffer flag is cleared.
  - If i_valid is high and i_ready is low, then store the data in data_reg, assert o_valid = 1, and set buffer flag to 1, and assert o_ready = 0 (not ready to accept new data).
  - If i_valid is low, then if buffer flag is set and i_ready is high, then forward the stored data (o_data = data_reg, o_valid = 1) and clear buffer flag, and assert o_ready = 0? But then if i_ready is high, the downstream accepted the buffered data, so then the skid buffer becomes empty and ready to accept new data, so o_ready becomes 1.
  
  Let's design state machine for skid_buffer:
  Inputs: i_valid, i_ready.
  There are two states: empty and full.
  
  Let's denote internal signals:
  reg [3:0] data_reg;
  reg buffer; // indicates if buffer is storing data.
  
  Behavior:
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          data_reg <= 4'b0;
          buffer <= 0;
      end else begin
          if (i_valid && i_ready) begin
              // Accept new data immediately, no buffering.
              data_reg <= i_data;
              buffer <= 0;
          end else if (i_valid && !i_ready && !buffer) begin
              // Downstream not ready, and no data stored, so buffer the data.
              data_reg <= i_data;
              buffer <= 1;
          end else if (buffer && i_ready) begin
              // Downstream now ready, forward buffered data and clear buffer.
              data_reg <= data_reg; // hold
              buffer <= 0;
          end
          // if i_valid is low and no buffering, do nothing.
      end
  end
  
  And combinational outputs:
  o_data = (buffer ? data_reg : i_data) ? Not exactly: if buffer is set, then o_data should be data_reg, else i_data.
  But careful: if i_valid is high and i_ready is high, then we want to pass through i_data. If i_valid is high and i_ready is low and no buffer, then we buffer the data and output the buffered data. If buffer is set and i_ready is high, then output buffered data.
  
  But what if i_valid is low? Then we output the buffered data if buffer is set? Or should we output nothing? The spec says: "The skid buffer should temporarily store incoming data when the downstream module indicates it is not ready." So if no data is coming in, then o_valid should be low, unless there is buffered data waiting to be forwarded? But then if there is buffered data, valid should be high. But if i_valid is low and there is buffered data, then we can forward it if downstream is ready. But if downstream is not ready, then we hold the buffered data.
  
  So the combinational logic:
  o_data = (buffer ? data_reg : i_data) if i_valid is high? But if i_valid is low, then what? 
  We need to consider that the skid buffer may have data stored from a previous cycle even if current i_valid is low. So we need to generate o_valid based on: if (buffer is set) then o_valid = 1, else if (i_valid is high) then o_valid = 1. But what if both are high? Then it's ambiguous. But likely, if i_valid is high and buffer is not set, then o_valid = i_valid. If i_valid is low but buffer is set, then o_valid = 1.
  
  Also, o_ready: if buffer is set, then o_ready should be low because the skid buffer is busy holding data? But if i_valid is high and i_ready is high, then it's ready to accept new data.
  
  Let's design it more clearly:
  
  We have two modes:
  Mode 1: Buffer empty (buffer==0). Then if i_valid is high and i_ready is high, then pass through data, and set buffer to 0. If i_valid is high and i_ready is low, then store data in buffer and set buffer to 1, and output that data.
  Mode 2: Buffer full (buffer==1). Then if i_ready is high, then forward the buffered data and clear the buffer, making it empty. If i_ready is low, then hold the buffered data.
  
  So combinational outputs:
  o_data = (buffer ? data_reg : i_data)   // if buffer is set, use buffered data, else use i_data.
  o_valid = (buffer || i_valid) ? 1'b1 : 1'b0. But wait, if i_valid is high but buffer is set, then that means we are in the process of buffering? But then o_valid should be 1. But then if i_valid is high and buffer is 0, then o_valid = 1. So simply: o_valid = i_valid || buffer.
  
  o_ready: When buffer is set, then o_ready = i_ready? Not exactly: When buffer is set, the skid buffer is busy holding data, so it cannot accept new data until the buffered data is forwarded. So o_ready should be 0 if buffer is set, regardless of i_ready. But if buffer is not set, then o_ready should follow i_ready. But wait, consider: if i_valid is high and i_ready is low, then we buffer data, so o_ready should be 0. If i_valid is low and buffer is not set, then o_ready should be i_ready.
  
  So o_ready = (!buffer) ? i_ready : 1'b0.
  
  But what if i_valid is low and buffer is set? Then o_ready should be 0 because we are holding data.
  
  So final combinational assignments for skid_buffer:
  always @(*) begin
      o_data = (buffer ? data_reg : i_data);
      o_valid = (buffer || i_valid);
      o_ready = (!buffer) ? i_ready : 1'b0;
  end
  
  And sequential always block for skid_buffer:
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          data_reg <= 4'b0;
          buffer <= 0;
      end else begin
          if (i_valid && i_ready && !buffer) begin
              // Pass through new data, buffer remains empty.
              data_reg <= i_data;
              buffer <= 0;
          end else if (i_valid && !i_ready && !buffer) begin
              // Downstream not ready, buffer data.
              data_reg <= i_data;
              buffer <= 1;
          end else if (buffer && i_ready) begin
              // Downstream is ready, forward buffered data and clear buffer.
              // data_reg remains same.
              buffer <= 0;
          end
          // else: no change.
      end
  end
  
  That should work.
  
  Now, implement pipelined_skid_buffer module:
  
  We instantiate skid_buffer skid_0, register reg1, skid_buffer skid_2, register reg3, and connect them as described.
  
  We'll need wires:
  wire [3:0] skid0_data;
  wire skid0_valid;
  wire skid0_o_ready;
  
  wire [3:0] reg1_data;
  wire reg1_valid;
  wire reg1_ready_out;
  
  wire [3:0] skid2_data;
  wire skid2_valid;
  wire skid2_o_ready;
  
  wire [3:0] reg3_data;
  wire reg3_valid;
  wire reg3_ready_out;
  
  And then assign outputs:
  assign data_o = reg3_data;
  assign valid_o = reg3_valid;
  
  And assign pipelined_skid_buffer.ready_o to skid_0.i_ready. But we want to drive that from the module output. We can do: assign ready_o = 1'b1 if skid_0 is empty? But we don't have a signal from skid_0 that tells us if it is empty. We can infer that if skid_0.buffer is 0 then it is empty. But skid_buffer internal signal buffer is not exposed. We could add an output from skid_buffer, but spec doesn't mention that. Alternatively, we can assume that the skid_buffer is always ready to accept new data if it is not buffering. But we can't see that from outside.
  
  But we can simply drive ready_o = 1'b1. But that might not be correct if the first stage is busy. But the spec says: "ready_o: to signal readiness of pipelined register to receive data from upstream blocks." That means that if the first stage is ready to accept data, then ready_o should be high. And since the first stage is skid_buffer, its input ready is i_ready. We can drive that with a combinational logic that checks if skid_buffer is not busy. But since skid_buffer's internal state is not accessible externally, we have to assume that the skid_buffer module itself will assert o_ready when it's not busy. But o_ready is output from skid_buffer, not i_ready.
  
  The typical handshake: upstream drives valid_i and expects ready_o. ready_o should be high if the pipeline can accept new data. The pipeline can accept new data if the first stage is ready. And the first stage's input ready is i_ready. We can connect ready_o to 1 if skid_buffer is not busy. But how do we know if skid_buffer is not busy? We could add an output from skid_buffer that indicates if it is empty. But spec doesn't mention that.
  
  Alternatively, we can assume that the skid_buffer module always accepts new data if there's no backpressure. But in our skid_buffer implementation, o_ready is determined by (!buffer) ? i_ready : 0. So if buffer is 0, then o_ready equals i_ready. And i_ready is input to skid_buffer. But in our pipelined module, we want to drive skid_buffer's i_ready with ready_o. So we can simply assign ready_o = 1'b1. But that might be incorrect if the first stage is busy.
  
  However, the pipeline's readiness to accept new data is determined by the first stage's input ready, which is connected to pipelined_skid_buffer.ready_o. So we want ready_o to reflect whether skid_buffer is empty. But we don't have an output from skid_buffer for that. We could modify skid_buffer to have an output "empty" that is high when buffer is 0. But spec doesn't mention that.
  
  Given the constraints, I think we can assume that the pipelined_skid_buffer.ready_o is simply tied to 1, because the first stage (skid_buffer) will internally handle backpressure. But that doesn't seem right.
  
  Alternatively, we can assume that the skid_buffer module's input i_ready is simply driven by the pipelined module's ready_o, and we can set ready_o = 1 if no data is being buffered. But since we don't have a signal from skid_buffer, we can assume that the skid_buffer module is combinational and its i_ready is not used. But i_ready is an input to skid_buffer, so we can drive it externally.
  
  We could drive ready_o = 1'b1 always, but then the skid_buffer would always accept new data if i_valid is high. But that might break the handshake if the downstream is not ready. But the purpose of skid_buffer is to buffer data when downstream is not ready. So if ready_o is always high, then the skid_buffer will never buffer data because it will always pass through. But that's not desired.
  
  We want ready_o to be 1 only if the first stage (skid_buffer) is not busy. The busy condition is when buffer flag is set. But since we don't expose that, we can assume that if the skid_buffer's output o_ready is high, then it is ready to accept new data. But o_ready is an output of skid_buffer, not an input. We want to drive skid_buffer's input i_ready. We can use the fact that in a valid/ready handshake, the receiver's ready signal is generated by the receiver. So for the first stage, the receiver is the pipelined_skid_buffer itself. So we want to generate ready_o such that if the first stage (skid_buffer) is not busy, then ready_o is high. But how do we know if the first stage is not busy? We could infer it from the fact that if skid_buffer's internal buffer is not set, then it is ready. But since we don't have that signal, we might assume that the skid_buffer module always asserts o_ready when it is ready to accept new data. But that o_ready is not available to the pipelined module because it's an output of skid_buffer.
  
  Alternatively, we can instantiate skid_buffer and then use its o_ready as the indicator of whether it is ready to accept new data. But in our instantiation, we already used skid_buffer's o_ready to drive reg1.ready_in. So we could also assign ready_o = skid_buffer0.o_ready, but that is an output of skid_buffer. But then the pipelined module's ready_o would be the same as skid_buffer's o_ready. But then the upstream module would drive valid_i and expect ready_o to be high if the pipeline can accept data. That seems reasonable.
  
  So we can do: assign ready_o = skid0_o_ready. But careful: skid0_o_ready is the output of skid_buffer0, but that signal is used as input to reg1. But we can use it as well for ready_o. That might be acceptable.
  
  So in pipelined_skid_buffer, we do:
  assign ready_o = skid0_o_ready;  // from first stage skid_buffer.
  
  And then instantiate the modules:
  
  skid_buffer skid_0 (
      .clk(clock),
      .reset(rst),
      .i_data(data_i),
      .i_valid(valid_i),
      .i_ready(ready_o),   // connect pipelined_skid_buffer.ready_o to skid_buffer's i_ready
      .o_data(skid0_data),
      .o_valid(skid0_valid),
      .o_ready(skid0_o_ready)
  );
  
  register reg1 (
      .clk(clock),
      .rst(rst),
      .data_in(skid0_data),
      .valid_in(skid0_valid),
      .ready_in(skid0_o_ready), // or should it be reg1_ready_in? Let's re-read: Stage 1 output o_ready goes to stage 2 input ready_in.
      .data_out(reg1_data),
      .valid_out(reg1_valid),
      .ready_out(reg1_ready_out)
  );
  
  skid_buffer skid_2 (
      .clk(clock),
      .reset(rst),
      .i_data(reg1_data),
      .i_valid(reg1_valid),
      .i_ready(reg1_ready_out), // connect reg1.ready_out to skid_buffer2.i_ready
      .o_data(skid2_data),
      .o_valid(skid2_valid),
      .o_ready(skid2_o_ready)
  );
  
  register reg3 (
      .clk(clock),
      .rst(rst),
      .data_in(skid2_data),
      .valid_in(skid2_valid),
      .ready_in(ready_i), // connect pipelined_skid_buffer.ready_i to reg3.ready_in
      .data_out(reg3_data),
      .valid_out(reg3_valid),
      .ready_out(reg3_ready_out)
  );
  
  assign data_o = reg3_data;
  assign valid_o = reg3_valid;
  
  And that's it.
  
  But wait, check the handshake for register: In register, we have:
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          mem <= 4'b0;
          data_present <= 0;
      end else begin
          if (valid_in && ready_in) begin
              mem <= data_in;
              data_present <= 1;
          end
          if (valid_in && ready_in) begin
              data_present <= 0;
          end
          else if (valid_in && !ready_in) begin
              data_present <= 1;
          end
          else begin
              data_present <= 0;
          end
      end
  end
  
  But as discussed, the two conditions for valid_in && ready_in conflict. We want to do:
  if (rst) ... else begin
      if (valid_in && ready_in) begin
          mem <= data_in;
          // transfer data: then clear data_present
          data_present <= 0;
      end else if (valid_in && !ready_in) begin
          // hold data
          data_present <= 1;
      end else begin
          data_present <= 0;
      end
  end
  
  That should work.
  
  And assign ready_out = !data_present.
  
  For skid_buffer, we already designed the sequential logic.
  
  Let's now write the final code in a single file "rtl/pipelined_skid_buffer.sv" with three modules: pipelined_skid_buffer, register, skid_buffer.
  
  I'll produce the final code in plain text.

  
  Let's produce the code:

  
  We'll start with the pipelined_skid_buffer module:

  module pipelined_skid_buffer(
      input wire clock,
      input wire rst,
      input wire [3:0] data_i,
      input wire valid_i,
      output wire ready_o,
      output wire valid_o,
      output wire [3:0] data_o,
      input wire ready_i
  );
  
  // Internal wires for pipelined stages
  wire [3:0] skid0_data;
  wire skid0_valid;
  wire skid0_o_ready;
  
  wire [3:0] reg1_data;
  wire reg1_valid;
  wire reg1_ready_out;
  
  wire [3:0] skid2_data;
  wire skid2_valid;
  wire skid2_o_ready;
  
  wire [3:0] reg3_data;
  wire reg3_valid;
  wire reg3_ready_out;
  
  // Instantiate skid_buffer stage 0
  skid_buffer skid_0 (
      .clk(clock),
      .reset(rst),
      .i_data(data_i),
      .i_valid(valid_i),
      .i_ready(ready_o),   // pipelined module's ready_o drives skid_buffer's input ready
      .o_data(skid0_data),
      .o_valid(skid0_valid),
      .o_ready(skid0_o_ready)
  );
  
  // Instantiate register stage 1
  register reg1 (
      .clk(clock),
      .rst(rst),
      .data_in(skid0_data),
      .valid_in(skid0_valid),
      .ready_in(skid0_o_ready),  // stage 1 output ready drives stage 2 input ready
      .data_out(reg1_data),
      .valid_out(reg1_valid),
      .ready_out(reg1_ready_out)
  );