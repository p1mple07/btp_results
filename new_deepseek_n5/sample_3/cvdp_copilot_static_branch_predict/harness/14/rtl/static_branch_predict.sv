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

  logic [31:0] reg_addr;
  logic [32:0] imm_jal_type;
  logic [32:0] imm_jalr_type;
  logic [32:0] imm_b_type;
  logic [32:0] imm_cj_type;
  logic [32:0] imm_cb_type;
  logic [32:0] instr;

  logic instr_jal, instr_jalr, instr_b, instr_cj, instr_cb;
  logic instr_b_taken;

  // Decode instruction
  instr = fetch_rdata_i;

  // Determine branch type and calculate immediate values
  case(instr[6:0])
    7'h6F: instr_jal = 1; imm_jal_type = { {12(instr[31])}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    7'h67: instr_jalr = 1; imm_jalr_type = {{20(instr[31])}, instr[31:20]} + register_addr_i;
    7'h63: instr_b = 1; imm_b_type = { {19(instr[31])}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    7'h67 | 7'h66: instr_cj = 1; imm_cj_type = { {20(instr[12])}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
    7'h67 | 7'h65: instr_cb = 1; imm_cb_type = { {23(instr[12])}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
    default: instr_b_taken = 0;
  endcase

  // Calculate confidence levels
  if (instr_jal) predict_confidence_o = 100;
  else if (instr_jalr) predict_confidence_o = 100;
  else if (instr_b) predict_confidence_o = 90;
  else if (instr_cj) predict_confidence_o = 90;
  else if (instr_cb) predict_confidence_o = 90;
  else predict_confidence_o = 0;

  // Set prediction flags
  predict_branch_taken_o = (predict_confidence_o > 50);
  predict_branch_type_o = { instr_b, instr_cj, instr_cb, instr_jal, instr_jalr }[instr];
  predict_branch_offset_o = 0;
  if (instr_jal) predict_branch_offset_o = imm_jal_type;
  else if (instr_jalr) predict_branch_offset_o = imm_jalr_type;
  else if (instr_b) predict_branch_offset_o = imm_b_type;
  else if (instr_cj) predict_branch_offset_o = imm_cj_type;
  else if (instr_cb) predict_branch_offset_o = imm_cb_type;

  // Calculate target address
  predict_branch_pc_o = fetch_pc_i + predict_branch_offset_o;

  // Exception detection
  predict_exception_o = 0;
  if (!fetch_valid_i) predict_exception_o = 1;
  else if (instr_b_taken) predict_exception_o = 1;

endmodule