module static_branch_predict (
  // Inputs
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Internal signals
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

  // Outputs
  output logic predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);

  logic [31:0] reg_addr;

  // Branch prediction logic
  logic [31:0] imm_jal_type_assign;
  logic [31:0] imm_jalr_type_assign;
  logic [31:0] imm_b_type_assign;
  logic [31:0] imm_cj_type_assign;
  logic [31:0] imm_cb_type_assign;

  assign imm_jal_type = (fetch_rdata_i[6:0] == 8'h6F) ? 32'h0000000000000000 : 0;
  assign imm_jalr_type = (fetch_rdata_i[6:0] == 8'h67) ? 32'h0000000000000000 : 0;
  assign imm_b_type = (fetch_rdata_i[6:0] == 8'h63) ? 32'h0000000000000000 : 0;
  assign imm_cj_type = (fetch_rdata_i[6:0] == 8'h6C) ? 32'h0000000000000000 : 0;
  assign imm_cb_type = (fetch_rdata_i[6:0] == 8'h6B) ? 32'h0000000000000000 : 0;

  // Determine branch type
  assign instr_jal = (instr[6:0] == 8'h6F);
  assign instr_jalr = (instr[6:0] == 8'h67);
  assign instr_b = (instr[6:0] == 8'h63);
  assign instr_cj = (instr[6:0] == 8'h6C);
  assign instr_cb = (instr[6:0] == 8'h6B);

  // Branch taken decision
  assign predict_branch_taken_o = (instr_b) ? (imm_b_type[31] == 1) :
                                        (instr_cj && imm_cj_type[31] > 0) ||
                                        (instr_cb && imm_cb_type[31] > 0);

  // Predicted PC
  assign predict_branch_pc_o = fetch_pc_i + branch_imm;

endmodule
