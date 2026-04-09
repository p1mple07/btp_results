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

  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;

  // Instruction decoding
  always_comb begin
    instr = fetch_rdata_i;

    instr_jal = (instr[6:0] == 7'h6F);
    instr_jalr = (instr[6:0] == 7'h67);
    instr_b = (instr[6:0] == 7'h63);
    instr_cj = (instr[21:16] == 7'h00000000); // Example condition for CJ, replace with actual CJ decoding logic
    instr_cb = (instr[21:16] == 7'h00000000); // Example condition for CB, replace with actual CB decoding logic

    // Offset calculation
    if (instr_jal) begin
      imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    end
    else if (instr_jalr) begin
      imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + register_addr_i;
    end
    else if (instr_b) begin
      imm_b_type =  { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    end
    else if (instr_cj) begin
      imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
    end
    else if (instr_cb) begin
      imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
    end
    else begin
      imm_jal_type = 32'b0;
      imm_jalr_type = 12'b0;
      imm_b_type = 32'b0;
      imm_cj_type = 32'b0;
      imm_cb_type = 32'b0;
    end

    // Branch prediction logic
    predict_branch_taken_o = (instr_b_taken && instr_b) || instr_jal || instr_jalr || instr_cj || instr_cb;

    // Confidence level calculation
    if (instr_b || instr_cj || instr_cb) begin
      predict_confidence_o = 90;
    end
    else if (instr_jal || instr_jalr) begin
      predict_confidence_o = 100;
    end
    else begin
      predict_confidence_o = 0;
    end

    // Exception detection
    predict_exception_o = (fetch_pc_i % 4) != 0;

    // Branch type determination
    predict_branch_type_o = (instr_jal) ? 0 : (instr_jalr) ? 1 : (instr_b) ? 2 : (instr_cj) ? 3 : 4;

    // Branch offset calculation
    case (predict_branch_type_o)
      0: predict_branch_offset_o = imm_jal_type;
      1: predict_branch_offset_o = imm_jalr_type;
      2: predict_branch_offset_o = imm_b_type;
      3: predict_branch_offset_o = imm_cj_type;
      4: predict_branch_offset_o = imm_cb_type;
    endcase

end
