module to add a new input signal to control whether the data should be sign-extended or zero-extended when loaded into the writeback stage." So we have a module rtl/load_store_unit.sv. We need to modify it to add a new input "ex_if_extend_mode_i". It is a 1-bit input. It is used to control extension of the loaded data. It is used only when load operation is done for halfword or byte. The description: For halfword and byte, if ex_if_extend_mode_i==0 (zero-extend), then the loaded data is shifted to the least significant bits and padded with zeros in upper bits. If ex_if_extend_mode_i==1 (sign-extend), then the loaded data is shifted and sign extended by replicating the MSB. But what exactly is the shifting? For halfword, 16 bits, for byte, 8 bits. But the module is in SystemVerilog and it is a load store unit. The code is provided.

We need to modify the module to add a new input. Where is the place to apply extension? The extension should be applied in the "Read Response Handling" always_ff block. In the "Read Response Handling" always_ff block, it assigns wb_if_rdata_q <= dmem_rsp_rdata_i. But now we need to modify it to perform extension when load operation is performed.

But wait: The module is a load store unit. It is a hardware module. The extension should be applied when the load operation occurs. The dmem_rsp_rdata_i is the data from DMEM. The extension is applied if the type is not word, i.e. ex_if_type_i is 0 or 1. But wait, note: The extension input is not used in the always_ff block currently. We need to update it so that the read data is extended. But then the extension is a function of the extension mode and the type. But how to get the type? In the always_ff block for read response, we only check dmem_rvalid_i. But we can do the extension logic as a combinational block. But note that the extension should only apply for loads. But how to know if it's load or store? The "ex_if_we_i" input is "write enable: 0 (load), 1 (store)". So if ex_if_we_i==0, then it's a load, and we need to extend. But then what if it's a store? Then we don't need to extend. But then we need to check ex_if_type_i to determine if it's a load of halfword or byte. But wait, the extension input is provided on the interface? It is an additional input "ex_if_extend_mode_i". So we add this input to the module interface. But then the extension should be applied in the read response block when ex_if_we_i is 0 and ex_if_type_i is not 2? But careful: The module interface has ex_if_type_i as a 2-bit input with possible values: 2'b10 for word, 2'b01 for halfword, 2'b00 for byte. But then we need to check if it's a load operation (ex_if_we_i==0). But wait, the extension logic should be applied regardless of ex_if_req_i? But the extension mode is provided externally, so it should be used in the always_ff block for read response? But the always_ff block for read response currently is:
 
 always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (dmem_rvalid_i) begin
      wb_if_rdata_q   <= dmem_rsp_rdata_i;
      wb_if_rvalid_q  <= 1'b1;
    end else begin
      wb_if_rvalid_q  <= 1'b0;
    end
  end

