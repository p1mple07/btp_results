module that compresses a 24-bit input vector (num_i) into a 12-bit mantissa (mantissa_o) and a 4-bit exponent (exponent_o) output. The module is to be implemented in Verilog. It is RTL code generation problem. The instructions include: Provide only the RTL code generated according to the requirements. And instructions: "When generating files, return the file name in the correct place at the folder structure." But instructions: "Your response will be saved directly to: rtl/compression_engine.sv." So we need to output the file content with that file name in the folder structure: rtl/compression_engine.sv.

We need to complete the code. Let's check the given partial code. We have module compression_engine with inputs clk, reset, num_i, outputs mantissa_o, exponent_o. It has internal wires: exp_oh (logic [23:12]) but then we have parameter usage: onehot_to_bin module uses parameter ONE_HOT_W = 12 and BIN_W = 4. So the code is using onehot vector width = 12 bits. But then in the compression_engine module, they defined exp_oh as logic [23:12]. That is a bit weird. Wait, check: "logic [23:12] exp_oh;" is defined. But then we see that the onehot_to_bin module is instantiated with .ONE_HOT_W(12) and .BIN_W(4). But then we assign exp_oh[23] = num_i[23]. But then comment: "Insert code for one-hot encoding of exp_oh". We need to implement the one-hot encoding logic. But note: The onehot_to_bin module expects a one-hot vector of width 12 bits, but our exp_oh is declared as logic [23:12]. But wait, it's declared as logic [23:12] which is 12 bits (bit 23 downto bit 12 inclusive, which is 12 bits). So that is correct. And then we want to compute exp_oh[i] for each bit i in that range? But the instruction said: "For each bit i: exp_oh[i] = num_i[i] & ~|num_i[23:i+1];". But note: our exp_oh is 12 bits, but then the index range is [23:12]. But then the formula should be: For each bit index i in [23:12] (or maybe [23:12]) but then the formula uses "num_i[i] & ~|num_i[23:i+1]". But then i+1 is not defined if i = 23. Let's check: if i = 23, then num_i[23:i+1] is num_i[23:24] which is empty? Usually in Verilog, if the range is inverted, it's 0? But we can define it as a constant 0. But the typical approach: for i in range [23:12], we want to check if num_i[i] is set and all bits above it (i+1 to 23) are zero. But then how to do that? The formula says: exp_oh[i] = num_i[i] & ~(|num_i[23:i+1]). But if i = 23, then num_i[23:24] is empty, and ~(|num_i[23:24]) is 1. But if i = 22, then we want to check if num_i[22] is 1 and num_i[23] is 0. But our vector has 24 bits, index from 0 to 23. But then our onehot vector is 12 bits, meaning the bits from index 12 to 23. But then the logic is: for each i in [23:12], set exp_oh[i] = num_i[i] & ~(|num_i[i+1:23]). But the provided formula is: exp_oh[i] = num_i[i] & ~|num_i[23:i+1]. But note: index order: The MSB is bit 23. So if num_i[23] is 1, then exp_oh[23] = 1. If num_i[23] is 0 but num_i[22] is 1, then exp_oh[22] = 1, provided that bits 23..23 are all zero, which they are because bit 23 is 0. But then if input is all zeros, then no bit gets set, so then exponent = 0.

We need to complete the one-hot encoding logic. So we have to write code like:

for (int i = 23; i >= 12; i--) begin
    exp_oh[i] = num_i[i] & ~(|num_i[i+1:23]); // but careful: if i == 23 then i+1:23 is empty, so we need a special case?
end

But then the provided partial code "assign exp_oh[23] = num_i[23];" is given. But then we need to fill in the rest. We can write a generate loop maybe:

genvar i;
generate
   for (i = 22; i >= 12; i = i - 1) begin: one_hot_loop
      assign exp_oh[i] = num_i[i] & ~(|num_i[i+1:23]);
   end
endgenerate

But careful: We have to check index boundaries. For i=22, then num_i[23:23] is bit 23. But what if i=23? Then the range is [24:23]. But then we need to treat that as 0. But we can use a conditional expression: For i=23, we can simply assign it as num_i[23]. But then for i from 22 to 12, we do: assign exp_oh[i] = num_i[i] & ~(|num_i[i+1:23]). But then i+1:23, when i=22, the range is [23:23] which is fine. When i=12, then range is [13:23]. That is fine.

So one-hot encoding is completed.

Next, the onehot_to_bin module. It is a parameterized module. It takes input oh_vec_i (ONE_HOT_W bits) and outputs bin_vec_o. It needs to perform priority encoding: find the highest index that is 1 and output its binary value. But the instructions: "Use the provided onehot_to_bin module to convert the one-hot vector (exp_oh) into a binary exponent (exp_bin)." But then the code says: "onehot_to_bin #(... ) exp_oh_bin (.oh_vec_i(exp_oh), .bin_vec_o(exp_bin));". And then "assign exponent = (|exp_oh) ? exp_bin + 4'h1 : exp_bin;". But then in the onehot_to_bin module, they want us to implement code for priority encoding. The code snippet in the onehot_to_bin module is:

module onehot_to_bin #(
  parameter ONE_HOT_W = 32,  // Width of the one-hot input
  parameter BIN_W     = 5    // Width of the binary output
)(
  input   wire [ONE_HOT_W-1:0]  oh_vec_i,  // One-hot encoded input
  output  logic [BIN_W-1:0]     bin_vec_o  // Binary encoded output
);

  integer i;

 // Insert code for one-hot encoding of `exp_oh` for priority encoding

endmodule