module static_branch_predict (
  
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);
  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;

  logic [31:0] branch_imm;

  logic [31:0] instr;
  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;
  
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Calculate branch immediate based on instruction type
  if (instr_jal) begin
      branch_imm = imm_jal_type;
  else if (instr_jalr) begin
      branch_imm = imm_jalr_type;
  else if (instr_b) begin
      // B-type branch immediate construction
      branch_imm = (imm_b_type + (16'h10000000_00000000)) - 1;
  else if (instr_cj) begin
      // Extract immediate from CJ instruction
      branch_imm = imm_cj_type;
  else if (instr_cb) begin
      // Extract immediate from CB instruction
      branch_imm = imm_cb_type;
  else begin
      branch_imm = 0;
  end

  // Determine branch taken flag based on instruction type and immediate
  instr_b_taken = 0;
  if (instr_jal || instr_jalr || instr_cj) begin
      instr_b_taken = 1;
  else if (instr_b) begin
      // For B-type branches, check sign bit of immediate
      instr_b_taken = (branch_imm[31] == 1);
  else if (instr_cb) begin
      // For CB-type branches, check sign bit of immediate
      instr_b_taken = (branch_imm[31] == 1);
  end

  // Calculate predicted branch target address
  predict_branch_pc_o = branch_imm + fetch_pc_i;