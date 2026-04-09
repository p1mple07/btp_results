// Branch prediction and branch target calculation
always_comb begin
  // Instruction decoding
  instr = fetch_rdata_i;
  reg_addr = register_addr_i;

  // JAL instruction
  instr_jal = (instr[6:0] == 7'h6F);
  if (instr_jal) begin
    imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    predict_branch_type_o = 2'b00; // JAL
  end

  // JALR instruction
  instr_jalr = (instr[6:0] == 7'h67);
  if (instr_jalr) begin
    imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
    predict_branch_type_o = 2'b01; // JALR
  end

  // B-type instruction
  instr_b = (instr[6:0] == 7'h63);
  if (instr_b) begin
    imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    predict_branch_type_o = 2'b10; // B-type
    instr_b_taken = (imm_b_type[31] == 1'b1);
  end

  // CJ and CB instruction
  instr_cj = (instr[31] == instr[12]);
  instr_cb = (instr[11] == instr[6]);
  if (instr_cj) begin
    imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
    predict_branch_type_o = 2'b11; // CJ/CB
    instr_b_taken = (imm_cj_type[31] == 1'b1);
  end

  // Branch prediction logic
  if (fetch_valid_i) begin
    if (instr_jal || instr_jalr || instr_b_taken || instr_cj || instr_cb) begin
      predict_branch_taken_o = 1'b1;
      predict_confidence_o = 100;
    end else begin
      predict_branch_taken_o = 1'b0;
      predict_confidence_o = (instr_b_taken ? 90 : 50);
    end
  end else begin
    predict_branch_taken_o = 1'b0;
    predict_confidence_o = 0;
    predict_exception_o = 1'b1;
  end

  // Branch target address calculation
  if (predict_branch_taken_o) begin
    predict_branch_pc_o = fetch_pc_i + imm_jal_type + imm_jalr_type + imm_b_type + imm_cj_type;
  end else begin
    predict_branch_pc_o = fetch_pc_i;
  end
end
