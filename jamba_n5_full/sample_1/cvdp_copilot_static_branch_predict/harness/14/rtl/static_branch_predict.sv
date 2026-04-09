module static_branch_predict(
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,

  output logic [7:0]  predict_confidence_o,   // Confidence level in prediction
  output logic        predict_exception_o,    // Exception/misalignment detection
  output logic [2:0]  predict_branch_type_o,  // Type of branch
  output logic [31:0] predict_branch_offset_o // Calculated branch offset
);

  // Extract instruction fields
  assign instr_jal   = (fetch_rdata_i[6:0] == 6'h6F);
  assign instr_jalr  = (fetch_rdata_i[6:0] == 7'h67);
  assign instr_b     = (fetch_rdata_i[6:0] == 7'h63);
  assign instr_cj    = (fetch_rdata_i[6:0] == 7'h63 && fetch_rdata_i[11:7] == 3'b0000);
  assign instr_cb    = (fetch_rdata_i[6:0] == 7'h63 && fetch_rdata_i[11:7] == 3'b0001);

  logic instr_b_taken;
  logic instr_cj_taken;
  logic instr_cb_taken;

  // Check if branch taken
  assign predict_branch_taken_o = (instr_jal || instr_jalr || instr_b || instr_cj || instr_cb);

  // Compute confidence level
  assign predict_confidence_o = (instr_b_taken || instr_cj_taken || instr_cb_taken) ? 90 : 50;

  // Compute target address
  assign predict_branch_pc_o = fetch_pc_i + reg_addr;

  // Determine branch type
  assign predict_branch_type_o = (instr_jal) ? 0 : (instr_jalr) ? 1 : (instr_b) ? 2 : (instr_cj) ? 3 : 4;

  // Exception detection
  assign predict_exception_o = (fetch_pc_i[30:20] == 3'b000) ? 1 : 0;

endmodule
