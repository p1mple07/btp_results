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

  // Determine branch type and set branch_taken
  instr_jal = (instr[6:0] == 7'h6F);
  instr_jalr = (instr[6:0] == 7'h67);
  instr_b = (instr[6:0] == 7'h63);
  instr_cj = (instr[5:0] & 7'h0F) == 7'h08;
  instr_cb = (instr[5:0] & 7'h0F) == 7'h0C;

  instr_b_taken = (instr_b & (imm_b_type[31] == 1)) 
                | (instr_cb & (imm_cb_type[31] == 1));

  // Select branch_imm based on instruction type
  branch_imm = 0;
  if (instr_jal) branch_imm = imm_jal_type;
  else if (instr_jalr) branch_imm = imm_jalr_type;
  else if (instr_b) branch_imm = imm_b_type;
  else if (instr_cj) branch_imm = imm_cj_type;
  else if (instr_cb) branch_imm = imm_cb_type;
  else branch_imm = 0;

  // Set prediction outputs
  predict_branch_taken_o = 
    instr_jal | instr_jalr | instr_cj | instr_b_taken;
  predict_branch_pc_o = predict_branch_taken_o ? (fetch_pc_i + branch_imm) : fetch_pc_i;