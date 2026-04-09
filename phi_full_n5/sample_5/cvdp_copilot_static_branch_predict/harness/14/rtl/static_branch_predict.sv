// Branch prediction and branch target calculation
always @(fetch_rdata_i, fetch_pc_i, register_addr_i, fetch_valid_i) begin
    // Decode the fetched instruction
    instr = fetch_rdata_i;
    reg_addr = register_addr_i;

    // Initialize branch type flags
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[19:12] == 7'h00000000 && instr[12] == 7'h1);
    instr_cb = (instr[19:12] == 7'h00000000 && instr[12] == 7'h2);

    // Initialize confidence level and exception flags
    predict_confidence_o = 0;
    predict_exception_o = 1; // Assume non-aligned by default

    // Process each branch type
    casez({instr_jal, instr_jalr, instr_b, instr_cj, instr_cb})
        {1'b1, instr_jal} | {1'b1, instr_jalr}:
            begin
                predict_confidence_o = 100;
                predict_branch_taken_o = 1;
                imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
                predict_branch_offset_o = imm_jal_type + fetch_pc_i;
            end
        {1'b1, instr_b} | {1'b1, instr_cj}:
            begin
                predict_confidence_o = instr_b_taken ? 90 : 50;
                predict_branch_taken_o = instr_b_taken;
                imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
                predict_branch_offset_o = imm_b_type + fetch_pc_i;
            end
        {1'b1, instr_cb}:
            begin
                predict_confidence_o = instr_b_taken ? 90 : 50;
                predict_branch_taken_o = instr_b_taken;
                imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
                predict_branch_offset_o = imm_cb_type + fetch_pc_i;
            end
        default:
            begin
                predict_confidence_o = 0;
                predict_branch_taken_o = 0;
                predict_exception_o = 0;
            end
    endcase

    // Exception detection
    if (predict_confidence_o == 0) begin
        predict_exception_o = 1; // Set exception flag if confidence is 0
    end

    // Branch type output
    predict_branch_type_o = instr_jal ? 2'b01 : instr_jalr ? 2'b10 : instr_b ? 2'b11 : instr_cj ? 2'b00 : instr_cb ? 2'b00 : 2'bx;
end
