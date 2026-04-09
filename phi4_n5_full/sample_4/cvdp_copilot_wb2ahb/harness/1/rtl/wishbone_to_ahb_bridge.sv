<think>We have instructions: "You are solving a 'Specification to RTL Translation' problem. To solve this problem correctly, you should only respond with the RTL code translated from the specification." The request: "Design a System Verilog module named `wishbone_to_ahb_bridge`." and then specification details are provided. Our answer must be plain text and saved to file "rtl/wishbone_to_ahb_bridge.sv". We must produce a SystemVerilog module that translates the specification. We must produce plain text. We must produce an RTL file that satisfies the specification.

Let's check the details:

- There's a folder structure: rtl, verif, docs, etc. But we only need to produce the RTL code in file "rtl/wishbone_to_ahb_bridge.sv".

- We need to produce a SystemVerilog module that has two sets of ports: Wishbone ports and AHB ports.

Wishbone Ports (WB Master):

Inputs:
- clk_i: clock for wishbone operations.
- rst_i: active low reset signal.
- cyc_i: valid Wishbone transaction cycle.
- stb_i: strobe signal for valid data on wishbone interface.
- sel_i[3:0]: byte enables selecting which bytes are active.
- we_i: write enable signal.
- addr_i[31:0]: address for Wishbone transaction.
- data_i[31:0]: Write data from wishbone master.

Wishbone Outputs:
- data_o[31:0]: read data back to Wishbone master.
- ack_o: acknowledge signal for wishbone operations.

AHB Ports (from AHB Slave):
- hclk: clock for AHB operations.
- hreset_n: active low reset for the AHB interface.
- hrdata[31:0]: read data from AHB slave.
- hresp[1:0]: AHB response signal.
- hready: indicates when the AHB slave is ready.

AHB Outputs:
- htrans[1:0]: AHB transaction type.
- hsize[2:0]: size of AHB transfer.
- hburst[2:0]: burst type, always single (3'b000).
- hwrite: write enable signal for AHB transactions.
- haddr[31:0]: address for AHB transaction.
- hwdata[31:0]: write data to the AHB slave.

Functional Requirements:
1. Protocol Translation: Translate Wishbone signals to AHB signals.
2. Address Fixing: derive AHB addresses from Wishbone addresses using sel_i.
3. Single Transfer Support: Only single AHB transfers (hburst = 000).
4. Data Handling: perform endian conversion for read and write data between Wishbone and AHB.
5. Control Signals: use an FSM-like approach to manage transaction phases (htrans) including IDLE, NON-SEQUENTIAL, and BUSY states.
6. Pipeline Management: handle data and address phases for AHB transactions with proper synchronization using hready.

Implementation details:
- Endian conversion: convert between Wishbone's little-endian and AHB's data handling. Use sel_i to determine active bytes.
- Signal Holding: hold transaction attributes during AHB operations.
- Reset Behavior: ensure internal registers reset to default when rst_i or hreset_n is asserted.
- Latency: ensure ack_o is only asserted after completing AHB transaction (hready asserted).

Edge Cases:
1. Invalid Byte Selection: handle invalid or conflicting sel_i gracefully.
2. AHB Slave Busy: test when hready is asserted late, stalling the transaction.
3. Back-to-Back Transactions: ensure correct operation when Wishbone initiates new transaction immediately after previous one completes.

Given these, we need to produce a module that implements an FSM that waits for wishbone transaction start, then generates AHB transaction signals accordingly, and then after AHB transaction completes, outputs ack_o and data_o. The module should be parameterizable for configurable data width for byte, halfword, and word-level transactions. But the specification says "provides configurable data width for byte, halfword, and word-level transactions." That means that the AHB transfer size is determined by sel_i. So hsize[2:0] must reflect the transfer size. Typically, in AHB, hsize is 2 bits or 3 bits? Actually, the spec says hsize[2:0] which is 3 bits. The valid sizes for AHB are: Byte (0), Halfword (1), Word (2) maybe. But wait, the spec says "configurable data width for byte, halfword, and word-level transactions." We need to detect which bytes are enabled in sel_i. If sel_i = 4'b0001, then it's a byte transfer. If sel_i = 4'b0011 then it's a halfword transfer, if sel_i = 4'b1111 then it's a word transfer. But also maybe if sel_i is not contiguous, then it's a byte transfer? Actually, in Wishbone, sel_i is the byte enable. For a valid transaction, typically if multiple bytes are enabled, the transfer size is determined by the minimum contiguous block? But specification doesn't specify contiguousness check, it says "use sel_i to determine active bytes in a transfer." We can assume if only one byte enabled then it's a byte transfer. If two bytes enabled then it's halfword transfer, if four bytes enabled then it's word transfer. But what if sel_i is not contiguous? Then maybe we consider it as multiple byte transfers? But the specification says "configurable data width for byte, halfword, and word-level transactions." So we assume that if sel_i bits are contiguous and equal to 2 or 4, then use halfword or word, otherwise use byte transfer. But the specification does not require to check contiguousness? It says "Use sel_i to determine active bytes in a transfer." Possibly we can detect the number of bits set in sel_i, and if it equals 1 then size = 0 (byte), if equals 2 then size = 1 (halfword), if equals 4 then size = 2 (word). But if it's not exactly 1,2, or 4, then we default to byte transfer maybe.

We need to perform endian conversion: Wishbone is little-endian, AHB might be big-endian? The specification says "convert between Wishbone's little-endian and AHB's data handling." So that means if we are reading data from AHB, we need to reverse the byte order if necessary. But it's ambiguous: does AHB assume little-endian? Typically AHB is often big-endian, but not necessarily. But the specification explicitly says "perform endian conversion for read and write data between Wishbone and AHB." That means that when writing, we need to reorder the data from wishbone (which is little-endian) into the order expected by AHB. And when reading, we need to reorder data from AHB to wishbone. So we need a function to convert between little-endian and big-endian. But the specification does not specify which direction. Possibly we can assume that AHB is big-endian. But I'm not 100% sure. However, the specification says "Wishbone's little-endian format" so likely AHB is big-endian. We can assume that conversion is needed. So we need to have a function that does endian conversion: maybe a simple function that swaps bytes: data_in[31:0] to data_out[31:0] = {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]}. But we must consider the sel_i: only selected bytes should be converted. But if sel_i is not all ones, then we only reorder the selected bytes? Possibly we need to combine the data from AHB with Wishbone data if only part of the word is accessed. But then we need to preserve the unselected bytes from previous read. Possibly we need a register that holds the read data that is updated when hready is asserted. We'll design an FSM with states: IDLE, NON_SEQ, BUSY maybe. The FSM transitions: in IDLE, if cyc_i and stb_i are asserted, then capture the wishbone transaction parameters (address, data, sel_i, we_i) and then move to NON_SEQ. In NON_SEQ, wait for hready from AHB slave to become high, then in BUSY state, output ack_o and data_o if it's read transaction. For write transactions, ack_o is asserted when hready is high.

