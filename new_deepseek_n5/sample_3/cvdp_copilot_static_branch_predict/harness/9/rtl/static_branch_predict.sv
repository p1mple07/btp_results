module static_branch_predict (
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
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

  logic [31:0] instr_b_taken;
  logic [31:0] instr_jal_taken;
  logic [31:0] instr_jalr_taken;
  logic [31:0] instr_cb_taken;

  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  assign instr_b_taken = (instr_b & imm_b_type[31]) | (instr_cb & imm_cb_type[31]);
  assign instr_jal_taken = instr_jal  & imm_jal_type[31];
  assign instr_jalr_taken = instr_jalr & imm_jalr_type[31];
  assign instr_cb_taken = instr_cb   & imm_cb_type[31];

  always_comb begin
    branch_imm = imm_b_type;

    case(1'b1)
      instr_jal_taken : branch_imm = imm_jal_type;
      instr_jalr_taken : branch_imm = imm_jalr_type;
      instr_b_taken : branch_imm = imm_b_type;
      instr_cb_taken : branch_imm = imm_cb_type;
      default    : branch_imm = 0;
    endcase

    if (fetch_valid_i)
      predict_branch_pc_o = fetch_pc_i + branch_imm;
    else
      predict_branch_pc_o = fetch_pc_i;
      predict_exception_o = 1;
      predict_branch_taken_o = 0;
      predict_branch_pc_o = 0;
    end

    case(1'b1)
      instr_jal_taken : predict_branch_taken_o = 1;
      instr_jalr_taken : predict_branch_taken_o = 1;
      instr_b_taken : predict_branch_taken_o = (imm_b_type[31] == 1) ? 1 : 0;
      instr_cb_taken : predict_branch_taken_o = (imm_cb_type[31] == 1) ? 1 : 0;
      default : predict_branch_taken_o = 0;
    endcase

    case(1'b1)
      instr_jal_taken : predict_branch_type_o = 3'h001;
      instr_jalr_taken : predict_branch_type_o = 3'h010;
      instr_b_taken : predict_branch_type_o = 3'h011;
      instr_cb_taken : predict_branch_type_o = 3'h101;
      default : predict_branch_type_o = 3'h000;
    endcase

    case(1'b1)
      instr_jal_taken : predict_branch_offset_o = imm_jal_type;
      instr_jalr_taken : predict_branch_offset_o = imm_jalr_type;
      instr_b_taken : predict_branch_offset_o = imm_b_type;
      instr_cb_taken : predict_branch_offset_o = imm_cb_type;
      default : predict_branch_offset_o = 0;
    endcase

    if (fetch_valid_i)
      predict_confidence_o = (imm_b_type[31] == 1) ? 8'd90 : 8'd50;
    else
      predict_confidence_o = 0;
    end
  end
  assign predict_exception_o = (fetch_pc_i[1:0] != 2'b00);
endmodule