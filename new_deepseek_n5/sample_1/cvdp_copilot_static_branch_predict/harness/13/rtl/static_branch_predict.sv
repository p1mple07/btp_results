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

  logic instr_b_taken;
  
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Decode instruction type and calculate immediate
  if (instr[6:0] == 7'h6F) begin
    instr_jal = 1;
    branch_imm = imm_jal_type;
  elsif (instr[6:0] == 7'h67) begin
    instr_jalr = 1;
    branch_imm = imm_jalr_type;
  elsif (instr[6:0] == 7'h63) begin
    instr_b = 1;
    branch_imm = imm_b_type;
  elsif (instr[31:0] == 7'h20 || instr[31:0] == 7'h1F) begin
    instr_cj = 1;
    branch_imm = imm_cj_type;
  else if (instr[31:0] == 7'h21) begin
    instr_cb = 1;
    branch_imm = imm_cb_type;
  end

  // Set branch_taken based on instruction type and immediate
  instr_b_taken = 0;
  if (instr_jal || instr_jalr || instr_cj) begin
    predict_branch_taken_o = 1;
  elsif (instr_b || instr_cb) begin
    if (branch_imm[31] == 1) begin
      predict_branch_taken_o = 1;
    end
  end

  // Calculate predicted branch target address
  predict_branch_pc_o = branch_imm + fetch_pc_i;