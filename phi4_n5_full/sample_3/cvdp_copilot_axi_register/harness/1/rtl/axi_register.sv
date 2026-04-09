<think>We are given a specification for a SystemVerilog module named axi_register implementing configurable AXI4-Lite Slave interface for controlling and monitoring specific hardware registers. The module should implement the following registers:
- Beat counter: 20-bit counter. It is read and write.
- Start signal: single-bit control.
- Done status: single-bit flag (read and write, but description says read and write? Actually specification says it is read and write, but then in functional description says done signal: clears done_i if LSB is 1, but description says "Done Status: Single-bit flag indicating the completion of a hardware task" so it's read and write? But then "Write Transactions" says: "Done Signal: Clears done_i internally if LSB is 1, effectively resetting the done status in the module's logic." But then the register map: "Done" is at offset 0x300 with read/write access. So it's read and write, but read value is from done_i? But then specification says "done_i" is an input that indicates that a hardware task has been completed to be reflected in the status register. But then in functional description "Write Transactions" says "Done Signal: Clears done_i internally if the LSB is 1" so it's a register that can be written to to clear the done status? Actually, let's re-read description:

The module has following outputs:
- beat_o: 20-bit beat counter.
- start_o: single-bit control signal triggered via AXI write.
- writeback_o: single-bit control signal to trigger a writeback operation, also set via AXI.

The register map:
Beat: offset 0x100, 20-bit
Start: offset 0x200, 1-bit
Done: offset 0x300, 1-bit (but note: it's read-write, but then description says "done_i" is input that indicates that a hardware task has been completed, to be reflected in the status register. So perhaps "done" register is read from "done_i" (maybe a register that holds the done status)? But then "Write Transactions" says "Done Signal: Clears done_i internally if the LSB is 1, effectively resetting the done status in the module's logic." So that is contradictory? Possibly the Done register is a mirror of done_i except that when written with 1, it resets done status? But then "done_i" is an input, not output. So maybe the module has an internal register "done" that is updated by the input "done_i" (like a latch) and then can be cleared by a write to the register? But the functional description says: "done_i: indicates that a hardware task has been completed, to be reflected in the status register." So maybe the register "done" is driven by done_i? But then write transactions says "Done Signal: Clears done_i internally if the LSB is 1, effectively resetting the done status in the module's logic." So possibly the done register is read from done_i when not reset, but if a write with LSB=1 is performed, then we clear the done register, i.e., we set done=0. However, then "read" operations: "Done Signal: Returns the status of done_i (e.g., 1 if the hardware task is done, 0 otherwise)." So we need to implement a register "done" that holds the value of done_i, but can be cleared by a write if LSB is 1. But then what if done_i is high? Then the register remains high. But then "done" is not updated on the clock? Actually, description: "done_i" is an input and is used to reflect the status in the module's logic. So I think we have an internal register done_reg that is updated by the input done_i (maybe using an asynchronous set or synchronous set) and can be cleared by a write operation when wdata_i[0] is 1 and the corresponding byte is enabled. But the specification says: "The module uses the lower bits of wdata_i to determine the target register, then updates the corresponding outputs:" For Done Signal: "Clears done_i internally if the least significant bit is 1". That implies that if the register is written with 1, then we clear the done signal. But then in read transactions, "Done Signal: Returns the status of done_i (e.g., 1 if the hardware task is done, 0 otherwise)". So maybe the internal done register is set by the input done_i and can be cleared by a write to the register. But if done_i is an input, then its value might be coming asynchronously. But specification: "done_i: indicates that a hardware task has been completed, to be reflected in the status register." So maybe the register "done" is a combination of input done_i and write clearing? But wait, "done_i" is also an input to the module. So the module has an input "done_i". The register map shows Done at offset 0x300. But then functional description "Write Transactions" says: "Done Signal: Clears done_i internally if the LSB is 1, effectively resetting the done status in the module's logic." So I think the module has an internal register, let's call it done_reg, that is updated on write (if write to Done register with LSB=1, then done_reg becomes 0, otherwise it remains the same) but also maybe updated by the input done_i? But then in read transaction: "Done Signal: Returns the status of done_i (e.g., 1 if the hardware task is done, 0 otherwise)". So perhaps the register done is simply assigned to the input done_i? But then how do we clear it? Possibly the write transaction for Done register overrides the internal register with 0 if the LSB is 1. But if done_i is not used to update done register? Alternatively, maybe done register is implemented as a register that is set to done_i value when a write occurs? But then when done_i is high, if no write occurs, then the register remains high. But then the write transaction "Done Signal: Clears done_i internally if the LSB is 1" implies that if the write is done with LSB 1, then we clear the register regardless of done_i. So maybe we need an internal register for done that is updated by done_i asynchronously? But then that doesn't match the "AXI4-Lite protocol" which is synchronous. We can do a synchronous update of done_reg from done_i. But then if a write transaction occurs, if the register address is Done (0x300) and the LSB of wdata_i is 1, then we clear done_reg. But what if wdata_i is 0? Then do nothing. But then what if done_i is asserted externally? We need to update done_reg with done_i when not in a write transaction? But then that would be asynchronous? But then the spec says "done_i: indicates that a hardware task has been completed, to be reflected in the status register." So maybe the module has an internal register that latches done_i, and then if a write to done register with LSB=1 occurs, then we clear that register. But then how do we update it? Possibly we can use a separate register update logic: if not writing to done register, then done_reg <= done_i. But that is asynchronous? But we can do it in always_ff block triggered by posedge clk, and if reset, done_reg=0. And then on every clock cycle, if not in a write transaction, done_reg <= done_i, but if in a write transaction to done register and the LSB is 1, then done_reg <= 0. But then if wdata_i has LSB 0, then do nothing? But then that might override done_i? But specification "Done Signal: Clears done_i internally if the LSB is 1" suggests that if LSB=1, then we clear the done status, regardless of done_i. But then if done_i is asserted, the register should show 1? But then if a write occurs with 1, then it clears it to 0. But then if done_i is high after that, then the register will not update because it is in a write transaction? But then maybe we need separate registers for each control signal.

Let's list registers:
- Beat: 20 bits, writeable, read value from beat_reg (default 0)
- Start: 1 bit, writeable, read value from start_reg (default 0)
- Done: 1 bit, read/write. But functional description: "Done Signal: Clears done_i internally if the LSB is 1" So maybe it's a register that is updated from done_i except when a write occurs. But then if a write occurs with LSB 1, then it clears the register. But if a write occurs with LSB 0, then do nothing (or maybe update with 0? But then it doesn't matter because it's 0 anyway). But then read returns done_reg.
- Writeback: 1 bit, writeable, read value from writeback_reg (default 0)

Also, there is an ID register at offset 0x500 which is read-only. It has a fixed value, e.g., 32'h00010001 (from example read example, it returns 0x0001_0001). So we define parameter ID_VALUE = 32'h00010001.

The module interface includes:
Inputs:
- clk_i, rst_n_i (active low asynchronous reset)
- awaddr_i [ADDR_WIDTH-1:0]
- awvalid_i
- wdata_i [DATA_WIDTH-1:0]
- wvalid_i
- wstrb_i [(DATA_WIDTH/8)-1:0]
- bready_i
- araddr_i [ADDR_WIDTH-1:0]
- arvalid_i
- rready_i
- done_i (input, single-bit)

Outputs:
- awready_o
- wready_o
- bresp_o [1:0]
- bvalid_o
- arready_o
- rdata_o [DATA_WIDTH-1:0]
- rvalid_o
- rresp_o [1:0]
- beat_o [19:0]
- start_o
- writeback_o

Note: The outputs beat_o, start_o, writeback_o are directly assigned to internal registers. But the specification says: "Reflects the current value of the beat counter, configured via AXI writes." So beat_o is the internal beat register, which is 20 bits. But the AXI data bus is 32 bits, so we need to pad beat register to 32 bits when writing and reading. Similarly, start and writeback are 1 bit registers, so they must be placed in a 32-bit bus, possibly in the LSB of rdata_o when reading from those registers.

We need to implement AXI handshake. We'll implement state machines for write and read transactions. But we can implement simple combinational logic for a simple slave? But careful: AXI protocol: There is address phase and data phase. We need to support backpressure. But the specification is not trivial because we need to support both write and read transactions concurrently? But typical AXI4-Lite slave is simple: no pipelining, single transaction at a time. But the spec says: "only respond with the RTL code translated from the specification." So we need to generate SystemVerilog code for axi_register.

I will implement a simple AXI4-Lite slave. We'll have a state machine for write and read transactions. However, the specification doesn't require pipelining. We can implement simple combinational logic with registers to hold address and data.

I can implement two state machines: one for write transactions and one for read transactions. But we can also implement a simpler one if we assume no concurrent transactions. But the AXI4-Lite protocol usually supports concurrent transactions if the slave supports it. But since it's a simple register interface, we can assume that only one transaction is active at a time.

I can have two separate registers: write_addr, write_data, write_valid, read_addr, read_valid, etc.

Plan:
Define parameters: ADDR_WIDTH=32, DATA_WIDTH=32 (default values, but they are parameters).
Define localparam for register addresses: Beat register offset 16'h100, Start offset 16'h200, Done offset 16'h300, Writeback offset 16'h400, ID register offset 16'h500. But note: The specification uses hex addresses like 0x100, 0x200, etc. But these addresses are in bytes. So I'll use them as constants: localparam integer BEAT_ADDR = 16'h100; localparam integer START_ADDR = 16'h200; localparam integer DONE_ADDR = 16'h300; localparam integer WB_ADDR = 16'h400; localparam integer ID_ADDR = 16'h500.

But then the module should decode addresses: if (address matches one of these) then perform operation.

I need to implement handshake signals:
For write:
- awready_o is asserted when not busy writing.
- wready_o is asserted when not busy writing data.
- bvalid_o is asserted after write completion.
- bresp_o is 2'b00 for OKAY, 2'b10 for SLVERR.

For read:
- arready_o is asserted when not busy reading.
- rvalid_o is asserted after read completion.
- rresp_o is 2'b00 for OKAY, 2'b10 for SLVERR.

I can implement simple state machines. But the spec does not require pipelined transactions, so I can use a simple combinational logic: if (awvalid_i and not busy) then capture awaddr_i, etc. But AXI protocol is synchronous. I'll implement always_ff @(posedge clk_i or negedge rst_n_i) blocks for registers.

I'll have registers for write transaction state:
- reg [ADDR_WIDTH-1:0] axi_awaddr_reg;
- reg axi_awvalid_reg;
- reg axi_wready_reg;
- reg axi_bvalid_reg;
- reg [1:0] axi_bresp_reg;

Similarly, for read:
- reg [ADDR_WIDTH-1:0] axi_araddr_reg;
- reg axi_arvalid_reg;
- reg axi_rvalid_reg;
- reg [DATA_WIDTH-1:0] axi_rdata_reg;
- reg [1:0] axi_rresp_reg;

We need to implement logic to capture write address when awvalid_i and not busy.
We need to capture write data when wvalid_i and ready.

We need to implement handshake signals:
- awready_o: assigned to 1 if not busy with write address.
- wready_o: assigned to 1 if not busy with write data.
- bvalid_o: assigned to axi_bvalid_reg.
- bresp_o: assigned to axi_bresp_reg.
- arready_o: assigned to 1 if not busy with read address.
- rvalid_o: assigned to axi_rvalid_reg.
- rdata_o: assigned to axi_rdata_reg.
- rresp_o: assigned to axi_rresp_reg.

We need to update internal registers for beat, start, done, writeback.
We define:
- reg [19:0] beat_reg;
- reg start_reg;
- reg done_reg; // for done signal, but need to combine done_i and write transaction
- reg writeback_reg;

For the done register, we need to update from done_i when not writing? But the specification says: "Done Signal: Clears done_i internally if the LSB is 1." Possibly the logic is: if a write transaction to DONE register occurs with LSB=1, then done_reg <= 0, otherwise if no write transaction, then done_reg <= done_i? But that might cause glitch. Alternatively, we can treat done register as a mirror of done_i, but then a write transaction can override it. But the specification is ambiguous. It says: "Done Status: Single-bit flag indicating the completion of a hardware task." and "done_i: Indicates that a hardware task has been completed, to be reflected in the status register." So maybe done_reg is updated with done_i on every clock cycle. But then write transaction "Clears done_i internally if the LSB is 1" means that if a write occurs with LSB=1, then done_reg is cleared regardless of done_i. But then if done_i remains high externally, then done_reg would be high unless a write occurs. But then read returns done_reg. So I'll implement: always_ff @(posedge clk_i or negedge rst_n_i) begin if(!rst_n_i) done_reg <= 0; else if (write transaction to DONE register with LSB==1) then done_reg <= 0; else done_reg <= done_i; end

But wait, we must consider that write transaction may be concurrent with done_i update. But we can assume that write transaction is atomic. But if a write occurs, then we update done_reg accordingly. But what if a write occurs and the data is not 1? The spec says "Clears done_i internally if the LSB is 1" so if the LSB is 1, then clear done. If not, then leave it as is? But then how do we set done? The register is read/write, but the spec doesn't mention setting done to 1 via write. It only mentions clearing it. So I'll implement: if (write transaction to DONE register and wdata_i[0] is 1) then done_reg <= 0; else done_reg <= done_i.

But then what about the other registers? Beat, start, writeback registers: They are updated only on write transactions. But note: The spec says "Beat counter: A 20-bit counter that can be set and read by the AXI master." So when writing to Beat register, we update beat_reg with lower 20 bits of wdata_i, and assign beat_o = beat_reg.
For Start: when writing to Start register, if LSB of wdata_i is 1 and corresponding byte is enabled, then start_o <= 1. But also, perhaps we want to latch the value? But the spec says "Start Signal: A single-bit control signal to trigger a hardware operation." So if written, then set start_o to 1? But then maybe it should be latched until reset? But specification doesn't mention clearing start signal. So I'll implement: if a write occurs to Start register, then start_reg <= wdata_i[0] (if byte is enabled). But we need to check wstrb_i for the least significant byte. But since DATA_WIDTH=32, wstrb_i is 4 bits. The least significant byte is bit0 of wstrb_i. So condition: if (wstrb_i[0] is asserted) then update start_reg with wdata_i[0].
For Writeback: similar: if write occurs to Writeback register, then writeback_reg <= wdata_i[0] if wstrb_i[0] is asserted.
For Beat: update beat_reg with wdata_i[19:0] if write occurs to Beat register, if full write (wstrb_i all ones) or partial write is allowed? Specification says: if partial write (not all bytes enabled) then acknowledge the write without modifying the register. So if not all bytes are enabled, then do not update beat_reg. But which bytes? The beat register is 20 bits, so it occupies lower 20 bits of the 32-bit word. But the specification says: "if full write, then update, if partial write, then do not modify." But then what is considered full write? It says: "If wvalid_i is asserted and all bits in wstrb_i are set (indicating that all bytes in wdata_i are valid), then update." But if not all bits are set, then do not update. But wstrb_i is DATA_WIDTH/8 bits, so for 32-bit data, that's 4 bytes. But the beat register is 20 bits, which spans 3 bytes (20 bits) but not exactly aligned to byte boundaries? Actually, 20 bits means 20/8 = 2.5 bytes. But the specification likely expects that the beat register is located at offset 0x100 and occupies bits [19:0] of the word. But then the write strobe should cover the lower 3 bytes? But the spec says "if all bits in wstrb_i are set", but that doesn't make sense because wstrb_i is 4 bits for 32-bit data. We want to check if the byte enables for the bytes that are part of the register are set. But the register is 20 bits, so it might span bytes 0, 1, and 2. But then we need to check wstrb_i[0], wstrb_i[1], and wstrb_i[2]. But then what about the upper 4 bits? Possibly ignore them. But specification says "if all bits in wstrb_i are set", but that's ambiguous. It might be a simplification: if (wstrb_i == {DATA_WIDTH/8{1'b1}}) then perform complete update. But that would mean if DATA_WIDTH=32 then check if wstrb_i == 4'b1111. But that would update a 32-bit register. But our register is only 20 bits. So maybe we check if (wstrb_i[0] and wstrb_i[1] and wstrb_i[2]) are set, then update beat_reg with lower 20 bits of wdata_i, else do nothing.
I can do: if ((wstrb_i[0] && wstrb_i[1] && wstrb_i[2]) == 3'b111) then update beat_reg with wdata_i[19:0]. But note: if wstrb_i is not full, then do not update beat_reg.
For Start and Writeback registers, they are 1 bit registers. They are located at offset 0x200 and 0x400 respectively. They are 32-bit words, but only bit0 is used. So we check if wstrb_i[0] is asserted. And for Done register at offset 0x300, similarly, check if wstrb_i[0] is asserted.
For ID register at offset 0x500, any write attempt should generate error response.

Now, how to implement handshake:
I can use simple combinational logic with registers that capture the address and data. But careful: AXI4-Lite protocol: 
For write:
- When awvalid_i is high and axi_awready is high, capture awaddr_i.
- Then assert wready when not busy.
- When wvalid_i is high and axi_wready is high, capture wdata_i and wstrb_i, and perform register update.
- Then assert bvalid with response.
- bready_i is used to clear bvalid.
For read:
- When arvalid_i is high and axi_arready is high, capture araddr_i.
- Then assert rvalid with the read data.
- rready_i is used to clear rvalid.

I can implement separate always_ff blocks for write and read transactions. But I need to consider that we can have a write transaction and a read transaction concurrently. But the specification doesn't mention pipelined transactions. But AXI4-Lite protocol is usually simple. I can assume no concurrent transactions.

I can implement a simple FSM that handles either a write or read transaction. But the simplest approach is to implement separate combinational logic for write and read.

I can use registers:
For write:
- reg [ADDR_WIDTH-1:0] axi_awaddr_reg;
- reg axi_awvalid_reg;
- reg axi_wready_reg;
- reg axi_bvalid_reg;
- reg [1:0] axi_bresp_reg;

For read:
- reg [ADDR_WIDTH-1:0] axi_araddr_reg;
- reg axi_arvalid_reg;
- reg axi_rvalid_reg;
- reg [DATA_WIDTH-1:0] axi_rdata_reg;
- reg [1:0] axi_rresp_reg;

I can implement them as follows:
always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    axi_awaddr_reg <= 0;
    axi_awvalid_reg <= 0;
    axi_wready_reg <= 0;
    axi_bvalid_reg <= 0;
    axi_bresp_reg <= 2'b00;
    axi_araddr_reg <= 0;
    axi_arvalid_reg <= 0;
    axi_rvalid_reg <= 0;
    axi_rdata_reg <= 0;
    axi_rresp_reg <= 2'b00;
  end else begin
    // Write address phase
    if (awvalid_i && axi_awready) begin
      axi_awaddr_reg <= awaddr_i;
      axi_awvalid_reg <= 0;
    end
    // Write data phase
    if (wvalid_i && axi_wready) begin
      // perform register update based on axi_awaddr_reg
      case (axi_awaddr_reg)
        BEAT_ADDR: begin
          if ((wstrb_i[0] && wstrb_i[1] && wstrb_i[2]) == 3'b111) begin
            beat_reg <= wdata_i[19:0];
          end
          // else do nothing
        end
        START_ADDR: begin
          if (wstrb_i[0]) begin
            start_reg <= wdata_i[0];
          end
        end
        DONE_ADDR: begin
          if (wstrb_i[0]) begin
            // if LSB is 1, clear done_reg, else leave it
            if (wdata_i[0] == 1'b1)
              done_reg <= 1'b0;
            // else do nothing
          end
        end
        WB_ADDR: begin
          if (wstrb_i[0]) begin
            writeback_reg <= wdata_i[0];
          end
        end
        ID_ADDR: begin
          // Write to ID register is not allowed, generate error response.
          // Do not update any register.
        end
        default: begin
          // Invalid address, do nothing.
        end
      endcase
      axi_wready_reg <= 0;
      // Generate write response
      axi_bvalid_reg <= 1;
      // Determine response: OKAY if valid register, SLVERR if invalid write (e.g., ID register write or invalid address)
      if (axi_awaddr_reg == ID_ADDR) begin
         axi_bresp_reg <= 2'b10; // SLVERR
      end else if (axi_awaddr_reg != BEAT_ADDR && axi_awaddr_reg != START_ADDR && axi_awaddr_reg != DONE_ADDR && axi_awaddr_reg != WB_ADDR) begin
         axi_bresp_reg <= 2'b10; // SLVERR for invalid address
      end else begin
         axi_bresp_reg <= 2'b00; // OKAY
      end
    end else begin
      // If not in write data phase, ensure wready is high if not busy.
      axi_wready_reg <= 1; // default
    end

    // Completion of write transaction
    if (bready_i && axi_bvalid_reg) begin
      axi_bvalid_reg <= 0;
    end

    // Read address phase
    if (arvalid_i && axi_arready) begin
      axi_araddr_reg <= araddr_i;
      axi_arvalid_reg <= 0;
    end

    // Read data phase
    if (axi_arvalid_reg) begin
      axi_rvalid_reg <= 1;
      // Determine read data based on axi_araddr_reg
      case (axi_araddr_reg)
        BEAT_ADDR: begin
          // beat_reg is 20 bits, need to pad to 32 bits: lower 20 bits = beat_reg, upper 12 bits = 0
          axi_rdata_reg <= {12'b0, beat_reg};
        end
        START_ADDR: begin
          axi_rdata_reg <= {31'b0, start_reg};
        end
        DONE_ADDR: begin
          axi_rdata_reg <= {31'b0, done_reg};
        end
        WB_ADDR: begin
          axi_rdata_reg <= {31'b0, writeback_reg};
        end
        ID_ADDR: begin
          axi_rdata_reg <= 32'h00010001; // fixed ID value
        end
        default: begin
          axi_rdata_reg <= 32'h0;
          axi_rresp_reg <= 2'b10; // SLVERR for invalid address
        end
      endcase
    end else begin
      axi_rvalid_reg <= 0;
    end

    // Completion of read transaction
    if (rready_i && axi_rvalid_reg) begin
      axi_rvalid_reg <= 0;
    end
  end
end

But we need to assign axi_awready and axi_arready signals. They are outputs.
We can assign:
assign axi_awready = (!axi_awvalid_reg) ? 1'b1 : 0; but careful: axi_awvalid_reg is a register that holds previous cycle's value. But we want to assert axi_awready when not busy with a write transaction. We can simply assign axi_awready = ~axi_awvalid_reg, but that might be not correct because axi_awvalid_reg is updated only when a write transaction begins. Alternatively, we can have a flag that indicates if a write transaction is ongoing. But I can simply use: assign awready_o = (axi_awvalid_reg == 0) ? 1'b1 : 1'b0;
But then for wready, we want to assert when not busy. We can assign: assign wready_o = (axi_wready_reg == 0) ? 1'b1 : 1'b0; But careful: axi_wready_reg is a register that is set to 0 when busy. But we can also simply assign: assign wready_o = !axi_wready_reg; But then in always_ff, we set axi_wready_reg <= 0 when busy, and then assign it to 1 otherwise. But our code above sets axi_wready_reg <= 1 in the else clause. So that's fine.

Similarly, assign arready_o = !axi_arvalid_reg? But axi_arvalid_reg is a register that holds previous cycle's value. Alternatively, we can use a flag for read transaction. But I'll do similar: assign arready_o = !axi_arvalid_reg.

But careful: axi_arvalid_reg is set to 0 when not busy. So that's fine.

Now, the handshake signals for write response bvalid_o and read response rvalid_o are already in registers axi_bvalid_reg and axi_rvalid_reg.

I need to define outputs:
assign awready_o = !axi_awvalid_reg; // but axi_awvalid_reg is a register, so maybe it's better to have a separate flag.
But I can do: assign awready_o = ~axi_awvalid_reg; But axi_awvalid_reg is a reg that is set to 0 after capturing address. So that's fine.
Similarly, assign wready_o = ~axi_wready_reg;
assign bvalid_o = axi_bvalid_reg;
assign bresp_o = axi_bresp_reg;
assign arready_o = ~axi_arvalid_reg;
assign rvalid_o = axi_rvalid_reg;
assign rdata_o = axi_rdata_reg;
assign rresp_o = axi_rresp_reg;

Also, beat_o = beat_reg, start_o = start_reg, writeback_o = writeback_reg.

We also need to update internal registers for beat, start, done, writeback. I'll declare them as regs:
reg [19:0] beat_reg;
reg start_reg;
reg done_reg;
reg writeback_reg;

We need to update them in the always_ff block for write data phase. But note: The always_ff block above is combining write and read transactions. But then we need to update beat_reg, start_reg, done_reg, writeback_reg accordingly. But careful: the always_ff block for write data phase is inside the same always_ff block that handles both read and write. But we must ensure that write transactions update the registers only once. But since we are in one always_ff block, it's sequential. But the ordering: if (wvalid_i && axi_wready) then update registers. But note: axi_wready is a register that we set to 0 when busy and then 1 when not busy. But we set axi_wready_reg <= 1 in the else clause of the if (wvalid_i && axi_wready) block. But then if we are in a write transaction, then axi_wready_reg remains 0 until the transaction completes. That is fine.

I need to check the condition for full write for Beat register: if ((wstrb_i[0] && wstrb_i[1] && wstrb_i[2]) == 3'b111) then update beat_reg. But note: wstrb_i is an input vector. I can do: if (wstrb_i[0] && wstrb_i[1] && wstrb_i[2]) then update beat_reg. But what if wstrb_i is not full (i.e., not all bits set)? Then do nothing.
But what about registers that are 1 bit? For them, we only need wstrb_i[0] to be asserted.

I also need to generate error response for invalid address writes. For Done, Beat, Start, WB, these are valid. For ID, error.
For any address not equal to these, error.

Now, what about read transactions? In the always_ff block, when arvalid_i && axi_arready, we capture axi_araddr_reg. But axi_arready is not a register but an output assignment. But we need to assign axi_arready, but then use it in always_ff block. I can declare a reg for axi_arready_reg as well. But simpler: I can implement axi_arready as combinational: assign arready_o = 1'b1 if not busy with read transaction. But how do we know if busy? We can use axi_arvalid_reg. But axi_arvalid_reg is a register that holds previous cycle's value. So if axi_arvalid_reg is 0, then we are not busy. So assign arready_o = ~axi_arvalid_reg. But then in always_ff block, when arvalid_i is high and axi_arready is high, we capture address. But axi_arready is combinational. But then we need to use it in always_ff block. I can do: if (arvalid_i && ~axi_arvalid_reg) then capture address. But then set axi_arvalid_reg <= 1.
But then when rready_i is high and axi_rvalid_reg is high, then clear axi_rvalid_reg.

I need to define registers: axi_awvalid_reg, axi_wready_reg, axi_bvalid_reg, axi_bresp_reg, axi_araddr_reg, axi_arvalid_reg, axi_rvalid_reg, axi_rdata_reg, axi_rresp_reg.

I can do it in one always_ff block triggered by posedge clk_i or negedge rst_n_i.

I need to decide the ordering: First, handle write address phase, then write data phase, then completion of write transaction, then handle read address phase, then read data phase, then completion of read transaction.

I worry about concurrent transactions. But since it's AXI4-Lite, it's typically single transaction at a time.

I can structure the always_ff block as follows:

always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    axi_awaddr_reg <= 0;
    axi_awvalid_reg <= 0;
    axi_wready_reg <= 0;
    axi_bvalid_reg <= 0;
    axi_bresp_reg <= 2'b00;
    axi_araddr_reg <= 0;
    axi_arvalid_reg <= 0;
    axi_rvalid_reg <= 0;
    axi_rdata_reg <= 0;
    axi_rresp_reg <= 2'b00;
    beat_reg <= 20'b0;
    start_reg <= 1'b0;
    done_reg <= 1'b0;
    writeback_reg <= 1'b0;
  end else begin
    // Write address phase
    if (awvalid_i && !axi_awvalid_reg) begin
      axi_awaddr_reg <= awaddr_i;
      axi_awvalid_reg <= 1;
    end else begin
      axi_awvalid_reg <= 0;
    end

    // Write data phase
    if (wvalid_i && !axi_wready_reg) begin
      // capture write data and update registers based on axi_awaddr_reg
      case (axi_awaddr_reg)
        BEAT_ADDR: begin
          // Check full write condition: need wstrb_i for bytes 0,1,2
          if (wstrb_i[0] && wstrb_i[1] && wstrb_i[2])
            beat_reg <= wdata_i[19:0];
        end
        START_ADDR: begin
          if (wstrb_i[0])
            start_reg <= wdata_i[0];
        end
        DONE_ADDR: begin
          if (wstrb_i[0]) begin
            if (wdata_i[0] == 1'b1)
              done_reg <= 1'b0;
          end
        end
        WB_ADDR: begin
          if (wstrb_i[0])
            writeback_reg <= wdata_i[0];
        end
        ID_ADDR: begin
          // Attempt to write to ID register, generate error later.
        end
        default: begin
          // Invalid address, do nothing.
        end
      endcase
      axi_wready_reg <= 1;
      // Generate write response
      axi_bvalid_reg <= 1;
      if (axi_awaddr_reg == ID_ADDR) begin
         axi_bresp_reg <= 2'b10; // SLVERR
      end else if (axi_awaddr_reg != BEAT_ADDR && axi_awaddr_reg != START_ADDR && axi_awaddr_reg != DONE_ADDR && axi_awaddr_reg != WB_ADDR) begin
         axi_bresp_reg <= 2'b10; // SLVERR for invalid address
      end else begin
         axi_bresp_reg <= 2'b00; // OKAY
      end
    end else begin
      axi_wready_reg <= 0;
    end

    // Completion of write transaction
    if (bready_i && axi_bvalid_reg)
      axi_bvalid_reg <= 0;

    // Read address phase
    if (arvalid_i && !axi_arvalid_reg) begin
      axi_araddr_reg <= araddr_i;
      axi_arvalid_reg <= 1;
    end else begin
      axi_arvalid_reg <= 0;
    end

    // Read data phase
    if (axi_arvalid_reg) begin
      axi_rvalid_reg <= 1;
      case (axi_araddr_reg)
        BEAT_ADDR: begin
          axi_rdata_reg <= {12'b0, beat_reg};
        end
        START_ADDR: begin
          axi_rdata_reg <= {31'b0, start_reg};
        end
        DONE_ADDR: begin
          axi_rdata_reg <= {31'b0, done_reg};
        end
        WB_ADDR: begin
          axi_rdata_reg <= {31'b0, writeback_reg};
        end
        ID_ADDR: begin
          axi_rdata_reg <= 32'h00010001;
        end
        default: begin
          axi_rdata_reg <= 32'h0;
          axi_rresp_reg <= 2'b10;
        end
      endcase
    end else begin
      axi_rvalid_reg <= 0;
    end

    // Completion of read transaction
    if (rready_i && axi_rvalid_reg)
      axi_rvalid_reg <= 0;
  end
end

But there's a problem: The handshake signals for write address phase: I want to assert awready_o when not busy. But my code above sets axi_awvalid_reg to 1 when capturing address, but then resets it to 0 in the else clause. But then how do we know if a transaction is ongoing? I think I need separate flags for "write transaction active" and "read transaction active". For simplicity, I can assume that transactions are not pipelined and that only one transaction is active at a time.

I can use combinational assignments:
assign awready_o = ~axi_awvalid_reg;
assign wready_o = ~axi_wready_reg;
assign arready_o = ~axi_arvalid_reg;
assign bvalid_o = axi_bvalid_reg;
assign bresp_o = axi_bresp_reg;
assign rvalid_o = axi_rvalid_reg;
assign rdata_o = axi_rdata_reg;
assign rresp_o = axi_rresp_reg;

But then what are axi_awvalid_reg, axi_wready_reg, axi_arvalid_reg? They are registers that indicate if a transaction is ongoing. I can initialize them to 0. Then in write address phase, if (awvalid_i && !axi_awvalid_reg) then capture address and set axi_awvalid_reg = 1, and then clear it after capturing. But then in write data phase, if (wvalid_i && !axi_wready_reg) then process data and set axi_wready_reg = 1, then clear it after processing. But then axi_awvalid_reg and axi_wready_reg are used to generate ready signals. But then in the always_ff block, I need to update them appropriately.

Maybe I'll define separate registers for write transaction state:
reg write_active;
reg [ADDR_WIDTH-1:0] awaddr_reg;
reg [DATA_WIDTH-1:0] wdata_reg;
reg [ (DATA_WIDTH/8)-1:0] wstrb_reg;

Then in always_ff block:
if (awvalid_i && !write_active) begin
  awaddr_reg <= awaddr_i;
  write_active <= 1;
end else if (wvalid_i && write_active) begin
  // process write data using awaddr_reg
  case (awaddr_reg)
    ...
  endcase
  write_active <= 0;
end
assign awready_o = !write_active;
assign wready_o = write_active; // because we want to accept write data when active.
But then bvalid_o is asserted after write data phase, and then cleared when bready_i is high.

Similarly, for read transaction, I can define a flag read_active, and registers for araddr_reg.
But then the code becomes simpler.

I think I'll implement two separate always_ff blocks: one for write transactions and one for read transactions, using simple handshake logic.

For write transactions:
reg write_active;
reg [ADDR_WIDTH-1:0] awaddr_reg;
reg [DATA_WIDTH-1:0] wdata_reg;
reg [ (DATA_WIDTH/8)-1:0] wstrb_reg;
reg bvalid_reg;
reg [1:0] bresp_reg;

always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    write_active <= 0;
    bvalid_reg <= 0;
    bresp_reg <= 2'b00;
  end else begin
    // Address phase
    if (awvalid_i && !write_active) begin
      awaddr_reg <= awaddr_i;
      write_active <= 1;
    end
    // Data phase
    if (wvalid_i && write_active) begin
      wdata_reg <= wdata_i;
      wstrb_reg <= wstrb_i;
      // Process write based on awaddr_reg
      case (awaddr_reg)
        BEAT_ADDR: begin
          if (wstrb_reg[0] && wstrb_reg[1] && wstrb_reg[2])
            beat_reg <= wdata_reg[19:0];
        end
        START_ADDR: begin
          if (wstrb_reg[0])
            start_reg <= wdata_reg[0];
        end
        DONE_ADDR: begin
          if (wstrb_reg[0]) begin
            if (wdata_reg[0] == 1'b1)
              done_reg <= 1'b0;
          end
        end
        WB_ADDR: begin
          if (wstrb_reg[0])
            writeback_reg <= wdata_reg[0];
        end
        ID_ADDR: begin
          // Do nothing, will generate error response.
        end
        default: begin
          // Invalid address, do nothing.
        end
      endcase
      bvalid_reg <= 1;
      if (awaddr_reg == ID_ADDR)
         bresp_reg <= 2'b10;
      else if (awaddr_reg != BEAT_ADDR && awaddr_reg != START_ADDR && awaddr_reg != DONE_ADDR && awaddr_reg != WB_ADDR)
         bresp_reg <= 2'b10;
      else
         bresp_reg <= 2'b00;
      write_active <= 0;
    end
    // Completion phase for write
    if (bready_i && bvalid_reg)
      bvalid_reg <= 0;
  end
end

For read transactions:
reg read_active;
reg [ADDR_WIDTH-1:0] araddr_reg;
reg rvalid_reg;
reg [DATA_WIDTH-1:0] rdata_reg;
reg [1:0] rresp_reg;

always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i) begin
    read_active <= 0;
    rvalid_reg <= 0;
    rresp_reg <= 2'b00;
  end else begin
    // Address phase
    if (arvalid_i && !read_active) begin
      araddr_reg <= araddr_i;
      read_active <= 1;
    end
    // Data phase
    if (read_active) begin
      rvalid_reg <= 1;
      case (araddr_reg)
        BEAT_ADDR: begin
          rdata_reg <= {12'b0, beat_reg};
        end
        START_ADDR: begin
          rdata_reg <= {31'b0, start_reg};
        end
        DONE_ADDR: begin
          rdata_reg <= {31'b0, done_reg};
        end
        WB_ADDR: begin
          rdata_reg <= {31'b0, writeback_reg};
        end
        ID_ADDR: begin
          rdata_reg <= 32'h00010001;
        end
        default: begin
          rdata_reg <= 32'h0;
          rresp_reg <= 2'b10;
        end
      endcase
    end else begin
      rvalid_reg <= 0;
    end
    // Completion phase for read
    if (rready_i && rvalid_reg)
      rvalid_reg <= 0;
  end
end

Now, assign output signals:
assign awready_o = !write_active;
assign wready_o = write_active; // because we accept write data only when active.
assign bvalid_o = bvalid_reg;
assign bresp_o = bresp_reg;

assign arready_o = !read_active;
assign rvalid_o = rvalid_reg;
assign rdata_o = rdata_reg;
assign rresp_o = rresp_reg;

And assign beat_o = beat_reg, start_o = start_reg, writeback_o = writeback_reg.

For done_reg update, we also need to update it with done_i when not writing? But specification: "done_i: indicates that a hardware task has been completed, to be reflected in the status register." So I can update done_reg every clock cycle if not in a write transaction. But then if a write transaction occurs and clears done, that takes precedence. But what if a write transaction occurs concurrently with done_i? The spec says: "Clears done_i internally if the LSB is 1." That implies that if a write occurs to the DONE register with LSB=1, then done_reg becomes 0. Otherwise, done_reg should reflect done_i. So I can do: if (!write_active && !read_active) then done_reg <= done_i; But careful: if a write transaction is in progress, we don't update done_reg from done_i. But what if there is no transaction? Then update done_reg with done_i.
I can add in a always_ff block for done_reg update:
always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i)
    done_reg <= 1'b0;
  else if (!write_active && !read_active)
    done_reg <= done_i;
end
But wait, if a write transaction occurs to DONE register, we want to clear done_reg if wdata_i[0] is 1. But that is already handled in the write transaction block. But then if no transaction occurs, then done_reg should follow done_i. But what if done_i changes while a transaction is ongoing? The specification isn't clear. I assume that done_reg is updated only when not busy with a transaction. I'll implement that.

So I'll add:
always_ff @(posedge clk_i or negedge rst_n_i) begin
  if (!rst_n_i)
    done_reg <= 1'b0;
  else if (!write_active && !read_active)
    done_reg <= done_i;
end

But careful: There's a potential race if both write and read transactions are not active. That is fine.

Now, what about beat_reg, start_reg, writeback_reg? They are updated only in write transaction block. And they are registered, so they hold their values.

Now, check parameter defaults: ADDR_WIDTH=32, DATA_WIDTH=32. And localparam addresses:
localparam BEAT_ADDR = 16'h100;
localparam START_ADDR = 16'h200;
localparam DONE_ADDR = 16'h300;
localparam WB_ADDR = 16'h400;
localparam ID_ADDR = 16'h500;

I need to declare these as localparams inside the module.

I also need to declare module parameters: parameter ADDR_WIDTH = 32, parameter DATA_WIDTH = 32.

Now, I'll write the complete SystemVerilog module code in plain text, without JSON formatting, and ensure that the file name is rtl/axi_register.sv.

I'll produce the code as plain text.

I'll now produce the code in plain text:

```
module axi_register #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic                   clk_i,
  input  logic                   rst_n_i,
  input  logic [ADDR_WIDTH-1:0]  awaddr_i,
  input  logic                   awvalid_i,
  input  logic [DATA_WIDTH-1:0]  wdata_i,
  input  logic                   wvalid_i,
  input  logic [(DATA_WIDTH/8)-1:0] wstrb_i,
  input  logic                   bready_i,
  input  logic [ADDR_WIDTH-1:0]  araddr_i,
  input  logic                   arvalid_i,
  input  logic                   rready_i,
  input  logic                   done_i,
  output logic                   awready_o,
  output logic                   wready_o,
  output logic [1:0]             bresp_o,
  output logic                   bvalid_o,
  output logic                   arready_o,
  output logic [DATA_WIDTH-1:0]  rdata_o,
  output logic                   rvalid_o,
  output logic [1:0]             rresp_o,
  output logic [19:0]            beat_o,
  output logic                   start_o,
  output logic                   writeback_o
);

  // Local parameters for register addresses
  localparam logic [15:0] BEAT_ADDR  = 16'h100;
  localparam logic [15:0] START_ADDR = 16'h200;
  localparam logic [15:0] DONE_ADDR  = 16'h300;
  localparam logic [15:0] WB_ADDR    = 16'h400;
  localparam logic [15:0] ID_ADDR    = 16'h500;

  // Internal registers for AXI write transaction
  reg write_active;
  reg [ADDR_WIDTH-1:0] awaddr_reg;
  reg [DATA_WIDTH-1:0] wdata_reg;
  reg [(DATA_WIDTH/8)-1:0] wstrb_reg;
  reg bvalid_reg;
  reg [1:0] bresp_reg;

  // Internal registers for AXI read transaction
  reg read_active;
  reg [ADDR_WIDTH-1:0] araddr_reg;
  reg rvalid_reg;
  reg [DATA_WIDTH-1:0] rdata_reg;
  reg [1:0] rresp_reg;

  // Internal registers for application logic
  reg [19:0] beat_reg;
  reg start_reg;
  reg done_reg;
  reg writeback_reg;

  // AXI Write Transaction Logic
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      write_active <= 1'b0;
      bvalid_reg   <= 1'b0;
      bresp_reg    <= 2'b00;
    end else begin
      // Address Phase: Capture address if not busy
      if (awvalid_i && !write_active) begin
        awaddr_reg <= awaddr_i;
        write_active <= 1'b1;
      end

      // Data Phase: Process write data if active
      if (wvalid_i && write_active) begin
        wdata_reg <= wdata_i;
        wstrb_reg <= wstrb_i;
        case (awaddr_reg)
          BEAT_ADDR: begin
            // Full write condition: check if lower 3 bytes are enabled
            if (wstrb_reg[0] && wstrb_reg[1] && wstrb_reg[2])
              beat_reg <= wdata_reg[19:0];
          end
          START_ADDR: begin
            if (wstrb_reg[0])
              start_reg <= wdata_reg[0];
          end
          DONE_ADDR: begin
            if (wstrb_reg[0]) begin
              if (wdata_reg[0] == 1'b1)
                done_reg <= 1'b0;
            end
          end
          WB_ADDR: begin
            if (wstrb_reg[0])
              writeback_reg <= wdata_reg[0];
          end
          ID_ADDR: begin
            // Attempt to write to read-only ID register; do nothing.
          end
          default: begin
            // Invalid address; no update.
          end
        endcase
        bvalid_reg <= 1'b1;
        // Set response: OKAY for valid registers, SLVERR for ID or invalid address
        if (awaddr_reg == ID_ADDR)
          bresp_reg <= 2'b10; // SLVERR
        else if (awaddr_reg != BEAT_ADDR && awaddr_reg != START_ADDR &&
                 awaddr_reg != DONE_ADDR && awaddr_reg != WB_ADDR)
          bresp_reg <= 2'b10; // SLVERR for invalid address
        else
          bresp_reg <= 2'b00; // OKAY
        write_active <= 1'b0;
      end

      // Completion Phase: Clear write response when master acknowledges
      if (bready_i && bvalid_reg)
        bvalid_reg <= 1'b0;
    end
  end

  // AXI Read Transaction Logic
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      read_active <= 1'b0;