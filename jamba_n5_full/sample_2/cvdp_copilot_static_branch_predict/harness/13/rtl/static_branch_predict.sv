module static_branch_predict (
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

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

  // Branch type decoding
  assign instr_jal = (opcode == 7'h6F);
  assign instr_jalr = (opcode == 7'h67);
  assign instr_b = (instr[6:0] == 7'h63);
  assign instr_cj = (instr[6:0] == 7'h6A); // CJ opcode is 7'h6A
  assign instr_cb = (instr[6:0] == 7'h69);

  // Determine branch_imm
  assign branch_imm = (instr_jal) ? imm_jal_type : 
                     (instr_jalr) ? imm_jalr_type : 
                     (instr_b) ? imm_b_type : 
                     (instr_cj) ? imm_cj_type : 
                     (instr_cb) ? imm_cb_type : 
                     branch_imm + 0;

  assign predict_branch_taken_o = (instr_b_taken) || (instr_jal || instr_jalr || instr_cj);
  assign predict_branch_pc_o = fetch_pc_i + branch_imm;

endmodule
