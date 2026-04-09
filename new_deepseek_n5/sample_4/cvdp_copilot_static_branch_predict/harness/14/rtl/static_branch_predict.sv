module static_branch_predict(
  input logic [31:0] fetch_rdata_i,
  input logic [31:0] fetch_pc_i,
  input logic [31:0] register_addr_i,
  input logic fetch_valid_i,
  output logic predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [7:0] predict_confidence_o,
  output logic predict_exception_o,
  output logic [2:0] predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o
)  

  // Decode instruction
  logic [31:0] instr = fetch_rdata_i;
  
  // Determine branch type
  instr_jal = (instr[6:0] == 7'h6F);
  instr_jalr = (instr[6:0] == 7'h67);
  instr_b = (instr[6:0] == 7'h63);
  instr_cj = (instr[6:0] == 7'h66) & (~instr[31] & ~instr[30]);
  instr_cb = (instr[6:0] == 7'h66) & (instr[31] & ~instr[30]);
  
  // Calculate imms
  imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + register_addr_i;
  imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[31:25], instr[11:8], 1'b0 };
  imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
  imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
  
  // Set confidence levels
  predict_confidence_o = 50;
  if (instr_jal) predict_confidence_o = 100;
  if (instr_jalr) predict_confidence_o = 100;
  if (instr_b) predict_confidence_o = (imm_b_type[31] == 1) ? 90 : 50;
  if (instr_cj) predict_confidence_o = (imm_cj_type[31] == 1) ? 90 : 50;
  if (instr_cb) predict_confidence_o = (imm_cb_type[31] == 1) ? 90 : 50;
  
  // Set prediction flags
  predict_exception_o = 0;
  if (!fetch_valid_i) predict_exception_o = 1;
  if (instr_jal || instr_jalr || instr_cj || instr_cb) predict_branch_taken_o = (predict_confidence_o > 50);
  if (instr_b_taken) predict_branch_taken_o = 1;
  predict_branch_pc_o = fetch_pc_i + predict_confidence_o;
  predict_branch_type_o = { instr_jal ? 7'h6F : 0, instr_jalr ? 7'h67 : 0, instr_b ? 7'h63 : 0, instr_cj ? 7'h66 : 0, instr_cb ? 7'h66 : 0 };
  predict_branch_offset_o = (instr_jal || instr_jalr) ? imm_jalr_type : 0;