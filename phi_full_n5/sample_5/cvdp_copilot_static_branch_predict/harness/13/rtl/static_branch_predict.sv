  // Branch Immediate Selection
  always @(*) begin
    case (instr[6:0])
      7'h6F: instr_jal = 1'b1; imm_jal_type = {instr[7:0], {instr[7], 1'b0}};
      7'h67: instr_jalr = 1'b1; imm_jalr_type = instr[7:0] + reg_addr;
      7'h63: instr_b = 1'b1; imm_b_type = {instr[31], instr[30:0]} - (instr[30] & 1'b1);
      7'h6C: instr_cj = 1'b1; imm_cj_type = instr[31:23] + {instr[22:1], 1'b0};
      7'h6B: instr_cb = 1'b1; imm_cb_type = instr[31:23] + {instr[22:1], 1'b0};
      default: branch_imm = imm_b_type + 0;
    endcase
  end

  // Branch Taken Decision
  always_comb begin
    case (instr[6:0])
      7'h6F: instr_b_taken = 1'b1;
      7'h67: instr_b_taken = 1'b1;
      7'h63: instr_b_taken = instr_b[31];
      7'h6C: instr_b_taken = imm_cj_type[31];
      7'h6B: instr_b_taken = imm_cb_type[31];
      default: instr_b_taken = 1'b0;
    endcase
  end

  // Branch Prediction
  assign predict_branch_taken_o = (instr_jal || instr_jalr || instr_b || instr_cj || instr_cb) && instr_b_taken;

  // Branch Target Address Calculation
  always @(posedge fetch_valid_i) begin
    if (fetch_valid_i) begin
      predict_branch_pc_o = fetch_pc_i + branch_imm;
    end
  end
endmodule
