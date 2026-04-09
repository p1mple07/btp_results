module static_branch_predict (
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [7:0]  predict_confidence_o,
  output logic        predict_exception_o,
  output logic [2:0]  predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o
);

  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;

  // Detect instruction type
  assign instr_jal = (fetch_valid_i & (fetch_rdata_i[6:0] == 7'h6F));
  assign instr_jalr = (fetch_valid_i & (fetch_rdata_i[6:0] == 7'h67));
  assign instr_b = (fetch_valid_i & (fetch_rdata_i[6:0] == 7'h63));
  assign instr_cj = (fetch_valid_i & (fetch_rdata_i[6:0] == 7'h60));
  assign instr_cb = (fetch_valid_i & (fetch_rdata_i[6:0] == 7'h61));

  // Compute internal registers
  assign reg_addr = (instr_jal) ? 32'h0 : 
                     (instr_jalr) ? 32'h0 : 
                     (instr_b) ? 19'h0 : 
                     (instr_cj) ? 20'h0 : 
                     (instr_cb) ? 23'h0 : 
                     32'h0;

  // Immediate values
  assign imm_jal_type = (instr_jal) ? {12'h00000000} | {instr[31:12]} : 0;
  assign imm_jalr_type = (instr_jalr) ? {{20{register_addr_i[31]}}} + reg_addr : 0;
  assign imm_b_type = (instr_b) ? {19'h0} | {19'h0, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0} : 0;
  assign imm_cj_type = (instr_cj) ? {20'h0, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0} : 0;
  assign imm_cb_type = (instr_cb) ? {23'h0} | {23'h0, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0} : 0;

  // Branch prediction logic
  assign predict_branch_taken_o = (predict_confidence_o > 50);
  assign predict_confidence_o = (instr_b || instr_cb) ? 90 : 50;
  assign predict_confidence_o = (instr_jal || instr_jalr) ? 100 : 50;

  assign predict_exception_o = (fetch_pc_i[31:0] != 0);

  assign predict_branch_pc_o = fetch_pc_i + reg_addr;

  assign predict_branch_offset_o = predict_branch_offset;

endmodule
