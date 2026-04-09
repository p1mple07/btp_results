// Offset Calculation for different branch types
assign imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + register_addr;
assign imm_b_type =  { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };

// Branch Prediction Logic
assign predict_branch_taken_o = (predict_confidence_o > 50);
assign predict_branch_pc_o = (predict_branch_taken_o ? fetch_pc_i + predict_branch_offset_o : 0);

// Confidence Level Calculation
assign predict_confidence_o = (fetch_valid_i) ? (instr_b_taken ? 90 : 50) : 0;

// Exception Detection
assign predict_exception_o = (fetch_pc_i % 4 != 0) ? 1'b1 : 1'b0;

// Branch Type Identification
assign instr_jal = (instr[6:0] == 7'h6F);
assign instr_jalr = (instr[6:0] == 7'h67) && (fetch_valid_i);
assign instr_b = (instr[6:0] == 7'h63) && (fetch_valid_i);
assign instr_cj = (instr[6:0] == 7'h66) && (fetch_valid_i);
assign instr_cb = (instr[6:0] == 7'h65) && (fetch_valid_i);

// Branch Prediction Decision
assign instr_b_taken = instr_b && (instr[31] == 1);

// Branch Target Address
assign predict_branch_offset_o = (instr_jal) ? imm_jal_type :
                                 (instr_jalr) ? imm_jalr_type :
                                 (instr_b) ? imm_b_type :
                                 (instr_cj) ? imm_cj_type :
                                 (instr_cb) ? imm_cb_type : 0;

// Type of Branch Instruction
assign predict_branch_type_o = (instr_jal) ? 2'b00 :
                               (instr_jalr) ? 2'b01 :
                               (instr_b) ? 2'b10 :
                               (instr_cj) ? 2'b11 : 2'b00;

endmodule