We need to generate htrans[1:0]. The AHB protocol has multiple transaction types: IDLE (00), BUSY (01), NON-SEQ (10) maybe. But the specification says to support SINGLE transfers, so hburst should always be 3'b000. And htrans should be controlled by FSM states: IDLE (00), NON-SEQ (10) maybe, and then maybe BUSY (??). The specification says: "Use an FSM-like approach to manage transaction phases (htrans), including IDLE, NON-SEQUENTIAL, and BUSY states." So we can define states: IDLE, NON_SEQ, BUSY. But then what is htrans? In AHB, htrans is a 2-bit field where 00 is IDLE, 01 is BUSY, 10 is NON_SEQ, and 11 is RESERVED. So we can assign: IDLE: 2'b00, NON_SEQ: 2'b10, BUSY: 2'b01 maybe. But typically in AHB, the transaction phases are: IDLE, BUSY, and NON-SEQ. But the specification says "including IDLE, NON-SEQUENTIAL, and BUSY states." So we can assign: IDLE: htrans = 2'b00, NON_SEQ: htrans = 2'b10, BUSY: htrans = 2'b01.

We need to output hburst always as 3'b000 (SINGLE).

hwrite should reflect we_i. haddr should be derived from addr_i. But also address fixing using sel_i. "Derive AHB-compliant addresses from Wishbone addresses using sel_i." Possibly if sel_i is not all ones, then we need to round the address down to the nearest word boundary. For example, if sel_i is 4'b0001, then address should be aligned to a byte boundary. If sel_i is 4'b0011, then address should be aligned to halfword boundary, if sel_i is 4'b1111 then address is word aligned. So we can compute haddr as addr_i aligned to the size of the transfer. We can do that by taking addr_i[1:0] for byte, addr_i[1:0] for halfword, and addr_i[1:0] for word. For byte, no alignment needed. For halfword, clear bit0, for word, clear bits1:0. So we need to compute hsize based on sel_i: if popcount(sel_i)==1 then hsize = 0 (byte), if popcount(sel_i)==2 then hsize = 1 (halfword), if popcount(sel_i)==4 then hsize = 2 (word). But what if popcount is not 1,2,or4? Then default to byte. But also we need to check contiguousness maybe. But specification doesn't require contiguous check. We can just check number of bits set.

