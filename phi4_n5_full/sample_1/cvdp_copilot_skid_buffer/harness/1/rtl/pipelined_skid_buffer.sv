modules: pipelined_skid_buffer, register, skid_buffer. We have specifications. We need to produce one answer with a plain text answer that includes the code in file: "rtl/pipelined_skid_buffer.sv". The code should be "synthesizable" and must implement the logic as described. 

Let's break down the requirements.

We have three modules:

- pipelined_skid_buffer
- register
- skid_buffer

We need to complete the modules in the provided template. The code should be SystemVerilog code that is synthesizable. We have to put each module's code. We need to include the three modules.

The design specification for pipelined_skid_buffer is:

"Complete the module named pipelined_skid_buffer in System Verilog. The module should meet the specifications below."

The pipelined system includes:
- Input skid buffer (skid_0) for data input and initial buffering.
- A register (reg1) to store and forward data after the first buffer.
- A second skid buffer (skid_2) for intermediate buffering.
- Another register (reg3) at the end to finalize the data pipeline.

We have interface signals:
Inputs: clock, rst, data_i[3:0], valid_i, ready_i.
Outputs: data_o[3:0], valid_o, ready_o.

The design: The pipelined buffer system is comprised of skid_0, reg1, skid_2, reg3 in series.

Let's think: The pipelined structure is: data_i goes into skid_0, then output of skid_0 goes to reg1, then output of reg1 goes to skid_2, then output of skid_2 goes to reg3. Then final outputs are from reg3. But careful: Actually, the description says: "An input skid buffer (skid_0) for data input and initial buffering. A register (reg1) to store and forward data after the first buffer. A second skid buffer (skid_2) for intermediate buffering. Another register (reg3) at the end to finalize the data pipeline."

Wait, but then we have the interface signals: valid_i, ready_i, etc. 
We need to connect these modules.

