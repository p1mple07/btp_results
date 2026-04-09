module static_branch_predict(
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,

  // Additional outputs
  output logic [7:0]  predict_confidence_o,   // Confidence level in prediction
  output logic        predict_exception_o,    // Exception/misalignment detection
  output logic [2:0]  predict_branch_type_o,  // Type of branch
  output logic [31:0] predict_branch_offset_o // Calculated branch offset
);

  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;

  // Branch detection and type classification
  if (fetch_valid_i) begin
    if (instr[6:0] == 7'h6F) begin
      // JAL
      imm_jal_type = {12{instr[31]}};
      // Add offset for JAL
    end else if (instr[6:0] == 7'h67) begin
      // JALR
      reg_addr = register_addr_i;
      imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
      // Add offset for JALR
    end else if (instr[6:0] == 7'h63) begin
      // B-type
      imm_b_type = {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0;
      // Add offset for B-type
    end else if (instr[6:0] == 7'h63) begin
      // CJ or CB (compressed)
      imm_cj_type = {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0;
      imm_cb_type = {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0;
      // Add offset for CJ/CB
    end else begin
      // Default to no branch prediction
    end
  end

  // Compute branch taken flag
  assign predict_branch_taken_o = predict_confidence_o > 50;

  // Compute predicted PC
  assign predict_branch_pc_o = (predict_branch_taken_o) ?
    fetch_pc_i + imm_jal_type  // JAL / JALR
    : fetch_pc_i + imm_b_type  // B-type
    : fetch_pc_i + imm_cj_type; // CJ / CB

  // Confidence level
  assign predict_confidence_o = (fetch_valid_i && !fetch_valid_i) ? 0 : predict_branch_taken_o ? 90 : 50;

  // Exception detection
  assign predict_exception_o = predict_exception_o;

  // Branch type
  assign predict_branch_type_o = (imm_jal_type[31:20] == 3'b0) ? 0 : (imm_b_type[31] == 1'b1) ? 1 : 2;

endmodule
