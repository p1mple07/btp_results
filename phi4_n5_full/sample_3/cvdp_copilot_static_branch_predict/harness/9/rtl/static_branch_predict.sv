module static_branch_predict (
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,
  
  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [7:0]  predict_confidence_o,
  output logic        predict_exception_o,
  output logic [2:0]  predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o
);

  // Local parameters for opcodes
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;
  
  // Intermediate signals for immediate extraction
  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  
  logic [31:0] instr;
  
  // Instruction type detection signals
  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;
  
  // Signals for branch prediction using Value Range Propagation
  logic [31:0] branch_imm;
  logic [2:0]  branch_type;
  logic [7:0]  confidence;
  logic        branch_taken;
  logic [31:0] branch_offset;
  
  // Immediate extraction assignments
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;
  
  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  
  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
                         instr[2], instr[11], instr[5:3], 1'b0 };
  
  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
                         instr[4:3], 1'b0 };
  
  // Instruction type detection
  assign instr_b    = (instr[6:0] == OPCODE_BRANCH);
  assign instr_jal  = (instr[6:0] == OPCODE_JAL);
  assign instr_jalr = (instr[6:0] == OPCODE_JALR);
  
  assign instr_cb = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));
  
  // Combinational block implementing Value Range Propagation prediction
  always_comb begin
    if (!fetch_valid_i) begin
      branch_imm   = 32'd0;
      branch_type  = 3'd0;
      confidence   = 8'd0;
      branch_taken = 1'b0;
      branch_offset = 32'd0;
    end else begin
      case (1'b1)
        instr_jal: begin
          branch_imm   = imm_jal_type;
          branch_type  = 3'b001;  // JAL
          confidence   = 8'd100;  // Jump always taken with 100% confidence
        end
        instr_jalr: begin
          branch_imm   = imm_jalr_type;
          branch_type  = 3'b010;  // JALR
          confidence   = 8'd100;  // Jump always taken with 100% confidence
        end
        instr_cj: begin
          branch_imm   = imm_cj_type;
          branch_type  = 3'b100;  // Compressed Jump
          confidence   = 8'd100;  // Jump always taken with 100% confidence
        end
        instr_b: begin
          branch_imm   = imm_b_type;
          branch_type  = 3'b011;  // Branch
          // For branch instructions: negative offset (MSB = 1) => 90% confidence; positive offset (MSB = 0) => 50% confidence
          confidence   = (imm_b_type[31]) ? 8'd90 : 8'd50;
        end
        instr_cb: begin
          branch_imm   = imm_cb_type;
          branch_type  = 3'b101;  // Compressed Branch
          // For compressed branch: negative offset => 90% confidence; positive offset => 50% confidence
          confidence   = (imm_cb_type[31]) ? 8'd90 : 8'd50;
        end
        default: begin
          branch_imm   = 32'd0;
          branch_type  = 3'd0;
          confidence   = 8'd0;
        end
      endcase
      
      // Prediction decision: if confidence exceeds 50%, branch is predicted taken.
      branch_taken = (confidence > 8'd50) ? 1'b1 : 1'b0;
      branch_offset = branch_imm;
    end
  end
  
  // Output assignments
  assign predict_branch_pc_o    = fetch_pc_i + branch_imm; 
  assign predict_branch_taken_o = branch_taken;
  assign predict_confidence_o   = confidence;
  assign predict_exception_o    = (fetch_pc_i[1:0] != 2'b00);  // Misalignment detection
  assign predict_branch_type_o  = branch_type;
  assign predict_branch_offset_o= branch_offset;
  
endmodule