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

  // Decode instruction
  instr = fetch_rdata_i;
  instr_jal = (instr[6:0] == 6F);
  instr_jalr = (instr[6:0] == 67);
  instr_b = (instr[6:0] == 63);
  instr_cj = (instr[31] & (instr[6:0] & 6F));
  instr_cb = (instr[31] & (instr[6:0] & 6C));

  // Calculate immediate
  branch_imm = 0;
  if (instr_jal) branch_imm = imm_jal_type;
  else if (instr_jalr) branch_imm = imm_jalr_type;
  else if (instr_b) branch_imm = imm_b_type;
  else if (instr_cj) branch_imm = imm_cj_type;
  else if (instr_cb) branch_imm = imm_cb_type;

  // Branch prediction
  predict_branch_taken_o = instr_jal | instr_jalr | instr_cj | instr_cb | instr_b;

  // Calculate target address
  predict_branch_pc_o = branch_imm + fetch_pc_i;