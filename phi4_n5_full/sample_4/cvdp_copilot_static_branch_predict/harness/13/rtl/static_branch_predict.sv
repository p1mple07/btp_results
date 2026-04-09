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

  // Instruction type flags
  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  // Additional wires for immediate construction
  logic [19:0] imm_jal;         // 20-bit immediate for JAL
  logic [12:0] imm_b_temp;      // 13-bit immediate for B-type (includes MSB)
  logic [11:0] imm_cj_temp;     // 12-bit immediate for CJ
  logic [11:0] imm_cb_temp;     // 12-bit immediate for CB

  // Connect inputs
  assign instr  = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Instruction decoding
  assign instr_jal  = (instr[6:0] == 7'h6F);
  assign instr_jalr = (instr[6:0] == 7'h67);
  // B-type instructions have opcode 0x63. Differentiate CB-type (compressed branch)
  // CB-type: opcode 0x63 with funct3 == 3'b000.
  assign instr_b   = (instr[6:0] == 7'h63) && (instr[14:12] != 3'b000);
  assign instr_cb  = (instr[6:0] == 7'h63) && (instr[14:12] == 3'b000);
  // CJ-type (compressed jump) assumed to have opcode 0x6B.
  assign instr_cj  = (instr[6:0] == 7'h6B);

  // Immediate Calculations

  // JAL: 20-bit immediate: bits[31:20], bits[24:18], bits[15:12], bit[11]
  assign imm_jal = { instr[31:20], instr[24:18], instr[15:12], instr[11] };
  // Sign-extend the 20-bit immediate to 32 bits
  assign imm_jal_type = {{12{imm_jal[19]}}, imm_jal};

  // JALR: 12-bit immediate from bits[31:20] added to register address
  assign imm_jalr_type = reg_addr + {{20{instr[31]}}, instr[31:20]};

  // B-type: 13-bit immediate: MSB is bit[31], then bits[31:25] and bits[11:7]
  assign imm_b_temp = { instr[31], instr[31:25], instr[11:7] };
  // Sign-extend the 13-bit immediate to 32 bits
  assign imm_b_type = {{19{imm_b_temp[12]}}, imm_b_temp};

  // CJ-type: 12-bit immediate: bits[31:25] and bits[11:7]
  assign imm_cj_temp = { instr[31:25], instr[11:7] };
  // Sign-extend the 12-bit immediate to 32 bits
  assign imm_cj_type = {{20{imm_cj_temp[11]}}, imm_cj_temp};

  // CB-type: 12-bit immediate: bits[31:25] and bits[11:7]
  assign imm_cb_temp = { instr[31:25], instr[11:7] };
  // Sign-extend the 12-bit immediate to 32 bits
  assign imm_cb_type = {{20{imm_cb_temp[11]}}, imm_cb_temp};

  // Branch Immediate Selection
  always_comb begin
    // Default to B-type immediate
    branch_imm = imm_b_type;
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
    // Else: remain as default (B-type)
  end

  // Branch Taken Decision
  always_comb begin
    // For JAL, JALR, and CJ instructions, always predict branch taken.
    if (instr_jal || instr_jalr || instr_cj)
      predict_branch_taken_o = 1;
    // For B-type branches, predict taken if sign bit of the immediate is set.
    else if (instr_b)
      predict_branch_taken_o = imm_b_type[31];
    // For CB-type branches, predict taken if sign bit of the immediate is set.
    else if (instr_cb)
      predict_branch_taken_o = imm_cb_type[31];
    else
      predict_branch_taken_o = 0;
  end

  // Branch Target Address Calculation
  assign predict_branch_pc_o = fetch_pc_i + branch_imm;

endmodule