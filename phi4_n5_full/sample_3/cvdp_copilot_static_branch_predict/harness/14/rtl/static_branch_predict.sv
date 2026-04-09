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

  // Internal registers and wires
  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;
  logic        instr_jal;
  logic        instr_jalr;
  logic        instr_b;
  logic        instr_cj;
  logic        instr_cb;

  // Assign internal register from input
  assign reg_addr = register_addr_i;
  assign instr    = fetch_rdata_i;

  // Instruction decoding: determine branch type based on opcode
  // JAL: opcode == 7'h6F, JALR: opcode == 7'h67, B-type: opcode == 7'h63.
  // For compressed instructions (not one of the above), use bit[12] to differentiate:
  //   if (instr[12] == 1'b0) then CJ, else CB.
  always_comb begin
    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b   = (instr[6:0] == 7'h63);
    instr_cj  = 1'b0;
    instr_cb  = 1'b0;
    if (~(instr_jal || instr_jalr || instr_b)) begin
      if (instr[12] == 1'b0)
        instr_cj = 1'b1;
      else
        instr_cb = 1'b1;
    end
  end

  // Calculate immediate values for each branch type
  always_comb begin
    // JAL: 32-bit immediate from 20-bit field
    imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

    // JALR: 12-bit immediate sign-extended and added to reg_addr
    imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;

    // B-type: 32-bit immediate constructed from bit fields
    imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

    // CJ: Compressed Jump immediate
    imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };

    // CB: Compressed Branch immediate
    imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
  end

  // Branch prediction: determine branch type, confidence, offset, and target address
  always_comb begin
    if (!fetch_valid_i) begin
      predict_confidence_o = 8'd0;
      predict_branch_type_o = 3'd0;
      predict_branch_offset_o = 32'd0;
      predict_branch_pc_o = fetch_pc_i;
    end
    else if (instr_jal) begin
      predict_branch_type_o = 3'd1;  // JAL
      predict_confidence_o = 8'd100;
      predict_branch_offset_o = imm_jal_type;
      predict_branch_pc_o = fetch_pc_i + imm_jal_type;
    end
    else if (instr_jalr) begin
      predict_branch_type_o = 3'd2;  // JALR
      predict_confidence_o = 8'd100;
      predict_branch_offset_o = imm_jalr_type;
      predict_branch_pc_o = fetch_pc_i + imm_jalr_type;
    end
    else if (instr_b) begin
      predict_branch_type_o = 3'd3;  // B-type
      // For B-type: if sign bit set, confidence = 90; else 50.
      predict_confidence_o = (imm_b_type[31]) ? 8'd90 : 8'd50;
      predict_branch_offset_o = imm_b_type;
      predict_branch_pc_o = fetch_pc_i + imm_b_type;
    end
    else if (instr_cj) begin
      predict_branch_type_o = 3'd4;  // CJ
      predict_confidence_o = 8'd100;
      predict_branch_offset_o = imm_cj_type;
      predict_branch_pc_o = fetch_pc_i + imm_cj_type;
    end
    else if (instr_cb) begin
      predict_branch_type_o = 3'd5;  // CB
      // For CB: if sign bit set, confidence = 90; else 50.
      predict_confidence_o = (imm_cb_type[31]) ? 8'd90 : 8'd50;
      predict_branch_offset_o = imm_cb_type;
      predict_branch_pc_o = fetch_pc_i + imm_cb_type;
    end
    else begin
      // Non-branch or unrecognized instruction
      predict_branch_type_o = 3'd0;
      predict_confidence_o = 8'd0;
      predict_branch_offset_o = 32'd0;
      predict_branch_pc_o = fetch_pc_i;
    end
  end

  // Branch taken flag: set to 1 if confidence > 50
  assign predict_branch_taken_o = (predict_confidence_o > 8'd50) ? 1'b1 : 1'b0;

  // Exception detection: flag misaligned PC (not 4-byte aligned)
  assign predict_exception_o = (fetch_pc_i[1:0] != 2'b00) ? 1'b1 : 1'b0;

endmodule