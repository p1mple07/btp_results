  always @(*) begin
    instr = fetch_rdata_i;
    reg_addr = register_addr_i;

    // Instruction type decoding
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[10:8] == 7'h00 && instr[6:0] == 7'h01); // Assuming CJ is indicated by 0x01 in the upper bits
    instr_cb = (instr[10:8] == 7'h00 && instr[6:0] == 7'h02); // Assuming CB is indicated by 0x02 in the upper bits

    // Branch immediate selection
    branch_imm = instr_jal ? imm_jal_type :
                 instr_jalr ? imm_jalr_type :
                 instr_b ? imm_b_type :
                 instr_cj ? imm_cj_type :
                 imm_cb_type;

    // Branch taken decision for B-type branches
    instr_b_taken = instr_b && (imm_b_type[31] == 1);

    // Branch prediction
    predict_branch_taken_o = instr_jal || instr_jalr || instr_b || instr_cj || instr_cb;

    // Branch target address calculation
    predict_branch_pc_o = fetch_pc_i + branch_imm;
  end
