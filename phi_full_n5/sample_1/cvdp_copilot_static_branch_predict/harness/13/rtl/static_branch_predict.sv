  // Instruction Decoding
  always @(*) begin
    instr = fetch_rdata_i;
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[15:12] == 7'h00000000);
    instr_cb = (instr[15:12] == 7'h00000001);
  end

  // Branch Immediate Selection
  always @(*) begin
    imm_jal_type = {31{instr_jal}};
    imm_jalr_type = imm_jal_type + {reg_addr};
    imm_b_type = {31{instr_b}};
    imm_cj_type = {31{instr_cj}};
    imm_cb_type = {31{instr_cb}};
    branch_imm = (instr_jal) || (instr_jalr) || (instr_b) ? imm_jal_type :
                 (instr_cj) ? imm_cj_type :
                 (instr_cb) ? imm_cb_type : imm_b_type;
  end

  // Branch Taken Decision
  always @(*) begin
    instr_b_taken = (instr_b) ? imm_b_type[31] : 0;
    // Assuming similar logic for imm_cj_type and imm_cb_type if needed
  end

  // Branch Prediction
  assign predict_branch_taken_o = (instr_jal) || (instr_jalr) || (instr_b) || (instr_cj) || (instr_cb);

  // Branch Target Address Calculation
  assign predict_branch_pc_o = fetch_pc_i + branch_imm;

endmodule