The design should be pipelined. We can assume the following connections:
- pipelined_skid_buffer instantiates skid_buffer skid_0 with inputs: clock, reset, i_data = data_i, i_valid = valid_i, i_ready = ready_i (or maybe not, wait, input ready_i is downstream ready signal, but we want to connect ready_i to skid_0's i_ready? Let's re-read: "Input signals: ready_i: to indicate downstream readiness." The description of pipelined_skid_buffer says that the module receives ready_i and valid_i. The outputs: ready_o, valid_o, and data_o.

I assume the pipeline structure: 
- skid_0: input skid buffer. It takes data_i, valid_i, and its output is connected to reg1's input.
- reg1: register module that takes data from skid_0 and outputs data to skid_2.
- skid_2: second skid buffer, takes data from reg1 and outputs to reg3.
- reg3: register module that takes data from skid_2 and outputs to final outputs.

We need to define the signals connecting them. We have to instantiate each module with appropriate connections.

We need to handle the handshake signals.

For skid_buffer module:
- Input: clk, reset, i_data, i_valid, i_ready.
- Output: o_data, o_valid, o_ready.
- It uses an internal register "data_reg", and a "buffer" flag. 
- When i_ready is high, it should forward input data directly to output if valid. When i_ready is low, it should store the data in internal register and set valid flag accordingly. When i_ready becomes high, then the stored data is forwarded and the flag cleared.
- I need to implement a skid buffer. Let's design its behavior:
  
  skid_buffer:
  
  We have an internal register "data_reg" (4 bits) and a "buffer" flag. 
  Let's define signals: reg [3:0] data_reg; reg buffer; reg o_valid.

  At each clock, if reset is high, then clear data_reg and buffer. Else, if i_valid and not buffer, then if i_ready is high then simply pass the input data and clear buffer, else if i_ready is low then store the input data in data_reg and set buffer flag. But careful: Actually, the specification says: "Temporarily store incoming data when the downstream module indicates it is not ready (i_ready is low). Forward data directly to the output when no buffering is required." So if i_valid is high and i_ready is high, then data is forwarded, and no buffering is needed. If i_ready is low, then store the data in data_reg and set buffer flag. Also, if there is already data buffered (buffer flag high), and i_ready is high, then output the buffered data and clear buffer flag. But what if both i_valid and buffered data are present? Which one has priority? Usually, skid buffer: if input is valid and ready is low, then store input. If there is already buffered data, then that buffered data is output if ready is high, otherwise remain stored. But then what about new input? The new input can be stored if there is space. But the specification says "Use a single register to temporarily store data", so it can only store one word. So if there's already data stored, then new incoming data may be overwritten if i_ready is low? But then that would cause data loss. We need to handle back pressure properly. Typically, a skid buffer only stores one word. If there is already one word stored and new data arrives when ready is low, then we have a conflict. But the spec says "Ensure that no data is lost when the downstream module is not ready to receive data." With a single register, we cannot store two words concurrently. So the skid buffer must be used only to buffer a single word. But then if the buffer is already full, then new data should be dropped? But the spec says "Ensure that no data is lost." That is contradictory: if the buffer is full, you cannot store new data. But maybe the idea is that if the buffer is full, then the input is not accepted (back pressure) i.e., the skid buffer is not accepting new data if the downstream module is not ready and there is already data stored. So, in that case, o_ready should be low. 
  So behavior:
  
  For skid_buffer:
  - if reset then clear data_reg, buffer flag, and o_valid = 0, and o_ready = 1 maybe.
  - if not reset, then:
    if (i_valid) then:
      if (i_ready) then: 
         if (buffer flag is set) then: output buffered data, clear buffer flag, and set o_valid = 1.
         else: forward input data, i.e., o_data = i_data, o_valid = 1, and do not store anything.
      else (i_ready is low):
         if (buffer flag is not set) then: store i_data in data_reg, set buffer flag, and set o_valid = 1.
         else: if buffer flag is set then: hold buffered data, and do not accept new data, so output remains same? But then should we set o_ready = 0? 
         But then what to do with new input if buffer is full? We need to drop the new input. But then we must not update o_valid. But then the buffered data is still valid. 
    else (if not i_valid) then:
      if (buffer flag is set and i_ready is high) then: output buffered data, clear buffer flag, and set o_valid = 1.
      else: no new data. And then if i_ready is high and no buffered data then we can accept new data. So o_ready is 1 if not busy.
  
  But we need to decide o_ready signal for skid_buffer. The spec says: "output: o_ready: indicates that the skid buffer is ready to accept new input data." So o_ready is high if the skid buffer is not busy (i.e., not currently storing a value) or if it's not back-pressuring. But if there is buffered data, then it might be ready to accept new data if the downstream is ready? But then if downstream is not ready, we cannot accept new data because we risk losing it. 
  Let's define: if buffer flag is high, then o_ready should be 0 because it's busy. But if buffer flag is low, then o_ready should be 1 if input valid is high? But wait, but then if input valid is high and i_ready is low, then we accept the new data, store it, and set buffer flag high, and output valid. But if input valid is high and i_ready is low and buffer flag is already high, then we cannot accept new data, so o_ready should be 0.
  
  So, logic for o_ready:
  - if buffer flag is set, then o_ready = 0 always, because we are already holding data.
  - if buffer flag is not set, then o_ready = 1. But wait, check: if i_valid is high and i_ready is low, then we accept input, but then o_ready should be 0 after storing because buffer becomes set. But the o_ready output should be combinational output representing if the module is ready to accept new input at the current cycle. So we can compute o_ready as ~buffer.
  
  So o_ready = ~buffer.
  
  For o_valid:
  - If there is a buffered value, then o_valid = 1.
  - Else if input is valid and i_ready is high, then output valid = 1.
  
  But careful: if input is valid and i_ready is low, then we store the data and set o_valid = 1. But then if there is already buffered data, we ignore new input.
  
  Also, if no buffered data and no input, then o_valid = 0.
  
  Let's design state machine:
  - On reset, data_reg = 0, buffer = 0, o_valid = 0.
  - On rising edge of clk:
     if reset:
         data_reg <= 0; buffer <= 0; o_valid <= 0;
     else:
         if (i_valid) begin
            if (~buffer) begin
               if (i_ready) begin
                  // Accept input directly, no buffering needed.
                  // o_data = i_data.
                  buffer <= 0;
                  o_valid <= 1; // valid output from current input
               end else begin
                  // i_ready is low, so store input in buffer.
                  data_reg <= i_data;
                  buffer <= 1;
                  o_valid <= 1;
               end
            end else begin
               // buffer is already set, so cannot accept new input.
               // if downstream is ready, then output the buffered data.
               if (i_ready) begin
                  o_valid <= 1; // output buffered data
                  buffer <= 0; // clear buffer after forwarding
               end else begin
                  // keep buffered data, o_valid remains 1.
                  o_valid <= 1;
               end
            end
         end else begin
            // no new input
            if (buffer) begin
               if (i_ready) begin
                  // Output buffered data.
                  o_valid <= 1;
                  buffer <= 0;
               end else begin
                  // hold buffered data, o_valid remains 1.
                  o_valid <= 1;
               end
            end else begin
               o_valid <= 0;
            end
         end
         
         // assign o_data: if buffered then data_reg, else if input accepted directly then i_data? But i_data is not available on clock edge because it's synchronous. 
         // Actually, we can't store i_data in a register if we forward directly. But we can simply output i_data if i_valid and i_ready and not buffered.
         // But i_data is available at clock edge? In synchronous design, input signals are registered at clock edge.
         // So, if i_valid and ~buffer and i_ready then output i_data. But if buffer is set, then output data_reg.
         // But what if i_valid is high but i_ready is low and buffer is not set, then we stored data_reg = i_data. So output data_reg.
         // So, assign: if (buffer) then o_data = data_reg; else if (i_valid and i_ready) then o_data = i_data; else if (i_valid and not i_ready) then o_data = i_data; but then we stored it, so output data_reg.
         // Actually, we can simply assign: if (buffer) then o_data = data_reg; else if (i_valid) then o_data = i_data; else 'b0.
         // But careful: if i_valid and not i_ready, we stored data_reg = i_data, so buffer is set, so o_data = data_reg.
         // So, simply assign: o_data = (buffer) ? data_reg : i_data, but if not i_valid then i_data is undefined. But if not i_valid, then o_data should be data_reg if buffer is set, else 0.
         // So, we can do: assign o_data = (buffer) ? data_reg : (i_valid ? i_data : 4'b0);
         // But then if i_valid is false and buffer is false, then o_data = 0, which is fine.
         // But what if i_valid is false but buffer is true? Then o_data = data_reg.
         // We'll do that.
         // However, we have a combinational assignment outside always block. But we can't assign o_data inside always block because it's output.
         // We can use an assign statement for o_data, but then it will use the current values of i_data and buffer. But note that i_data is registered on clock edge. So it's safe.
         // But then, if i_valid and i_ready are used, then i_data is the value on the clock edge. That is acceptable.
         // We'll use a combinational assign outside always block.
         // But careful: We need to update o_data accordingly. But since i_data is registered at clock edge, it's fine.
         // We'll do: assign o_data = (buffer) ? data_reg : (i_valid ? i_data : 4'b0);
         // But this assignment is combinational, but data_reg is updated on clock edge. So it's okay.
         // So, we'll do that.
         // Also, assign o_ready = ~buffer.
         // We'll do that as well.
         // We can do combinational assignments for o_data and o_ready outside always block.
         // But then, in always block, we update data_reg and buffer, but o_data uses data_reg which is updated in clock cycle.
         // So it's fine.
         // We'll do that.
         // We'll do: assign o_data = (buffer) ? data_reg : (i_valid ? i_data : 4'b0);
         // and assign o_ready = ~buffer;
         // We already have them as output wires.
         // So we can declare internal reg for data_reg and buffer and o_valid, then assign outputs.
         // We'll implement that in the module.
         // End of always block.
         // So I'll write the code accordingly.
         // End always block.
         // End module.
         // End of skid_buffer.
         // I'll implement it in always block.
         // End.
         // Actually, I'll write the code accordingly.
  
         // End always block.
         // End module.
  
  We'll need to code skid_buffer module with a clocked always block for updating data_reg and buffer and o_valid. And we'll use assign for o_data and o_ready.
  
  Let's plan the skid_buffer module code:

  module skid_buffer(
    input clk,
    input reset,
    input [3:0] i_data,
    input i_valid,
    output o_ready,
    output [3:0] o_data,
    output o_valid,
    input i_ready
  );
  
  // internal registers
  reg [3:0] data_reg;
  reg buffer; // indicates if there is buffered data
  reg o_valid_reg; // internal valid flag
  
  // assign outputs
  assign o_data = (buffer) ? data_reg : (i_valid ? i_data : 4'b0);
  assign o_ready = ~buffer;
  assign o_valid = o_valid_reg;
  
  always @(posedge clk or posedge reset) begin
      if (reset) begin
          data_reg <= 4'b0;
          buffer <= 1'b0;
          o_valid_reg <= 1'b0;
      end else begin
          if (i_valid) begin
              if (~buffer) begin
                  if (i_ready) begin
                      // accept input directly, no buffering
                      data_reg <= i_data; // not really used, but assign
                      buffer <= 1'b0;
                      o_valid_reg <= 1'b1;
                  end else begin
                      // store input in buffer
                      data_reg <= i_data;
                      buffer <= 1'b1;
                      o_valid_reg <= 1'b1;
                  end
              end else begin
                  // buffer already has data, cannot accept new input
                  if (i_ready) begin
                      // forward buffered data
                      o_valid_reg <= 1'b1;
                      buffer <= 1'b0;
                  end else begin
                      // hold buffered data
                      o_valid_reg <= 1'b1;
                  end
              end
          end else begin
              if (buffer) begin
                  if (i_ready) begin
                      // forward buffered data
                      o_valid_reg <= 1'b1;
                      buffer <= 1'b0;
                  end else begin
                      // hold buffered data
                      o_valid_reg <= 1'b1;
                  end
              end else begin
                  o_valid_reg <= 1'b0;
              end
          end
      end
  end
  
  endmodule

  That should suffice for skid_buffer.

  Next, the register module:
  
  Requirements: The register module has interface:
  Inputs: clk, rst, data_in, valid_in.
  Outputs: data_out, valid_out, ready_out.
  Also, input ready_in.
  
  Behavior:
  - On reset, clear stored data and validity flag.
  - When valid_in is high and ready_in is high, then store data_in in mem and mark valid_out high.
  - When valid_out is high and ready_in is high, then output data and clear valid flag.
  - When ready_in is high but valid_in is low, then ready_out is high.
  
  But the handshake: The register should store input data when valid_in is high and ready_in is high, and then output valid_out. But then if ready_in is high, then data is accepted and valid_out is cleared.
  
  Actually, typical register:
  
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          mem <= 4'b0;
          valid_reg <= 1'b0;
      end else begin
          if (valid_in && ready_in) begin
              mem <= data_in;
              valid_reg <= 1'b1;
          end else if (valid_reg && ready_in) begin
              // data is forwarded, valid_reg remains? Actually, register should hold data until ready_in is high.
              // But if ready_in is high, then we output the stored data and clear valid flag.
              valid_reg <= 1'b0;
          end
      end
  end
  
  But careful: The handshake protocol: valid_in and ready_in handshake means that if valid_in is high and ready_in is high, then the register should capture the data. Then valid_out should be high until downstream indicates readiness (ready_in high) to accept the data. But the spec says: "Maintain current data until downstream logic indicates readiness to accept it (ready_in)." 
  So the register: if valid_in is high, then store data_in in mem, and set valid_out. Then on next cycle, if ready_in is high, then valid_out goes low. But also, if ready_in is low, then valid_out remains high.
  
  But also, if valid_in is low, then if valid_out is high and ready_in is high, then valid_out goes low.
  
  Also, ready_out is simply the inverse of valid_reg? Not exactly, because ready_out indicates that the register is ready to accept new input. But in a pipeline register, ready_out is typically high if the register is not currently holding valid data. So ready_out = ~valid_reg.
  
  So, code for register:
  
  module register(
      input clk,
      input rst,
      input [3:0] data_in,
      input valid_in,
      output ready_out,
      output valid_out,
      output [3:0] data_out,
      input ready_in
  );
  
  reg [3:0] mem;
  reg valid_reg;
  
  assign data_out = mem;
  assign valid_out = valid_reg;
  assign ready_out = ~valid_reg; // ready to accept new input if not holding valid data
  
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          mem <= 4'b0;
          valid_reg <= 1'b0;
      end else begin
          if (valid_in && ready_in) begin
              mem <= data_in;
              valid_reg <= 1'b1;
          end else if (valid_reg && ready_in) begin
              // data has been accepted by downstream, clear valid flag
              valid_reg <= 1'b0;
          end
      end
  end
  
  endmodule