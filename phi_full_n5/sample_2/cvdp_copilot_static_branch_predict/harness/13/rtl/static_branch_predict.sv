  always @(*) begin
    instr = fetch_rdata_i;
    reg_addr = register_addr_i;

    // Instruction decoding
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[6:0] == 7'h40); // Assuming CJ starts with 7'h40
    instr_cb = (instr[6:0] == 7'h41); // Assuming CB starts with 7'h41

    // Branch Immediate Selection
    if (instr_jal) begin
      imm_jal_type = {reg_addr, {instr[15:0], '0}};
    end
    else if (instr_jalr) begin
      imm_jalr_type = instr[11:0] + reg_addr;
    }
    else if (instr_b) begin
      imm_b_type = {instr[30:2], instr[2:0], '0}; // Sign extension
    end
    else if (instr_cj) begin
      imm_cj_type = instr[15:8]; // Extracting compressed immediate
    end
    else if (instr_cb) begin
      imm_cb_type = instr[15:8]; // Extracting compressed immediate
    end
    else begin
      branch_imm = imm_b_type;
    }

    // Branch Taken Decision
    instr_b_taken = (imm_b_type[31] == 1); // Assuming B-type branch is sign-extended

    // Branch Prediction
    predict_branch_taken_o = (instr_jal || instr_jalr || instr_b || instr_cj) || instr_b_taken;

    // Branch Target Address Calculation
    predict_branch_pc_o = fetch_pc_i + branch_imm;
  end
