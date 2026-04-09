// Branch prediction and branch target calculation
always @(fetch_rdata_i, fetch_pc_i, register_addr_i, fetch_valid_i) begin
  instr <= fetch_rdata_i;
  
  // Instruction type decoding
  instr_jal = (instr[6:0] == 7'h6F);
  instr_jalr = (instr[6:0] == 7'h67);
  instr_b = (instr[6:0] == 7'h63);
  instr_cj = (instr[19:12] == 7'h0000000); // Assuming specific bits for CJ
  instr_cb = (instr[19:12] == 7'h0000001); // Assuming specific bits for CB

  // Calculate immediate values based on instruction type
  if (instr_jal) begin
    imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    predict_confidence_o = 100;
  end
  else if (instr_jalr) begin
    imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + register_addr;
    predict_confidence_o = 100;
  end
  else if (instr_b) begin
    imm_b_type =  { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    if (imm_b_type[31]) begin
      predict_confidence_o = 90;
      predict_b_taken_o = 1;
    end
    else begin
      predict_confidence_o = 50;
      predict_b_taken_o = 0;
    end
  end
  else if (instr_cj) begin
    imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
    if (imm_cj_type[31]) begin
      predict_confidence_o = 90;
      predict_cj_taken_o = 1;
    end
    else begin
      predict_confidence_o = 50;
      predict_cj_taken_o = 0;
    end
  end
  else if (instr_cb) begin
    imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
    if (imm_cb_type[31]) begin
      predict_confidence_o = 90;
      predict_cb_taken_o = 1;
    end
    else begin
      predict_confidence_o = 50;
      predict_cb_taken_o = 0;
    end
  end
  else begin
    predict_confidence_o = 0;
    predict_branch_taken_o = 0;
    predict_exception_o = 1; // Assuming misalignment for invalid instructions
  end

  // Calculate branch offset
  if (instr_jal || instr_jalr || instr_b || instr_cj || instr_cb) begin
    predict_branch_offset_o = predict_branch_pc_o + (imm_jal_type || imm_jalr_type || imm_b_type || imm_cj_type || imm_cb_type);
  end
  else begin
    predict_branch_offset_o = 0;
  end
end