We need to modify it to apply extension when ex_if_we_i==0 and ex_if_type_i < 2 (i.e. 0x0 or 0x1). But wait, we must consider that the extension input is not in the always_ff block. So we need to add it as an input in the module port list. So add "input logic ex_if_extend_mode_i" to the port list. So new input is "ex_if_extend_mode_i" at the same level as others. But then, where do we use it? The extension should be applied in the "Read Response Handling" always_ff block. But note: The extension is only applicable when dmem_rvalid_i is true and it's a load (ex_if_we_i==0) and the type is halfword or byte. But then, what if it's a word load? The new input is ignored. But what if it's a store? Then we don't need to extend because store doesn't need extension because the data is written to memory. But then, should we apply extension on the read response? But the read response is only for load operations. But the code doesn't check ex_if_we_i in the read response block. But we can incorporate the extension logic in the always_ff block, but note that the always_ff block currently is triggered by dmem_rvalid_i. But we might need to use the current ex_if_type_i and ex_if_extend_mode_i to compute the extended data. But these signals are not registered, but they are input signals. But wait, in the always_ff block, ex_if_type_i and ex_if_we_i are available from the interface? They are not registered, but they are inputs. But careful: The always_ff block is asynchronous and is triggered on posedge clk, so the extension mode is available at that time. But then, we need to check ex_if_we_i and ex_if_type_i. But if it's a store, then we don't extend. But if it's a load and the type is halfword or byte, then we need to extend dmem_rsp_rdata_i. But how do we know the size? We check ex_if_type_i. For ex_if_type_i=2'b00 (byte load) then the loaded data is 8 bits, and we need to shift it left by 24 bits? Actually, careful: The loaded data is from dmem_rsp_rdata_i. But the byte enable indicates which byte is valid. For example, if dmem_be == 4'b0001 then the loaded byte is at bit 7. But then if zero-extended, we shift the loaded byte to the right position. But wait, the extension specification: "the loaded byte or halfword is shifted to the least significant bits and padded with zeros in the upper bits of the register." That means that if it's a byte load, then the loaded data is 8 bits, and then it's zero extended to 32 bits. But if it's a halfword load, then it's 16 bits extended to 32 bits. But the extension mode is either sign extension or zero extension. And the extension is applied on the loaded data (which is dmem_rsp_rdata_i) but we need to extract the valid portion. But wait, how do we know which byte or halfword is valid? Because the byte enable signal dmem_be indicates which bytes are valid. But then, the extension is not exactly just a shift. We need to extract the valid data from dmem_rsp_rdata_i based on dmem_be. But the original code does not do any extraction. It just passes dmem_rsp_rdata_i to wb_if_rdata_q. But now we need to extend the loaded data. But the specification says: "For Halfword and Byte loads, the loaded byte or halfword is shifted to the least significant bits and padded with zeros in the upper bits." That means we need to isolate the valid data portion from dmem_rsp_rdata_i. But how to do that? We can use the byte enable dmem_be to mask out the valid bytes? But the dmem_be signal is generated in the always_comb block for byte enable generation. But dmem_be is local to that always_comb block. But then, the always_ff block for read response does not have dmem_be as input. But we can compute the effective loaded data as: if ex_if_type_i == 2'b00 (byte load) then:
   effective_data = dmem_rsp_rdata_i[7:0] << (some shift)? But wait, the extension specification: "shifted to the least significant bits." That means if we are doing zero extension, we want to shift the loaded data to the LSB position. But what shift amount? For a byte load, we want the loaded byte to be in bits [7:0]. For a halfword load, we want the loaded halfword to be in bits [15:0]. But note, the loaded data is coming from DMEM as a 32-bit word. But the valid portion is only part of it. But how do we know which part is valid? The dmem_be signal tells which bytes are valid. But in the extension logic, we can assume that dmem_be is one-hot for the valid byte. But wait, the dmem_be is computed based on the address alignment. But then, if the address is misaligned, misaligned_addr is set, and then dmem_be remains 4'b0000? Actually, in the code, misaligned_addr is set to 1'b1 in some cases. But then, dmem_be remains 4'b0000. But then, the extension logic might have a problem if misaligned. But maybe we assume that misaligned loads are not allowed? But the spec doesn't mention misalignment extension. But we can assume that misaligned_addr is false when a load is accepted. But what if misaligned_addr is true? Then the extension logic might not be used? But probably, the extension is only used when misaligned_addr is false. But then, we can compute effective data by taking dmem_rsp_rdata_i masked by dmem_be? But dmem_be is a 4-bit value with bits set corresponding to valid bytes. But for byte load, dmem_be will be something like 4'b0001, 4'b0010, etc. But then, how to extract the valid data? We can do: effective_data = dmem_rsp_rdata_i & {32{dmem_be}}? But that doesn't work because dmem_be is 4 bits, not 32 bits. We need to replicate the bits. Alternatively, we can compute effective_data as: if ex_if_type_i == 2'b00, then effective_data = dmem_rsp_rdata_i << (8 * (index of set bit)? But the index of the set bit can be determined by the value of dmem_be. But note that dmem_be is computed as 4'b0001 for 2'b00 and address alignment 00, 4'b0010 for 01, etc. But then, we can compute the shift amount as: if dmem_be==4'b0001 then shift amount = 24, if 4'b0010 then shift amount = 16, if 4'b0100 then shift amount = 8, if 4'b1000 then shift amount = 0. But wait, that's reversed: if the valid byte is the least significant byte, then shift amount = 0; if the valid byte is the second byte, then shift amount = 8; if the valid byte is the third, then shift amount = 16; if the valid byte is the fourth, then shift amount = 24. But the code computed dmem_be in always_comb. But we can compute the shift amount from dmem_be. But then, for halfword load, ex_if_type_i == 2'b01, then dmem_be will be 4'b0011 or 4'b1100. But then, we need to extract the valid halfword. But then, we need to know which halfword is valid. Possibly, if dmem_be == 4'b0011, then the lower halfword is valid, so effective_data = dmem_rsp_rdata_i[15:0]. But if dmem_be == 4'b1100, then the upper halfword is valid, so effective_data = dmem_rsp_rdata_i[31:16]. But then, we shift it right by 16 bits. But then, apply extension: if zero extend then just zero-extend, if sign extend then replicate the sign bit. But sign extension: for a halfword, if effective_data[15] is 1 then result = effective_data | (- (1 << 16))? But that's not trivial in combinational logic. But we can use the built-in function $signed or something. But in SystemVerilog, we can use the "ext" operator? Actually, in SystemVerilog, you can do: effective_data_zero = effective_data; effective_data_sign = effective_data[15] ? {16'hFFFF, effective_data[15:0]} : {16'h0000, effective_data[15:0]}. But then, assign the extended value to wb_if_rdata_q.

But then, how do we combine extension for halfword and byte? We need to check ex_if_type_i. So the always_ff block for read response handling should be modified to something like:
 
 always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q <= 32'b0;
      wb_if_rvalid_q <= 1'b0;
    end else if (dmem_rvalid_i) begin
      if (!ex_if_we_i) begin // load operation
         // Now, check type
         if (ex_if_type_i == 2'b00) begin // byte load
             // Determine shift amount based on dmem_be
             case (dmem_be)
               4'b0001: begin effective_data = dmem_rsp_rdata_i[7:0] << 24; end
               4'b0010: begin effective_data = dmem_rsp_rdata_i[7:0] << 16; end
               4'b0100: begin effective_data = dmem_rsp_rdata_i[7:0] << 8;  end
               4'b1000: begin effective_data = dmem_rsp_rdata_i[7:0]; end
             endcase
             // Apply extension
             if (ex_if_extend_mode_i == 1'b0) begin
                wb_if_rdata_q <= effective_data;
             end else begin
                wb_if_rdata_q <= {{24{effective_data[7]}}, effective_data};
             end
         end else if (ex_if_type_i == 2'b01) begin // halfword load
             // Determine valid halfword based on dmem_be
             // dmem_be can be either 4'b0011 or 4'b1100.
             if (dmem_be == 4'b0011) begin
                effective_data = dmem_rsp_rdata_i[15:0];
             end else if (dmem_be == 4'b1100) begin
                effective_data = dmem_rsp_rdata_i[31:16];
             end
             // Now, effective_data is 16-bit, shift to lower bits
             effective_data = effective_data; // already lower 16 bits? Actually, we need to zero-extend it to 32 bits: effective_data = effective_data;
             if (ex_if_extend_mode_i == 1'b0) begin
                wb_if_rdata_q <= {16'd0, effective_data};
             end else begin
                wb_if_rdata_q <= {{16{effective_data[15]}}, effective_data};
             end
         end else begin // word load: ex_if_type_i == 2'b10, no extension applied
             wb_if_rdata_q <= dmem_rsp_rdata_i;
         end
      end else begin
         wb_if_rvalid_q <= 1'b0;
      end
      wb_if_rvalid_q <= 1'b1;
    end else begin
      wb_if_rvalid_q <= 1'b0;
    end
  end

But note: We need to declare a temporary variable effective_data. But the always_ff block is sequential. We can declare a local variable inside the block. But SystemVerilog doesn't allow variable declarations inside always_ff blocks? Actually, you can declare a temporary variable in the always_ff block if it's a procedural block. But it's not synthesizable? But it's fine. Alternatively, we can compute the extension in an always_comb block and then register it. But the specification says: "During load transactions, the load/store unit will apply the specified extension mode before updating wb_if_rdata_o with the read data." That means that the extension should be done in the always_ff block for read response.

But note: The extension should be applied only for load operations. But how do we know that it's a load operation? ex_if_we_i==0. But the always_ff block for read response does not check ex_if_we_i. But we can check that. But then, what if it's a store? The read data is not used in that case. But then, we can simply assign dmem_rsp_rdata_i to wb_if_rdata_q if it's a store? But that's not needed because store doesn't need read data. But maybe we can just do: if (ex_if_we_i == 0) then apply extension else assign dmem_rsp_rdata_i. But wait, but the always_ff block is triggered only on dmem_rvalid_i, which is for load responses. But store doesn't generate a response, so it's fine.

I worry about the fact that ex_if_type_i and ex_if_extend_mode_i are input signals that might change between cycles. But they are available at read response time. But they are not registered. But that's acceptable.

We need to modify the port list: add "input logic ex_if_extend_mode_i" after ex_if_wdata_i maybe.

Let's check original port list:
 module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    output logic                 ex_if_ready_o    ,
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,        // Requested data valid
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [ 3:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
 );

We need to add new input: "input logic ex_if_extend_mode_i" after ex_if_addr_offset_i maybe.

So new port list:

 module load_store_unit (
    input logic clk,
    input logic rst_n,
    input logic ex_if_req_i,
    input logic ex_if_we_i,
    input logic [1:0] ex_if_type_i,
    input logic [31:0] ex_if_wdata_i,
    input logic [31:0] ex_if_addr_base_i,
    input logic [31:0] ex_if_addr_offset_i,
    input logic ex_if_extend_mode_i,  // new input for extension mode
    output logic ex_if_ready_o,
    output logic [31:0] wb_if_rdata_o,
    output logic wb_if_rvalid_o,
    output logic dmem_req_o,
    input logic dmem_gnt_i,
    output logic [31:0] dmem_req_addr_o,
    output logic dmem_req_we_o,
    output logic [3:0] dmem_req_be_o,
    output logic [31:0] dmem_req_wdata_o,
    input logic [31:0] dmem_rsp_rdata_i,
    input logic dmem_rvalid_i
 );

That is the new port list.

Now, where to implement extension? We modify the always_ff block for read response handling.

Original always_ff block for read response:
 always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (dmem_rvalid_i) begin
      wb_if_rdata_q   <= dmem_rsp_rdata_i;
      wb_if_rvalid_q  <= 1'b1;
    end else begin
      wb_if_rvalid_q  <= 1'b0;
    end
  end

We need to modify it to check if it's a load operation (ex_if_we_i==0) and if ex_if_type_i is 0 or 1. But wait, how do we know which load type? ex_if_type_i: 2'b00 -> Byte load, 2'b01 -> Halfword load, 2'b10 -> Word load. For word load, we do nothing.

So new always_ff block becomes:

 always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q <= 32'b0;
      wb_if_rvalid_q <= 1'b0;
    end else if (dmem_rvalid_i) begin
      if (!ex_if_we_i) begin  // load operation
         case (ex_if_type_i)
           2'b10: begin
             // Word load: no extension
             wb_if_rdata_q <= dmem_rsp_rdata_i;
           end
           2'b01: begin
             // Halfword load
             // Determine which halfword is valid based on dmem_be?
             // But we don't have dmem_be signal available here? We could compute it based on ex_if_addr_int?
             // But we computed dmem_be in always_comb block above. But that always_comb block is combinational.
             // But dmem_be is computed and then assigned to dmem_req interface. But we don't have dmem_be as a register.
             // However, we can compute the extension using the same logic as in the always_comb block for byte enable generation.
             // But we need to know the address alignment. We can recalc: misaligned_addr is computed in always_comb block.
             // But we can simply replicate the logic here.
             // Actually, we can compute effective_data as:
             // if (ex_if_addr_offset_i[1:0] == 2'b00) then lower halfword valid, else upper halfword valid.
             // But careful: ex_if_addr_offset_i is used in address calculation: data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i.
             // We can use data_addr_int[1:0] to determine which halfword is loaded.
             // But dmem_be was computed using data_addr_int[1:0] in the always_comb block.
             // We can recompute that here:
             // For halfword load, if (data_addr_int[1:0] == 2'b00) then effective_data = dmem_rsp_rdata_i[15:0],
             // else effective_data = dmem_rsp_rdata_i[31:16].
             // But wait, what if misaligned_addr is true? Then extension may not be valid.
             // But according to spec, extension is applied only when misaligned_addr is false. But the always_ff block doesn't have misaligned_addr.
             // We can recalc misaligned_addr as well.
             // misaligned_addr is computed in always_comb block with the same logic as above.
             // We can recalc misaligned_addr here for halfword load:
             // For halfword load, misaligned_addr is set if data_addr_int[1:0] is not 2'b00 or 2'b10.
             // But we already computed that in the always_comb block.
             // However, we don't have dmem_be or misaligned_addr in this block. We need to recompute them.
             // We can recompute data_addr_int here: data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i, which is already computed in an assign statement.
             // But note: ex_if_addr_base_i and ex_if_addr_offset_i are inputs.
             // So we can do: data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i; (but it's already assigned above)
             // Then, determine halfword valid:
             if (data_addr_int[1:0] == 2'b00) begin
               effective_data = dmem_rsp_rdata_i[15:0];
             end else if (data_addr_int[1:0] == 2'b10) begin
               effective_data = dmem_rsp_rdata_i[31:16];
             end else begin
               // misaligned, just pass dmem_rsp_rdata_i?
               effective_data = dmem_rsp_rdata_i;
             end
             // Now apply extension: shift effective_data to lower bits.
             if (ex_if_extend_mode_i == 1'b0) begin
               wb_if_rdata_q <= {16'd0, effective_data};
             end else begin
               wb_if_rdata_q <= {{16{effective_data[15]}}, effective_data};
             end
           end
           2'b00: begin
             // Byte load
             // Determine shift amount based on data_addr_int[1:0]
             // For byte load, if (data_addr_int[1:0] == 2'b00) then shift = 24, if 2'b01 then shift = 16, if 2'b10 then shift = 8, if 2'b11 then shift = 0.
             case (data_addr_int[1:0])
               2'b00: begin
                 effective_data = dmem_rsp_rdata_i[7:0];
                 effective_data = effective_data << 24;
               end
               2'b01: begin
                 effective_data = dmem_rsp_rdata_i[7:0];
                 effective_data = effective_data << 16;
               end
               2'b10: begin
                 effective_data = dmem_rsp_rdata_i[7:0];
                 effective_data = effective_data << 8;
               end
               2'b11: begin
                 effective_data = dmem_rsp_rdata_i[7:0];
                 effective_data = effective_data; // no shift
               end
             endcase
             if (ex_if_extend_mode_i == 1'b0) begin
               wb_if_rdata_q <= effective_data;
             end else begin
               wb_if_rdata_q <= {{24{effective_data[7]}}, effective_data};
             end
           end
           default: begin
             wb_if_rdata_q <= dmem_rsp_rdata_i;
           end
         endcase
      end else begin
         wb_if_rdata_q <= dmem_rsp_rdata_i;
      end
      wb_if_rvalid_q <= 1'b1;
    end else begin
      wb_if_rvalid_q <= 1'b0;
    end
  end

But wait, in this always_ff block, we refer to "effective_data" which is not declared. We need to declare a local variable effective_data of type logic [31:0]. But can we declare it inside an always_ff block? In SystemVerilog, you can declare variables in a procedural block if using "integer" or "logic" but it's not synthesizable sometimes, but it's allowed in SystemVerilog.

We can declare "logic [31:0] effective_data;" at the beginning of the block. But then we need to compute effective_data based on ex_if_type_i.

But careful: We need to compute data_addr_int. But data_addr_int is computed as assign data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i; in the code. So that's available.

But then, in the halfword load case, we check if (data_addr_int[1:0] == 2'b00) then effective_data = dmem_rsp_rdata_i[15:0]; else if (data_addr_int[1:0] == 2'b10) then effective_data = dmem_rsp_rdata_i[31:16]; else effective_data = dmem_rsp_rdata_i; But wait, what if data_addr_int[1:0] is 2'b01 or 2'b11? For halfword, valid alignments are only 2'b00 and 2'b10. So if it's misaligned, we could set misaligned_addr flag and maybe not extend? But the spec doesn't specify misaligned behavior explicitly. But we can assume that misaligned_addr is false if a load is accepted. But maybe we should do: if (data_addr_int[1:0] != 2'b00 && data_addr_int[1:0] != 2'b10) then effective_data = dmem_rsp_rdata_i; That would be consistent with the always_comb block for halfword load in the original code: it sets misaligned_addr if not aligned. But then, the original code: in always_comb block for byte enable generation, for halfword load, if (data_addr_int[1:0] != 2'b00 and not 2'b10) then misaligned_addr = 1 and dmem_be is 4'b0000. But then, in our extension logic, we can do: if (data_addr_int[1:0] != 2'b00 && data_addr_int[1:0] != 2'b10) then effective_data = dmem_rsp_rdata_i. But then, no extension is applied. But spec says: "For halfword load: if extension mode is zero, result is just the loaded halfword shifted to lower bits, if sign extension then replicate the MSB." But if misaligned, then misaligned_addr is true, so maybe we should not perform extension? The specification does not mention misaligned loads. But the spec says "For Halfword and Byte Load operations", so I assume misaligned_addr should be false for valid operations. So we can assume that if misaligned_addr is true, then maybe we just pass dmem_rsp_rdata_i. But the spec doesn't require handling misaligned. We can mimic the original behavior: the original code sets misaligned_addr to 1'b1 in some cases and doesn't update dmem_be. But then, dmem_be remains 4'b0000. But then, in our extension logic, if ex_if_type_i is 2'b00 or 2'b01, we can check if misaligned_addr is true. But misaligned_addr is computed in always_comb block, but we don't have it in this block. But we can recalc misaligned_addr using the same logic as in the always_comb block for byte enable generation. But that might be duplicative. Alternatively, we can assume that misaligned_addr is false for valid operations. But it's not safe to assume. But the specification doesn't mention misaligned extension, so I'll assume misaligned_addr is false if load is accepted.

We can compute misaligned_addr for halfword load as: if (data_addr_int[1:0] != 2'b00 && data_addr_int[1:0] != 2'b10) then misaligned = 1. For byte load, valid alignments are any 2-bit value, so no misalignment possible. So for halfword load, we do:
 if ((data_addr_int[1:0] != 2'b00) && (data_addr_int[1:0] != 2'b10)) then effective_data = dmem_rsp_rdata_i; else if (data_addr_int[1:0] == 2'b00) then effective_data = dmem_rsp_rdata_i[15:0]; else if (data_addr_int[1:0] == 2'b10) then effective_data = dmem_rsp_rdata_i[31:16];

But wait, the always_comb block for halfword load in original code does:
 always_comb begin: case (ex_if_type_i)
 2'b01: begin  // Writing a half-word
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0011;
            2'b10:   dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end

So if the address isn't 00 or 10, then misaligned. So in our extension logic, if misaligned then effective_data = dmem_rsp_rdata_i. That is what we want.

For byte load, it's always aligned? Actually, for byte load, any 2-bit value is valid because a byte is 8 bits, so alignment is always fine.

So for byte load, we do:
 case (data_addr_int[1:0])
   2'b00: effective_data = dmem_rsp_rdata_i[7:0] << 24;
   2'b01: effective_data = dmem_rsp_rdata_i[7:0] << 16;
   2'b10: effective_data = dmem_rsp_rdata_i[7:0] << 8;
   2'b11: effective_data = dmem_rsp_rdata_i[7:0];
 endcase

Then apply extension mode.

For halfword load, we do:
 if (data_addr_int[1:0] == 2'b00) effective_data = dmem_rsp_rdata_i[15:0];
 else if (data_addr_int[1:0] == 2'b10) effective_data = dmem_rsp_rdata_i[31:16];
 else effective_data = dmem_rsp_rdata_i; // misaligned

Then apply extension:
 if (ex_if_extend_mode_i == 0) then effective_data is zero extended: {16'd0, effective_data} (which is effectively the same as effective_data but extended to 32 bits, but effective_data is already 16 bits if not misaligned, so we need to pad it to 32 bits).
 if (ex_if_extend_mode_i == 1) then effective_data is sign extended: {{16{effective_data[15]}}, effective_data}.

For word load (ex_if_type_i == 2'b10), no extension is applied, so wb_if_rdata_q = dmem_rsp_rdata_i.

So overall, the always_ff block becomes:

 always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
       wb_if_rdata_q <= 32'b0;
       wb_if_rvalid_q <= 1'b0;
    end else if (dmem_rvalid_i) begin
       if (!ex_if_we_i) begin // load operation
          case (ex_if_type_i)
            2'b10: begin // word load
              wb_if_rdata_q <= dmem_rsp_rdata_i;
            end
            2'b01: begin // halfword load
              if ((data_addr_int[1:0] != 2'b00) && (data_addr_int[1:0] != 2'b10)) begin
                 effective_data = dmem_rsp_rdata_i; // misaligned
              end else if (data_addr_int[1:0] == 2'b00) begin
                 effective_data = dmem_rsp_rdata_i[15:0];
              end else if (data_addr_int[1:0] == 2'b10) begin
                 effective_data = dmem_rsp_rdata_i[31:16];
              end
              if (ex_if_extend_mode_i == 1'b0) begin
                 wb_if_rdata_q <= {16'd0, effective_data};
              end else begin
                 wb_if_rdata_q <= {{16{effective_data[15]}}, effective_data};
              end
            end
            2'b00: begin // byte load
              case (data_addr_int[1:0])
                2'b00: begin
                  effective_data = dmem_rsp_rdata_i[7:0];
                  effective_data = effective_data << 24;
                end
                2'b01: begin
                  effective_data = dmem_rsp_rdata_i[7:0];
                  effective_data = effective_data << 16;
                end
                2'b10: begin
                  effective_data = dmem_rsp_rdata_i[7:0];
                  effective_data = effective_data << 8;
                end
                2'b11: begin
                  effective_data = dmem_rsp_rdata_i[7:0];
                  effective_data = effective_data; // no shift
                end
              endcase
              if (ex_if_extend_mode_i == 1'b0) begin
                 wb_if_rdata_q <= effective_data;
              end else begin
                 wb_if_rdata_q <= {{24{effective_data[7]}}, effective_data};
              end
            end
            default: wb_if_rdata_q <= dmem_rsp_rdata_i;
          endcase
       end else begin
         wb_if_rdata_q <= dmem_rsp_rdata_i;
       end
       wb_if_rvalid_q <= 1'b1;
    end else begin
       wb_if_rvalid_q <= 1'b0;
    end
 end

But note: We need to declare effective_data variable. But where do we declare it? We can declare it inside the always_ff block as a local variable. But in SystemVerilog, you can declare a variable inside an always_ff block. But I'm not 100% sure if it's allowed. Alternatively, we can declare a separate always_comb block that computes extended data and then register it. But the spec says "Your response will be saved directly to: rtl/load_store_unit.sv." So I can modify the module code accordingly.

We also need to update the port list with the new input signal.

So the final modified code should look like:

module load_store_unit (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 ex_if_req_i,           // LSU request
    input  logic                 ex_if_we_i,            // Write enable: 0 (load), 1 (store)
    input  logic     [ 1:0]      ex_if_type_i,          // Data type: 0x2 (word), 0x1 (halfword), 0x0 (byte)
    input  logic     [31:0]      ex_if_wdata_i,         // Data to write to memory
    input  logic     [31:0]      ex_if_addr_base_i,     // Base address
    input  logic     [31:0]      ex_if_addr_offset_i,   // Offset address
    input  logic                 ex_if_extend_mode_i,   // New input: 0 for zero-ext, 1 for sign-ext
    output logic                 ex_if_ready_o,
    output logic     [31:0]      wb_if_rdata_o,         // Requested data
    output logic                 wb_if_rvalid_o,        // Requested data valid
    output logic                 dmem_req_o,
    input  logic                 dmem_gnt_i,
    output logic     [31:0]      dmem_req_addr_o,
    output logic                 dmem_req_we_o,
    output logic     [ 3:0]      dmem_req_be_o,
    output logic     [31:0]      dmem_req_wdata_o,
    input  logic     [31:0]      dmem_rsp_rdata_i,
    input  logic                 dmem_rvalid_i
    );

  // Internal signals
  logic ex_req_fire;
  logic dmem_req_we_q;
  logic [31:0] data_addr_int;
  logic misaligned_addr;
  logic [3:0] dmem_be, dmem_req_be_q;

  logic busy_q;  // Sticky busy bit: Set with EX req and cleared with DMEM response
  logic dmem_req_q ;

  logic [31:0] dmem_req_wdata_q;
  logic [31:0] dmem_req_addr_q;

  logic [31:0] wb_if_rdata_q;
  logic wb_if_rvalid_q;

  // Address calculation
  assign data_addr_int = ex_if_addr_base_i + ex_if_addr_offset_i;

  // EX request fire condition
  assign ex_req_fire = ex_if_req_i && !busy_q && !misaligned_addr;
  assign ex_if_ready_o = !busy_q;

  ///////////////////////////////// Byte Enable Generation ////////////////////////////////
  always_comb begin
    misaligned_addr = 1'b0;
    dmem_be = 4'b0000;
    case (ex_if_type_i)  // 0x2 (word), 0x1 (halfword), 0x0 (byte)
      2'b00: begin  // Writing a byte
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0001;
            2'b01:   dmem_be = 4'b0010;
            2'b10:   dmem_be = 4'b0100;
            2'b11:   dmem_be = 4'b1000;
            default: dmem_be = 4'b0000;
          endcase
      end

      2'b01: begin  // Writing a half-word
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b0011;
            2'b10:   dmem_be = 4'b1100;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end

      2'b10: begin  // Writing a word
          case (data_addr_int[1:0])
            2'b00:   dmem_be = 4'b1111;
            default: begin
                dmem_be = 4'b0000;
                misaligned_addr = 1'b1;
            end
          endcase
      end
      default: begin
          dmem_be = 4'b0000;
          misaligned_addr = 1'b1;
      end 
    endcase
  end

  
  ///////////////////////////////// dmem_req ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      dmem_req_q <= 1'b0;
      dmem_req_addr_q <= '0;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
    end else if (ex_req_fire) begin
      dmem_req_q <= 1'b1;
      dmem_req_addr_q <= data_addr_int;
      dmem_req_we_q <= ex_if_we_i;
      dmem_req_be_q <= dmem_be ;
      dmem_req_wdata_q <= ex_if_wdata_i ;
    end else if (dmem_req_q && dmem_gnt_i) begin
      dmem_req_q <= 1'b0;  // request granted
      dmem_req_addr_q <= '0 ;
      dmem_req_we_q <= '0 ;
      dmem_req_be_q <= '0 ;
      dmem_req_wdata_q <= '0 ;
    end
  end
  

  ///////////////////////////////// DMEM Request Interface ////////////////////////////////
  always_comb begin : dmem_req
    dmem_req_o        = dmem_req_q;
    dmem_req_addr_o   = dmem_req_addr_q;
    dmem_req_we_o     = dmem_req_we_q;
    dmem_req_be_o     = dmem_req_be_q;
    dmem_req_wdata_o  = dmem_req_wdata_q;
  end

  ///////////////////////////////// Read Response Handling ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      wb_if_rdata_q   <= 32'b0;
      wb_if_rvalid_q  <= 1'b0;
    end else if (dmem_rvalid_i) begin
      if (!ex_if_we_i) begin // load operation
         case (ex_if_type_i)
           2'b10: begin
             // Word load: no extension applied
             wb_if_rdata_q <= dmem_rsp_rdata_i;
           end
           2'b01: begin
             // Halfword load: determine valid halfword based on alignment
             if ((data_addr_int[1:0] != 2'b00) && (data_addr_int[1:0] != 2'b10)) begin
               // Misaligned: pass full data without extension
               wb_if_rdata_q <= dmem_rsp_rdata_i;
             end else if (data_addr_int[1:0] == 2'b00) begin
               // Lower halfword valid
               wb_if_rdata_q <= {16'd0, dmem_rsp_rdata_i[15:0]};
             end else if (data_addr_int[1:0] == 2'b10) begin
               // Upper halfword valid
               wb_if_rdata_q <= {dmem_rsp_rdata_i[31:16], 16'd0};
             end
             // Apply extension based on ex_if_extend_mode_i
             if (ex_if_extend_mode_i == 1'b1) begin
               // Sign-extend: replicate MSB of the loaded halfword
               wb_if_rdata_q <= {{16{dmem_rsp_rdata_i[15]}}, dmem_rsp_rdata_i[15:0]};
             end
           end
           2'b00: begin
             // Byte load: determine shift amount based on alignment
             case (data_addr_int[1:0])
               2'b00: wb_if_rdata_q <= {24'd0, dmem_rsp_rdata_i[7:0]};
               2'b01: wb_if_rdata_q <= {16'd0, dmem_rsp_rdata_i[7:0], 8'd0};
               2'b10: wb_if_rdata_q <= {8'd0, dmem_rsp_rdata_i[7:0], 16'd0};
               2'b11: wb_if_rdata_q <= {dmem_rsp_rdata_i[7:0], 24'd0};
             endcase
             // Apply extension based on ex_if_extend_mode_i
             if (ex_if_extend_mode_i == 1'b1) begin
               // Sign-extend: replicate MSB of the loaded byte
               wb_if_rdata_q <= {{24{dmem_rsp_rdata_i[7]}}, dmem_rsp_rdata_i[7:0]};
             end
           end
           default: wb_if_rdata_q <= dmem_rsp_rdata_i;
         endcase
      end else begin
         wb_if_rdata_q <= dmem_rsp_rdata_i;
      end
      wb_if_rvalid_q <= 1'b1;
    end else begin
      wb_if_rvalid_q <= 1'b0;
    end
  end

  assign wb_if_rdata_o =  wb_if_rdata_q;
  assign wb_if_rvalid_o = wb_if_rvalid_q;

  ///////////////////////////////// Busy Logic ////////////////////////////////
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      busy_q <= 1'b0;
    end else if (ex_req_fire) begin
      busy_q <= 1'b1;
    end else if (dmem_req_we_q && dmem_gnt_i) begin
      busy_q <= 1'b0;  // Write request granted
    end else if (!dmem_req_we_q && dmem_rvalid_i) begin
      busy_q <= 1'b0;  // Read request response received
    end
  end
  
endmodule