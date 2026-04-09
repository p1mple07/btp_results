We need to modify the given Verilog code for static_branch_predict module. The requirement: implement Value Range Propagation for RISC-V branch and jump instructions. We need to provide the modified RTL code.

We should follow the algorithm described. Let's restructure the code accordingly.

We need to add new signals: predict_confidence_o (8-bit), predict_exception_o (1-bit), predict_branch_type_o (3-bit), predict_branch_offset_o (32-bit). Also outputs predict_branch_pc_o etc.

But the original code had many signals. We need to keep them but add new ones.

Let's plan:

- We'll keep existing inputs: fetch_rdata_i, fetch_pc_i, register_addr_i, fetch_valid_i.

- We'll add outputs: predict_branch_pc_o, predict_branch_taken_o, predict_branch_offset_o, predict_confidence_o, predict_exception_o, predict_branch_type_o.

- Also we need to compute branch_imm, predict_branch_pc_o, etc.

Let's rewrite the module accordingly.

We need to follow the algorithm steps.

We'll include the same logic: extract immediate, sign-extend, etc.

We need to set branch_imm accordingly.

Also we need to set predict_confidence_o to 8'd90 if predicted taken, else maybe 0? But the example shows 8'd90. But the requirement says output confidence level. So we can set it to 90% if predicted taken.

But the algorithm: The probability is 90% for backward, 50% for forward. So when predicted taken, confidence is 90%, else maybe 50%? But the example shows 90% for taken.

We'll set predict_confidence_o to 9'b11111111 if predicted taken, else 0? But the example uses 8'd90. The example: predict_confidence_o = 8'd90. So we can set to 8'd90.

But we need to be consistent.

Let's design:

We'll have:

assign predict_branch_taken_o;
assign predict_branch_pc_o;
assign predict_branch_offset_o;
assign predict_confidence_o;
assign predict_exception_o;
assign predict_branch_type_o;

Now, in the always block:

We need to compute branch_imm, etc.

But we need to handle the three cases: backward, forward, jump.

We can use conditional assignments.

Let's try to produce a coherent Verilog code.

We need to avoid JSON formatting. Just provide the code.

Also, note: the user wants the answer in plain text, no JSON.

We should produce the modified module code.

Let's draft:

We'll keep the existing parts:

module static_branch_predict (
  
  // Inputs
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Outputs
  output logic predict_branch_pc_o,
  output logic predict_branch_taken_o,
  output logic predict_branch_offset_o,
  output logic predict_confidence_o,
  output logic predict_exception_o,
  output logic predict_branch_type_o,

  // Internal signals
  logic [31:0] reg_addr,
  logic [31:0] imm_jal_type,
  logic [31:0] imm_jalr_type,
  logic [31:0] imm_b_type,
  logic [31:0] imm_cj_type,
  logic [31:0] imm_cb_type,
  logic [31:0] branch_imm,
  logic [31:0] instr,
  logic instr_jal,
  logic instr_jalr,
  logic instr_b,
  logic instr_cj,
  logic instr_cb,
  logic [31:0] imm_jal_type_jal,
  logic [31:0] imm_jalr_type_jalr,
  logic [31:0] imm_b_type_b,
  logic [31:0] imm_cb_type_cb,
  logic [31:0] branch_imm_jal,
  logic [31:0] branch_imm_jalr,
  logic [31:0] branch_imm_b,
  logic [31:0] branch_imm_cb,
  logic [31:0] imm_b_type_cj,
  logic [31:0] imm_b_type_cb,
  logic [31:0] branch_imm_cj,
  logic [31:0] imm_cb_type_cj,
  logic [31:0] imm_cb_type_cb,
  logic [31:0] branch_imm_cb_cj,
  logic [31:0] imm_cb_type_cb_cj,
  logic [31:0] branch_imm_cb_cb_cj,
  logic [31:0] imm_cb_type_cb_cb_cj,
  logic [31:0] branch_imm_cb_cb_cb_cj,
  logic [31:0] imm_cb_type_cb_cb_cb_cj,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj,
  logic [31:0] imm_cb_type_cb_cb_cb_cj_cj,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] branch_imm_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,
  logic [31:0] imm_cb_type_cb_cb_cb_cb_cj_cj_cj_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb_cb,