  always @(*) begin
    // Instruction Decoding
    instr = fetch_rdata_i;
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[6:0] == 7'h6C);
    instr_cb = (instr[6:0] == 7'h6B);

    // Branch Immediate Selection
    if (instr_jal) begin
      imm_jal_type = instr[24:20] << 16; // Sign-extended 20-bit immediate
      branch_imm = imm_jal_type;
    end
    else if (instr_jalr) begin
      imm_jalr_type = instr[23:12] + reg_addr; // Add register address to 12-bit immediate
      branch_imm = imm_jalr_type;
    end
    else if (instr_b) begin
      imm_b_type = {instr[29:30], instr[28:0]'b0, instr[27:25]'b0, instr[26:23]'b0, instr[22:16]'b0, instr[15:14]'b0}; // Sign-extend the immediate
      branch_imm = imm_b_type;
    end
    else if (instr_cj) begin
      imm_cj_type = instr[29:24]'b0; // Extract the immediate value for CJ
      branch_imm = imm_cj_type;
    end
    else if (instr_cb) begin
      imm_cb_type = instr[29:24]'b0; // Extract the immediate value for CB
      branch_imm = imm_cb_type;
    end
    else begin
      branch_imm = imm_b_type + 0;
    end

    // Branch Taken Decision
    instr_b_taken = (branch_imm[31] == 1); // Check if the immediate sign bit is set

    // Branch Prediction
    predict_branch_taken_o = (instr_jal || instr_jalr || instr_b || instr_cj || instr_cb) || instr_b_taken;

    // Branch Target Address Calculation
    predict_branch_pc_o = fetch_pc_i + branch_imm;
  end
