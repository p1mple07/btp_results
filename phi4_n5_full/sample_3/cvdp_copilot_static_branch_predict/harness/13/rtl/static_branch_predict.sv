module static_branch_predict (
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);

  // Internal signals
  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;

  logic [31:0] branch_imm;
  logic [31:0] instr;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  // Decode the fetched instruction
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  always @(*) begin
    // Decode instruction types based on opcode
    instr_jal   = (instr[6:0] == 7'h6F);
    instr_jalr  = (instr[6:0] == 7'h67);
    instr_b     = (instr[6:0] == 7'h63);
    // For compressed instructions, bit[0] is 1.
    if (instr[0] == 1'b1) begin
      // For compressed instructions, bit[12] distinguishes CJ (jump) and CB (branch)
      instr_cj = (instr[12] == 1'b1);
      instr_cb = (instr[12] == 1'b0);
    end else begin
      instr_cj = 1'b0;
      instr_cb = 1'b0;
    end

    // Immediate Calculations
    // JAL immediate: 20-bit immediate sign-extended from bits [31:20]
    imm_jal_type = {{11{instr[31]}}, instr[31:20]};

    // JALR immediate: 12-bit immediate sign-extended from bits [31:20] added to register address
    imm_jalr_type = reg_addr + {{20{instr[31]}}, instr[31:20]};

    // B-type immediate: Constructed from bits [31:25] and [11:7] then shifted left by 1
    imm_b_type = {{19{instr[31]}}, instr[31:25], instr[11:7]} << 1;

    // Compressed instructions immediate calculation (for both CJ and CB)
    if (instr[0] == 1'b1) begin
      imm_cj_type = {{21{instr[12]}}, instr[12:1]} << 1;
      imm_cb_type = {{21{instr[12]}}, instr[12:1]} << 1;
    end else begin
      imm_cj_type = 32'b0;
      imm_cb_type = 32'b0;
    end

    // Branch Immediate Selection
    // Default to B-type immediate if no other branch type is detected
    if (instr_jal)
      branch_imm = imm_jal_type;
    else if (instr_jalr)
      branch_imm = imm_jalr_type;
    else if (instr_b)
      branch_imm = imm_b_type;
    else if (instr_cj)
      branch_imm = imm_cj_type;
    else if (instr_cb)
      branch_imm = imm_cb_type;
    else
      branch_imm = branch_imm + 0;  // No branch: leave as default

    // Branch Taken Decision
    // For JAL, JALR, and CJ instructions, the branch is always predicted taken.
    // For B-type and CB instructions, the branch is predicted taken if the sign bit is set.
    if (instr_jal || instr_jalr || instr_cj)
      predict_branch_taken_o = 1'b1;
    else if (instr_b)
      predict_branch_taken_o = imm_b_type[31];
    else if (instr_cb)
      predict_branch_taken_o = imm_cb_type[31];
    else
      predict_branch_taken_o = 1'b0;

    // Branch Target Address Calculation
    predict_branch_pc_o = fetch_pc_i + branch_imm;
  end

endmodule