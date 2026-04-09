module static_branch_predict (
  
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction outputs
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [7:0] predict_confidence_o,
  output logic        predict_exception_o,
  output logic [3:0] predict_branch_type_o
);
  logic [31:0] imm_b_type;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;
  
    
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]}+reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
    instr[2], instr[11], instr[5:3], 1'b0 };

  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
    instr[4:3], 1'b0};

  assign instr_b    = instr[6:0] == OPCODE_BRANCH;
  assign instr_jal  = instr[6:0] == OPCODE_JAL;
  assign instr_jalr = instr[6:0] == OPCODE_JALR;

  assign instr_cb = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));

  always_comb begin
    branch_imm = imm_b_type;

    case(instr_b)
      instr_b : begin
        if (imm_b_type[31] == 1)
          predict_branch_taken_o = 1'b1;
          predict_confidence_o = 8'h90;
        else
          predict_branch_taken_o = 1'b0;
          predict_confidence_o = 8'h50;
      endcase
    case(instr_jal)
      instr_jal : begin
        predict_branch_taken_o = 1'b1;
        predict_confidence_o = 8'h90;
      endcase
    case(instr_jalr)
      instr_jalr : begin
        predict_branch_taken_o = 1'b1;
        predict_confidence_o = 8'h90;
      endcase
    case(instr_cj)
      instr_cj : begin
        if (imm_cb_type[31] == 1)
          predict_branch_taken_o = 1'b1;
          predict_confidence_o = 8'h90;
        else
          predict_branch_taken_o = 1'b0;
          predict_confidence_o = 8'h50;
      endcase
    case(instr_cb)
      instr_cb : begin
        predict_branch_taken_o = 1'b1;
        predict_confidence_o = 8'h90;
      endcase
    default    : begin
        predict_branch_taken_o = 1'b0;
        predict_confidence_o = 8'h50;
      endcase
    endcase
    assign predict_branch_pc_o    = fetch_pc_i + branch_imm; 
    assign instr_b_taken = (instr_b & imm_b_type[31]) | (instr_cb & imm_cb_type[31]);
    assign predict_branch_type_o = (instr_b ? 3'b011 : 
                                 (instr_jal ? 3'b001 : 
                                 (instr_jalr ? 3'b010 : 
                                 (instr_cj ? 3'b100 : 3'b000)));
    assign predict_exception_o = (fetch_pc_i[1:0] != 2'b00);
  end
endmodule
