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

  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  assign imm_jal_type = {{12{fetch_rdata_i}},fetch_rdata_i[19:12],fetch_rdata_i[20],fetch_rdata_i[30:21],1'b0 };
  assign imm_jalr_type = {{20{fetch_rdata_i}},fetch_rdata_i[31:20]+register_addr_i;
  assign imm_b_type = { {19{fetch_rdata_i}},fetch_rdata_i[31],fetch_rdata_i[7],fetch_rdata_i[30:25],fetch_rdata_i[11:8],1'b0 };
  assign imm_cj_type = { {20{fetch_rdata_i}},fetch_rdata_i[12],fetch_rdata_i[8],fetch_rdata_i[10:9],fetch_rdata_i[6],fetch_rdata_i[7],
    fetch_rdata_i[2],fetch_rdata_i[11],fetch_rdata_i[5:3],1'b0 };
  assign imm_cb_type = { {23{fetch_rdata_i}},fetch_rdata_i[12],fetch_rdata_i[6],fetch_rdata_i[2],fetch_rdata_i[11:10],
    fetch_rdata_i[4:3],1'b0};

  assign instr = fetch_rdata_i;
  assign instr_jal  = instr[6:0] == OPCODE_JAL;
  assign instr_jalr = instr[6:0] == OPCODE_JALR;

  assign instr_b    = instr[6:0] == OPCODE_BRANCH;
  assign instr_cb   = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));

  always_comb begin
    case(instr[6:0])
      OPCODE_BRANCH : begin
        if (imm_b_type[31] == 1)
          predict_branch_taken_o = 1; // Backward branch, high probability
        else
          predict_branch_taken_o = instr_b & imm_b_type[31]; // Forward branch, 50% probability
      end
      OPCODE_JAL    : begin
        predict_branch_taken_o = 1; // Jump instruction, 100% probability
      end
      OPCODE_JALR   : begin
        predict_branch_taken_o = 1; // JALR instruction, 100% probability
      end
      default     : begin
        predict_branch_taken_o = fetch_valid_i & (instr_jal | instr_jalr | instr_cj | instr_b_taken);
      end
    endcase

    assign predict_branch_pc_o    = fetch_pc_i + imm_b_type;
    assign predict_confidence_o = (predict_branch_taken_o ? 8'd90 : 8'd50); // Higher confidence for backward branches
    assign predict_exception_o = (fetch_pc_i[1:0] != 2'b00);
    assign predict_branch_type_o = (instr[6:0] == OPCODE_BRANCH) ? 3'b011 :
                                 (instr[6:0] == OPCODE_JAL) ? 3'b001 :
                                 (instr[6:0] == OPCODE_JALR) ? 3'b010 : 3'b000;
  end

  assign imm_b_type = { {19{fetch_rdata_i}},fetch_rdata_i[31],fetch_rdata_i[7],fetch_rdata_i[30:25],fetch_rdata_i[11:8],1'b0 };

  assign branch_imm = imm_b_type;

  assign instr_b_taken = (instr_b & imm_b_type[31]) | (instr_cb & imm_cb_type[31]);

  // Target Address Calculation
  assign predict_branch_pc_o    = fetch_pc_i + branch_imm; 
endmodule
