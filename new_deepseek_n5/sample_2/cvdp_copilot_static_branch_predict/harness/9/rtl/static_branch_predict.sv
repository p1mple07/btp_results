module static_branch_predict (
  
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [8:0]  predict_confidence_o,
  output logic [1:0]  predict_exception_o,
  output logic [2:0]  predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o);
  
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
  logic [3:2] inst_type;

  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:25], instr[11:8], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]}+reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
    instr[2], instr[11], instr[5:3], 1'b0 };

  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
    instr[4:3], 1'b0 };

  assign instr_b    = instr[6:0] == OPCODE_BRANCH;
  assign instr_jal  = instr[6:0] == OPCODE_JAL;
  assign instr_jalr = instr[6:0] == OPCODE_JALR;

  assign inst_type = case(instr[6:0])
    6'b000000 -> 3'b000;
    6'b000001 -> 3'b001;
    6'b000010 -> 3'b010;
    6'b000011 -> 3'b011;
    6'b000100 -> 3'b100;
    default -> 3'b101;
  endcase;

  always_comb begin
    branch_imm = imm_b_type;

    case(1'b1)
      instr_jal  : branch_imm = imm_jal_type;
      instr_jalr : branch_imm = imm_jalr_type;
      instr_b    : branch_imm = imm_b_type;
      instr_cj   : branch_imm = imm_cj_type;
      instr_cb   : branch_imm = imm_cb_type;
      default    : ;
    endcase

    predict_confidence_o = 8'd0;
    predict_exception_o = 1'b0;
    predict_branch_taken_o = 1'b0;
    predict_branch_type_o = 3'b000;

    local reg [31:0] target_address;

    if (fetch_valid_i) begin
      case (fetch_pc_i[1:0])
        00 -> predict_exception_o = 1'b1;
      endcase

      if (instr_jal || instr_jalr || instr_b) begin
        case (imm_b_type[31])
          1'b1 -> predict_confidence_o = 8'd90;
          1'b0 -> predict_confidence_o = 8'd50;
        endcase
        predict_branch_taken_o = (instr_jal || instr_jalr || instr_b);
        predict_branch_type_o = inst_type;
        target_address = fetch_pc_i + branch_imm;
        predict_branch_pc_o = target_address;
      elsif (instr_cj || instr_cb) begin
        case (imm_cb_type[31])
          1'b1 -> predict_confidence_o = 8'd90;
          1'b0 -> predict_confidence_o = 8'd50;
        endcase
        predict_branch_taken_o = (instr_cj || instr_cb);
        predict_branch_type_o = inst_type;
        target_address = fetch_pc_i + branch_imm;
        predict_branch_pc_o = target_address;
      else begin
        predict_confidence_o = 8'd0;
        predict_branch_taken_o = 1'b0;
        predict_branch_type_o = inst_type;
      endelse
    end
  end
  assign predict_branch_pc_o = target_address;
endmodule