For hdata conversion: When writing, we need to convert data_i from little-endian to big-endian ordering. But if only part of the word is selected, then we need to only swap the bytes that are selected? Or maybe we need to generate a 32-bit word with only the selected bytes swapped? But the specification says "perform endian conversion for read and write data between Wishbone and AHB." So for writes, we need to reorder the bytes of the entire 32-bit word according to the AHB's expected ordering. But if sel_i is not all ones, then we might want to swap only the bytes that are selected, leaving the unselected bytes unchanged. But that might be tricky. Alternatively, we can assume that the conversion function always reorders the entire 32-bit word regardless of sel_i. But then for partial transfers, the unselected bytes might be garbage. But the specification says "Use sel_i to determine active bytes in a transfer." So maybe we need to do something like: for each byte in 0 to 3, if sel_i[i] is high, then the corresponding byte in AHB is the corresponding byte from data_i, but in reversed order? That is, if AHB is big-endian, then AHB's byte 0 is wishbone's byte 3, AHB's byte 1 is wishbone's byte 2, etc. So we can do: if sel_i[0] then hwdata[7:0] = data_i[31:24]; if sel_i[1] then hwdata[15:8] = data_i[23:16]; if sel_i[2] then hwdata[23:16] = data_i[15:8]; if sel_i[3] then hwdata[31:24] = data_i[7:0]. But then for bytes that are not selected, we might leave them as they are or maybe assign zero? But careful: if we are doing a partial write, we must not overwrite unselected bytes that might be valid in a previous transaction? But since it's a single transfer, it's probably safe to assume that unselected bytes are not important. However, the specification says "handle invalid or conflicting sel_i values gracefully." So maybe if sel_i is not contiguous or not equal to 1,2, or 4 bits, then we default to byte access and only swap one byte. But I think it's better to implement a function that does a full conversion for the entire 32 bits, and then mask out the unselected bytes if needed. But if the transfer is partial, then the unselected bytes might be preserved from previous read? But since it's a write transaction, the unselected bytes are not written by the master, so they should be left unchanged. But if we simply perform a full swap, then unselected bytes get overwritten. So we need to do a selective swap: for each byte i, if sel_i[i] is 1, then assign hwdata byte = data_i swapped byte corresponding to the AHB order. For read transactions, we need to do the inverse conversion: if AHB returns data in big-endian order, then convert it to little-endian order for the selected bytes, and leave unselected bytes as they were (or zero them out). But then how do we combine them? We could use a register that holds previous read data and then update only the selected bytes. But then the specification says "Perform endian conversion for read and write data between Wishbone and AHB." So for reads, we need to convert hrdata from big-endian to little-endian for the bytes that are selected. But if only a subset of bytes are selected, then we need to combine them with previous data maybe. But since it's a single transfer, it might be simpler: on a read transaction, when hready is asserted, we capture hrdata, then convert it, and output it on data_o, but only for the bytes that are active. But what about the unselected bytes? Possibly they should be zeroed out or left unchanged. The specification doesn't specify what to do with unselected bytes in a read transaction. I assume we zero them out.

So we need to implement an FSM that on a read transaction, in IDLE state, if cyc_i and stb_i are asserted and we_i is low, then we capture the parameters (address, sel_i) and then output htrans = NON_SEQ, and wait for hready. Once hready is high, we move to BUSY state, then output ack_o and data_o. For write transaction, similar: capture parameters and output htrans = NON_SEQ, wait for hready, then move to BUSY state and output ack_o.

Now, what about hresp? The specification doesn't require to generate hresp. But hresp is input from AHB slave. Possibly we can pass it through to Wishbone read data? But specification doesn't mention hresp usage except that it's an input from AHB slave. So maybe we ignore it.

We also need to handle AHB slave busy: if hready is not asserted, then we must hold the transaction until hready becomes high. So the FSM should wait in NON_SEQ state until hready becomes high.

We need to support back-to-back transactions: once transaction completes, we go back to IDLE state and wait for next cycle.

Now, regarding clock domains: There are two clocks: clk_i for wishbone and hclk for AHB. But in a real design, these might be asynchronous. But specification doesn't mention synchronization between the two clocks. Possibly we assume they are the same clock domain or that wishbone operations are synchronous with hclk. But for safety, we might assume they are the same clock domain. But the specification lists them separately. However, we'll assume they are in the same clock domain for simplicity.

We also need to reset: rst_i is active low for wishbone, and hreset_n is active low for AHB. We need to check both resets.

Plan for the code:

We define parameters for state encoding. Let's define states: localparam IDLE = 2'b00, NON_SEQ = 2'b10, BUSY = 2'b01. We'll create an FSM state register.

We need registers for capturing wishbone transaction parameters: reg [31:0] wb_addr_reg, reg [31:0] wb_data_reg, reg [3:0] wb_sel_reg, reg wb_we_reg. Also maybe a register for hsize_reg.

We need a register for wishbone ack: ack_reg.

We need a register for data output: data_o_reg maybe.

We need to generate htrans, hburst, hwrite, haddr, hwdata, hsize. We'll drive them from state.

We need to compute haddr from wb_addr_reg and alignment based on hsize. For that, we can compute: if hsize==0 then haddr = wb_addr_reg; if hsize==1 then haddr = wb_addr_reg & ~1; if hsize==2 then haddr = wb_addr_reg & ~3.

