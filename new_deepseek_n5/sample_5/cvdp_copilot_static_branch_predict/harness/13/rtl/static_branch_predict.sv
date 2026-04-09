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

  // Instruction decoding and immediate selection
  if (instr[6:0] == 0x6F) begin
    instr_jal = 1;
    imm_jal_type = instr[31:0];
    imm_jalr_type = 0;
    imm_b_type = 0;
    imm_cj_type = 0;
    imm_cb_type = 0;
  elsif (instr[6:0] == 0x67) begin
    instr_jalr = 1;
    imm_jal_type = 0;
    imm_jalr_type = instr[31:0];
    imm_b_type = 0;
    imm_cj_type = 0;
    imm_cb_type = 0;
  elsif (instr[6:0] == 0x63) begin
    instr_b = 1;
    imm_jal_type = 0;
    imm_jalr_type = 0;
    imm_b_type = instr[31:0];
    imm_cj_type = 0;
    imm_cb_type = 0;
  elsif (instr[6:0] == 0x1C) begin
    instr_cj = 1;
    imm_jal_type = 0;
    imm_jalr_type = 0;
    imm_b_type = 0;
    imm_cj_type = instr[31:0];
    imm_cb_type = 0;
  elsif (instr[6:0] == 0x1D) begin
    instr_cb = 1;
    imm_jal_type = 0;
    imm_jalr_type = 0;
    imm_b_type = 0;
    imm_cj_type = 0;
    imm_cb_type = instr[31:0];
  else begin
    branch_imm = imm_b_type;
  end

  // Branch taken decision
  instr_b_taken = 1;
  if (instr_jal || instr_jalr || instr_cj) begin
    instr_b_taken = 1;
  elsif instr_b begin
    instr_b_taken = ~imm_b_type[31];
  elsif instr_cj begin
    instr_b_taken = ~imm_cj_type[31];
  elsif instr_cb begin
    instr_b_taken = ~imm_cb_type[31];
  end

  // Predicted branch taken output
  predict_branch_taken_o = instr_b_taken;

  // Predicted branch target address
  predict_branch_pc_o = branch_imm + fetch_pc_i;