We need to compute hsize from sel_i: 
   if (|sel_i == 4'b0001) then hsize=0, if (|sel_i == 4'b0011) then hsize=1, if (|sel_i == 4'b1111) then hsize=2, else default 0.

But we need to detect number of bits set. We can use a function or combinational logic.

We need to compute hwdata from wb_data_reg and sel_i. We need to do selective swap:
   For each byte i:
      if sel_i[i] then hwdata[i*8 +:8] = wb_data_reg[(3-i)*8 +:8] 
      else hwdata[i*8 +:8] remains same as previous value? But then what initial value? Possibly 8'b0.
   But careful: if we do it in combinational logic, we need to generate a 32-bit value. We can do something like:
       assign hwdata_temp = { wb_data_reg[31:24], wb_data_reg[23:16], wb_data_reg[15:8], wb_data_reg[7:0] } and then mask with sel_i bits. But that would swap the entire word. But then we need to combine with unselected bytes from previous value if needed. But since this is a write transaction, we are writing new data, so unselected bytes can be zero.

   But wait: if the transaction is partial, then the AHB slave might expect only the selected bytes to be updated, while the unselected bytes remain unchanged. But since it's a single transfer, the AHB slave probably expects the entire word to be written. But if we only write selected bytes, then the unselected bytes might be left unchanged. But the specification says "configure data width for byte, halfword, and word-level transactions." That implies that the transaction size is determined by the number of active bytes. So for a byte transfer, only one byte is written, for a halfword transfer, two bytes are written, for a word transfer, four bytes are written. And the AHB slave expects that hsize and haddr are adjusted accordingly. So then haddr should be word-aligned for word transfer, halfword-aligned for halfword, and no alignment for byte. So in that case, the unselected bytes are not part of the transaction. But then if we swap the entire word, we would be writing data to the unselected bytes as well. So we need to do a selective swap: for each byte i, if sel_i[i] is 1, then assign the swapped byte; if not, then assign 8'b0. But then wait, that would lose any previous value that might be in that location. But since it's a write, we assume it's writing new data, so we can set unselected bytes to zero.

   But what if the AHB slave expects the unselected bytes to remain unchanged? In a partial write, typically the unselected bytes are not touched. But since we are generating a new transaction, the AHB slave should only consider the bytes specified by hsize. However, in AHB, the transfer size hsize tells the slave how many bytes to transfer. The slave should only update those bytes. But our module is generating a 32-bit hwdata, so the slave might use all 32 bits. But if the transfer size is smaller, then the slave should only consider the lower bytes? Actually, in AHB, hsize indicates the transfer size in bytes, so if hsize==0, then the transfer is 1 byte, if hsize==1, then 2 bytes, if hsize==2, then 4 bytes. The AHB slave will only use the lower hsize*8 bits of hwdata, I believe. But that depends on the AHB slave implementation. But for our module, we can assume that we generate the correct hsize and haddr and hwdata such that only the selected bytes are valid, and the rest can be zero.

   So for write: hwdata = { (sel_i[3]? {wb_data_reg[31:24]} : 8'b0), (sel_i[2]? {wb_data_reg[23:16]} : 8'b0), (sel_i[1]? {wb_data_reg[15:8]} : 8'b0), (sel_i[0]? {wb_data_reg[7:0]} : 8'b0) } but note the order: if AHB is big-endian, then the most significant byte of hwdata is the least significant byte of wb_data_reg. So we need to reorder: if sel_i[3] is 1, then hwdata[31:24] = wb_data_reg[7:0]. If sel_i[2] is 1, then hwdata[23:16] = wb_data_reg[15:8]. If sel_i[1] is 1, then hwdata[15:8] = wb_data_reg[23:16]. If sel_i[0] is 1, then hwdata[7:0] = wb_data_reg[31:24].

   But careful: the index in sel_i: typically bit 0 corresponds to lowest address byte, bit 1 to next, etc. But in our conversion, we want to swap: the lowest address byte in AHB is the most significant byte of the data bus. So if sel_i[0] is high, then that means the byte at address offset 0 is being accessed. But in big-endian, that corresponds to hwdata[31:24]. So mapping:
       if sel_i[0] then hwdata[31:24] = wb_data_reg[7:0]
       if sel_i[1] then hwdata[23:16] = wb_data_reg[15:8]
       if sel_i[2] then hwdata[15:8] = wb_data_reg[23:16]
       if sel_i[3] then hwdata[7:0] = wb_data_reg[31:24]

   For read, we need to do the reverse conversion. hrdata is from AHB, which is big-endian. So if sel_i[0] is high, then data_o[31:24] = hrdata[7:0] (the lowest byte of hrdata becomes the most significant byte of wishbone data). Wait, careful: Wishbone is little-endian, so wishbone data_o should have the least significant byte at bit 7:0. But hrdata is big-endian, so hrdata[7:0] is the least significant byte of AHB data. But we need to convert: for read, if sel_i[0] is high, then wishbone data_o[7:0] should be hrdata[7:0] (no swap because it's already in the correct order for the selected byte) OR do we need to swap? Let's re-read: "perform endian conversion for read and write data between Wishbone and AHB." So for writes, we swap the order. For reads, we need to swap back. So for read, the conversion is the inverse of the write conversion. So if sel_i[0] is high, then wishbone data_o[7:0] = hrdata[31:24] (because in write we did: if sel_i[0] then hwdata[7:0] = wb_data_reg[31:24], so for read, if sel_i[0] then data_o[7:0] = hrdata[31:24]). But wait, check: Write mapping: AHB (big-endian) expects the MSB to come from Wishbone LSB. So for write: if sel_i[0] is high, then hwdata[7:0] = wb_data_reg[31:24]. For read: hrdata is big-endian, so hrdata[7:0] is the LSB of AHB, but wishbone expects the LSB to be hrdata[31:24]? Let's derive carefully:
   Wishbone data is little-endian: the least significant byte is at bit 7:0.
   AHB data is big-endian: the most significant byte is at bit 31:24.
   For a write: we want to send wb_data_reg (little-endian) to AHB in big-endian order. That means: AHB byte0 (bit 31:24) should be wb_data_reg[7:0], AHB byte1 (23:16) should be wb_data_reg[15:8], AHB byte2 (15:8) should be wb_data_reg[23:16], AHB byte3 (7:0) should be wb_data_reg[31:24]. But then we only want to send selected bytes. So if sel_i[0] is 1, then hwdata[7:0] = wb_data_reg[31:24]. If sel_i[1] is 1, then hwdata[15:8] = wb_data_reg[23:16]. If sel_i[2] is 1, then hwdata[23:16] = wb_data_reg[15:8]. If sel_i[3] is 1, then hwdata[31:24] = wb_data_reg[7:0].
   For a read: hrdata is coming in big-endian order. So hrdata[31:24] is the first byte of the AHB data, hrdata[23:16] is the second, hrdata[15:8] is the third, hrdata[7:0] is the fourth. We need to convert it back to little-endian order for Wishbone. So if sel_i[3] is 1, then data_o[7:0] = hrdata[31:24] (because in write, if sel_i[3] is 1, then hwdata[31:24] = wb_data_reg[7:0], so invert that: if sel_i[3] is 1, then data_o[7:0] = hrdata[31:24]). Similarly, if sel_i[2] is 1, then data_o[15:8] = hrdata[23:16], if sel_i[1] is 1, then data_o[23:16] = hrdata[15:8], if sel_i[0] is 1, then data_o[31:24] = hrdata[7:0]. But then wait, wishbone data_o is little-endian, so the least significant byte should be data_o[7:0]. But then which mapping gives that? Let's try: For a byte transfer where sel_i = 4'b0001, then only bit 0 is high. Then for write: hwdata[7:0] = wb_data_reg[31:24]. For read: data_o[7:0] should be hrdata[31:24]? That seems consistent: read: if sel_i[0] is high, then data_o[7:0] = hrdata[31:24]. For a halfword transfer where sel_i = 4'b0011, then we want to transfer 2 bytes. For write: if sel_i[1] is high, then hwdata[15:8] = wb_data_reg[23:16] and if sel_i[0] is high, then hwdata[7:0] = wb_data_reg[31:24]. For read: then data_o[7:0] = hrdata[31:24] and data_o[15:8] = hrdata[23:16]. That means the LSB of wishbone data is hrdata[31:24] and the next byte is hrdata[23:16]. But then wishbone data becomes little-endian: [hrdata[31:24], hrdata[23:16], 0, 0]. But that is not little-endian ordering of the original data? Wait, let's re-check: If the AHB data was originally written as little-endian (for example, wishbone wrote 0x12345678 in little-endian, then AHB sees 0x78563412) then read back, we want to get 0x12345678. So if we do the conversion as described, for a word transfer, we want: if sel_i = 4'b1111, then write: hwdata[31:24] = wb_data_reg[7:0] (which is 0x12), hwdata[23:16] = wb_data_reg[15:8] (0x34), hwdata[15:8] = wb_data_reg[23:16] (0x56), hwdata[7:0] = wb_data_reg[31:24] (0x78). Then hrdata will be 0x78563412. For read conversion, we want data_o = 0x12345678. So then we need: if sel_i[3] is 1, then data_o[7:0] = hrdata[31:24] (which is 0x12), if sel_i[2] is 1, then data_o[15:8] = hrdata[23:16] (0x34), if sel_i[1] is 1, then data_o[23:16] = hrdata[15:8] (0x56), if sel_i[0] is 1, then data_o[31:24] = hrdata[7:0] (0x78). That works.

   So summary for conversion:
   Write: For each byte i from 0 to 3, if sel_i[i] is 1, then hwdata corresponding byte = wb_data_reg[(3-i)*8 +:8].
   Read: For each byte i from 0 to 3, if sel_i[i] is 1, then data_o corresponding byte = hrdata[(3-i)*8 +:8] but placed in little-endian order. But careful: wishbone data_o is little-endian, so the least significant byte is index 0. So if sel_i[0] is high, then data_o[7:0] = hrdata[7:0]? Let's derive: In write, if sel_i[0] is high, then hwdata[7:0] = wb_data_reg[31:24]. So for read, if sel_i[0] is high, then we want data_o[31:24] = hrdata[7:0] (because hrdata[7:0] corresponds to the byte that was written from wb_data_reg[31:24]). But wait, that doesn't seem symmetric. Let's re-check mapping:

   Let's denote Wishbone data as D (little-endian) and AHB data as A (big-endian).
   Write mapping: A[31:24] = D[7:0], A[23:16] = D[15:8], A[15:8] = D[23:16], A[7:0] = D[31:24].
   So if sel_i[3] is high, then A[31:24] = D[7:0].
   If sel_i[2] is high, then A[23:16] = D[15:8].
   If sel_i[1] is high, then A[15:8] = D[23:16].
   If sel_i[0] is high, then A[7:0] = D[31:24].
   Now, read mapping: We get A from AHB, and we want to produce D such that if sel_i[3] is high, then D[7:0] = A[31:24] (because originally D[7:0] was written to A[31:24]).
   Similarly, if sel_i[2] is high, then D[15:8] = A[23:16].
   If sel_i[1] is high, then D[23:16] = A[15:8].
   If sel_i[0] is high, then D[31:24] = A[7:0].
   But D is little-endian, so D[7:0] is the LSB. That means that the mapping for read should be: 
       if sel_i[3] is high, then data_o[7:0] = hrdata[31:24].
       if sel_i[2] is high, then data_o[15:8] = hrdata[23:16].
       if sel_i[1] is high, then data_o[23:16] = hrdata[15:8].
       if sel_i[0] is high, then data_o[31:24] = hrdata[7:0].
   This is consistent with the write mapping inversion.

   So I'll implement conversion functions maybe using generate or functions.

   We'll implement functions:
       function automatic [31:0] swap_bytes(input [31:0] data);
           swap_bytes = { data[31:24], data[23:16], data[15:8], data[7:0] };
       endfunction

   But then for selective swapping, we need to combine only the selected bytes. We can do something like:
       reg [31:0] conv_data;
       always_comb begin
         conv_data = 32'b0;
         if(sel_i[3])
            conv_data[31:24] = wb_data_reg[7:0];
         if(sel_i[2])
            conv_data[23:16] = wb_data_reg[15:8];
         if(sel_i[1])
            conv_data[15:8] = wb_data_reg[23:16];
         if(sel_i[0])
            conv_data[7:0] = wb_data_reg[31:24];
       end
       assign hwdata = conv_data;
   But wait, that is for write. For read, similarly:
       reg [31:0] conv_data_read;
       always_comb begin
         conv_data_read = 32'b0;
         if(sel_i[3])
            conv_data_read[7:0] = hrdata[31:24];
         if(sel_i[2])
            conv_data_read[15:8] = hrdata[23:16];
         if(sel_i[1])
            conv_data_read[23:16] = hrdata[15:8];
         if(sel_i[0])
            conv_data_read[31:24] = hrdata[7:0];
         // For unselected bytes, leave them as 0.
       end
       assign data_o = conv_data_read;
   But careful: in the write conversion, we want to place the swapped bytes in the positions corresponding to the AHB data order. And in the read conversion, we want to place them in the little-endian order positions.

   Actually, it might be simpler to do: for write, generate a 32-bit signal that is the full swapped version: sw = {wb_data_reg[31:24], wb_data_reg[23:16], wb_data_reg[15:8], wb_data_reg[7:0]}. Then mask it with sel_i bits in the proper positions. But then we have to place them in the correct positions. But the mapping is not linear because the positions in hwdata are fixed: bit31:24 is for sel_i[3], bit23:16 is for sel_i[2], etc. So we can do:
       assign hwdata = { (sel_i[3] ? wb_data_reg[7:0] : 8'b0),
                          (sel_i[2] ? wb_data_reg[15:8] : 8'b0),
                          (sel_i[1] ? wb_data_reg[23:16] : 8'b0),
                          (sel_i[0] ? wb_data_reg[31:24] : 8'b0) };
   That is simpler.

   For read, similarly:
       assign data_o = { (sel_i[3] ? hrdata[31:24] : 8'b0),
                          (sel_i[2] ? hrdata[23:16] : 8'b0),
                          (sel_i[1] ? hrdata[15:8] : 8'b0),
                          (sel_i[0] ? hrdata[7:0] : 8'b0) };
   But wait, check: For a byte transfer with sel_i = 4'b0001, then data_o = { (sel_i[3] ? hrdata[31:24] : 0), (sel_i[2] ? hrdata[23:16] : 0), (sel_i[1] ? hrdata[15:8] : 0), (sel_i[0] ? hrdata[7:0] : 0) } = {0,0,0, hrdata[7:0]}. But we want data_o to be little-endian, so the least significant byte should be hrdata[7:0]. That is correct.
   For a halfword transfer with sel_i = 4'b0011, then data_o = { (sel_i[3] ? hrdata[31:24] : 0), (sel_i[2] ? hrdata[23:16] : 0), (sel_i[1] ? hrdata[15:8] : 0), (sel_i[0] ? hrdata[7:0] : 0) } = {0, hrdata[23:16], hrdata[15:8], 0}. But wait, that would place hrdata[23:16] in the MSB and hrdata[15:8] in the second byte, which means the resulting little-endian number is 0x?? Not correct. Let's re-check the desired mapping for read:
       For a halfword transfer, if sel_i = 4'b0011, then we want to transfer two bytes. The AHB transaction will be 2 bytes, and hsize=1. In write, the mapping was: if sel_i[1] is high then hwdata[15:8] = wb_data_reg[23:16] and if sel_i[0] is high then hwdata[7:0] = wb_data_reg[31:24]. So the AHB sees 2 bytes: lower byte = wb_data_reg[31:24] and upper byte = wb_data_reg[23:16]. Then hrdata will be 0x?? such that hrdata[15:8] = wb_data_reg[23:16] and hrdata[7:0] = wb_data_reg[31:24]. Now, for read conversion back to Wishbone, we want data_o to be little-endian, i.e., data_o[7:0] should be wb_data_reg[31:24] and data_o[15:8] should be wb_data_reg[23:16]. So data_o should be { hrdata[31:24] ? or hrdata[23:16]? Let's derive: In write, if sel_i[0] is high then hwdata[7:0] = wb_data_reg[31:24]. So in read, if sel_i[0] is high then we want data_o[7:0] = hrdata[7:0]? But that doesn't match because hrdata[7:0] is the lower byte of the AHB transfer, which corresponds to wb_data_reg[31:24]. And if sel_i[1] is high then hwdata[15:8] = wb_data_reg[23:16]. So in read, if sel_i[1] is high then data_o[15:8] = hrdata[15:8]. So the mapping for read should be: 
       if sel_i[0] is high then data_o[7:0] = hrdata[7:0] (because that's the byte that was written from wb_data_reg[31:24])
       if sel_i[1] is high then data_o[15:8] = hrdata[15:8]
       if sel_i[2] is high then data_o[23:16] = hrdata[23:16] (if applicable)
       if sel_i[3] is high then data_o[31:24] = hrdata[31:24]
   But wait, check word transfer: if sel_i = 4'b1111, then in write: hwdata[31:24] = wb_data_reg[7:0], hwdata[23:16] = wb_data_reg[15:8], hwdata[15:8] = wb_data_reg[23:16], hwdata[7:0] = wb_data_reg[31:24]. Then hrdata will be 0x78563412. For read conversion, we want data_o = 0x12345678. So we want data_o[7:0] = hrdata[31:24] (0x12), data_o[15:8] = hrdata[23:16] (0x34), data_o[23:16] = hrdata[15:8] (0x56), data_o[31:24] = hrdata[7:0] (0x78). So the mapping for read should be: 
       if sel_i[3] is high then data_o[7:0] = hrdata[31:24]
       if sel_i[2] is high then data_o[15:8] = hrdata[23:16]
       if sel_i[1] is high then data_o[23:16] = hrdata[15:8]
       if sel_i[0] is high then data_o[31:24] = hrdata[7:0]
   And for write, mapping is the inverse: 
       if sel_i[3] is high then hwdata[31:24] = wb_data_reg[7:0]
       if sel_i[2] is high then hwdata[23:16] = wb_data_reg[15:8]
       if sel_i[1] is high then hwdata[15:8] = wb_data_reg[23:16]
       if sel_i[0] is high then hwdata[7:0] = wb_data_reg[31:24]
   So we can implement these as combinational logic with if statements.

   I'll implement two always_comb blocks for conversion. But since these depend on the captured wb_sel_reg and hrdata or wb_data_reg, I'll use registers.

   Let's structure the code:

   module wishbone_to_ahb_bridge (
       input  wire         clk_i,
       input  wire         rst_i,
       input  wire         cyc_i,
       input  wire         stb_i,
       input  wire [3:0]   sel_i,
       input  wire         we_i,
       input  wire [31:0]  addr_i,
       input  wire [31:0]  data_i,
       // AHB inputs:
       input  wire         hclk,
       input  wire         hreset_n,
       input  wire [31:0]  hrdata,
       input  wire [1:0]   hresp,
       input  wire         hready,
       // Wishbone outputs:
       output reg  [31:0]  data_o,
       output reg          ack_o,
       // AHB outputs:
       output reg [1:0]    htrans,
       output reg [2:0]    hsize,
       output reg [2:0]    hburst,
       output reg          hwrite,
       output reg [31:0]   haddr,
       output reg [31:0]   hwdata
   );

   We'll assume clk_i and hclk are the same for simplicity.

   Define state encoding:
       localparam IDLE = 2'd0,
                  NON_SEQ = 2'd2, // 10
                  BUSY = 2'd1;   // 01

   reg [1:0] state, next_state;

   Also, registers to hold captured wishbone transaction:
       reg [31:0] wb_addr;
       reg [31:0] wb_data;
       reg [3:0]  wb_sel;
       reg        wb_we;

   We'll have a register for ack (ack_reg). Initially ack_o = 0.

   FSM transitions:
       In IDLE: if (cyc_i && stb_i) then capture transaction parameters and go to NON_SEQ.
       In NON_SEQ: wait for hready. When hready is asserted, then go to BUSY.
       In BUSY: drive ack_o = 1 for one cycle, then go back to IDLE.

   Also, outputs: htrans, hburst, hwrite, haddr, hwdata, hsize.
   - hburst is always 3'b000.
   - htrans: in NON_SEQ state, htrans = 2'b10, in BUSY state, htrans = 2'b01, in IDLE, htrans = 2'b00.
   - hwrite = wb_we.
   - haddr: computed from wb_addr aligned to transfer size. hsize is computed from wb_sel.
   - hwdata: computed from wb_data and wb_sel for write transactions. For read transactions, hwdata is not used.
   
   Let's compute hsize based on wb_sel:
       if (|wb_sel == 1) then hsize = 0 (byte)
       else if (|wb_sel == 2) then hsize = 1 (halfword)
       else if (|wb_sel == 4) then hsize = 2 (word)
       else default hsize = 0.
   We can do this with combinational logic.

   We'll compute aligned address: aligned_addr = wb_addr & ~( (1<<hsize) - 1 ). But careful: if hsize==0, then (1<<0)-1 = 0, so address remains same; if hsize==1, then (1<<1)-1 = 1, so clear bit0; if hsize==2, then (1<<2)-1 = 3, so clear bits[1:0].

   We'll implement that in an always_comb block that computes haddr and hsize. But hsize is also an output of the module, so we can compute it in always_comb. But haddr depends on wb_addr and hsize. But hsize itself is computed from wb_sel. So we can do:

       always_comb begin
          case (wb_sel)
             4'b0001, 4'b1000, 4'b0100, 4'b0010: hsize = 0;
             4'b0011, 4'b1100, 4'b0110, 4'b1001, 4'b1010, 4'b0101: hsize = 1; // but careful, these patterns may not be contiguous though.
             4'b1111: hsize = 2;
             default: hsize = 0;
          endcase
          // For aligned address:
          case (hsize)
             0: haddr = wb_addr;
             1: haddr = wb_addr & 32'h~1;
             2: haddr = wb_addr & 32'h~3;
             default: haddr = wb_addr;
          endcase
       end

   But note: this always_comb block uses wb_sel and wb_addr which are captured in NON_SEQ state. But we need to ensure that when state is NON_SEQ or BUSY, these values are held constant. We can assign them in the FSM state machine. We'll capture them in IDLE state and then hold them.

   For write conversion, in NON_SEQ state, we need to generate hwdata from wb_data and wb_sel. We can do:
       always_comb begin
         hwdata = 32'b0;
         if (wb_sel[3]) hwdata[31:24] = wb_data[7:0];
         if (wb_sel[2]) hwdata[23:16] = wb_data[15:8];
         if (wb_sel[1]) hwdata[15:8] = wb_data[23:16];
         if (wb_sel[0]) hwdata[7:0] = wb_data[31:24];
       end
   But note: This combinational block should be sensitive to wb_data and wb_sel which are captured. So we can put it in a combinational always_comb block inside the module.

   For read conversion, in BUSY state, when hready is asserted, we capture hrdata and then convert it to data_o. We can do:
       always_comb begin
         data_o = 32'b0;
         if (wb_sel[3]) data_o[7:0] = hrdata[31:24];
         if (wb_sel[2]) data_o[15:8] = hrdata[23:16];
         if (wb_sel[1]) data_o[23:16] = hrdata[15:8];
         if (wb_sel[0]) data_o[31:24] = hrdata[7:0];
       end
   But note: wb_sel is the same as captured sel_i.

   Now, FSM:
   In IDLE:
       if (cyc_i && stb_i) begin
          next_state = NON_SEQ;
          capture wb_addr = addr_i, wb_data = data_i, wb_sel = sel_i, wb_we = we_i.
       end else next_state = IDLE.
   In NON_SEQ:
       if (hready) then next_state = BUSY; else next_state = NON_SEQ.
   In BUSY:
       next_state = IDLE (after one cycle, ack_o asserted for one cycle)

   We need to generate ack_o only in BUSY state, and deassert in IDLE.

   Also, htrans: when state is NON_SEQ, htrans = 2'b10; when state is BUSY, htrans = 2'b01; when state is IDLE, htrans = 2'b00.
   hburst is always 3'b000.
   hwrite is wb_we.
   haddr and hsize are computed as above.
   hwdata is computed for write transactions. For read transactions, we don't drive hwdata (or we can drive it as zero).

   We'll implement the FSM using a clocked always_ff block sensitive to clk_i and asynchronous reset (active low rst_i). But also hreset_n is for AHB, but our FSM is for wishbone side, so we use rst_i. But maybe we should also check hreset_n? The specification says "reset behavior: ensure all internal registers are reset when rst_i or hreset_n is asserted." But they are different clocks. We can assume they are synchronous to clk_i and hclk respectively. For simplicity, I'll assume hclk = clk_i. We can check both resets in the always_ff block.

   So always_ff @(posedge clk_i or negedge rst_i) begin
       if (!rst_i) begin
          state <= IDLE;
          ack_o <= 0;
          // Also clear other registers maybe.
       end else begin
          state <= next_state;
          ack_o <= (state == BUSY);
          if (state == IDLE && cyc_i && stb_i) begin
             wb_addr <= addr_i;
             wb_data <= data_i;
             wb_sel  <= sel_i;
             wb_we   <= we_i;
          end
       end
   end

   But careful: We want to capture parameters only on the rising edge when entering NON_SEQ. So maybe do:
       always_ff @(posedge clk_i or negedge rst_i) begin
         if (!rst_i) begin
            state <= IDLE;
            ack_o <= 0;
            wb_addr <= 32'd0;
            wb_data <= 32'd0;
            wb_sel <= 4'd0;
            wb_we <= 1'b0;
         end else begin
            case (state)
               IDLE: begin
                  if (cyc_i && stb_i) begin
                     wb_addr <= addr_i;
                     wb_data <= data_i;
                     wb_sel  <= sel_i;
                     wb_we   <= we_i;
                     state <= NON_SEQ;
                  end else begin
                     state <= IDLE;
                  end
               end
               NON_SEQ: begin
                  if (hready) begin
                     state <= BUSY;
                  end
               end
               BUSY: begin
                  state <= IDLE;
               end
               default: state <= IDLE;
            endcase
            ack_o <= (state == BUSY);
         end
       end

   But this FSM doesn't incorporate next_state logic properly because state updates in a single always_ff block. We can do a simple FSM without next_state register. But then we have combinational logic for outputs. Alternatively, we can use a state register and combinational next state logic, but simpler is to use a case statement in sequential always_ff block.

   But then what about htrans, hburst, hwrite, haddr, hsize, hwdata? We can assign them in an always_comb block.

   So I'll structure the code as follows:

   module wishbone_to_ahb_bridge (
       input  wire         clk_i,
       input  wire         rst_i,
       input  wire         cyc_i,
       input  wire         stb_i,
       input  wire [3:0]   sel_i,
       input  wire         we_i,
       input  wire [31:0]  addr_i,
       input  wire [31:0]  data_i,
       input  wire         hclk,
       input  wire         hreset_n,
       input  wire [31:0]  hrdata,
       input  wire [1:0]   hresp,
       input  wire         hready,
       output reg  [31:0]  data_o,
       output reg          ack_o,
       output reg [1:0]    htrans,
       output reg [2