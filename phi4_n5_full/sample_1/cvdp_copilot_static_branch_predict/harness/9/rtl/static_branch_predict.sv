module static_branch_predict (
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,
  output logic [7:0]  predict_confidence_o,
  output logic        predict_exception_o,
  output logic [2:0]  predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o
);

  // Internal registers and wires for immediate extraction
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
  
  // Opcode definitions
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;
  
  // Assign inputs to internal signals
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;
  
  // Immediate extraction for jump and branch instructions
  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  
  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
                         instr[2], instr[11], instr[5:3], 1'b0 };
  
  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
                         instr[4:3], 1'b0};
  
  // Instruction type detection
  assign instr_jal  = (instr[6:0] == OPCODE_JAL);
  assign instr_jalr = (instr[6:0] == OPCODE_JALR);
  assign instr_b    = (instr[6:0] == OPCODE_BRANCH);
  assign instr_cb   = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj   = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));
  
  // Combinational logic for branch prediction using Value Range Propagation
  always_comb begin
    // Default assignments for invalid instructions
    if (!fetch_valid_i) begin
      predict_confidence_o  = 8'd0;
      predict_branch_taken_o = 1'b0;
      predict_branch_pc_o   = fetch_pc_i;
      predict_branch_offset_o = 32'd0;
      predict_branch_type_o = 3'd0;
      predict_exception_o   = 1'b0;
    end else begin
      // Temporary signals for immediate value and confidence probability
      logic [31:0] imm;
      logic [7:0]  prob;
      
      // Determine instruction type and select the corresponding immediate value
      if (instr_jal) begin
         imm = imm_jal_type;
         prob = 8'd100;            // Jump (JAL) always taken
         predict_branch_type_o = 3'b001;
      end else if (instr_jalr) begin
         imm = imm_jalr_type;
         prob = 8'd100;            // Jump (JALR) always taken
         predict_branch_type_o = 3'b010;
      end else if (instr_cj) begin
         imm = imm_cj_type;
         prob = 8'd100;            // Compressed Jump (CJ) always taken
         predict_branch_type_o = 3'b100;
      end else if (instr_cb) begin
         imm = imm_cb_type;
         // For compressed branch: negative offset (MSB = 1) => 90%, positive offset (MSB = 0) => 50%
         if (imm[31])
            prob = 8'd90;
         else
            prob = 8'd50;
         predict_branch_type_o = 3'b101;
      end else if (instr_b) begin
         imm = imm_b_type;
         // For branch instructions: negative offset (MSB = 1) => 90%, positive offset (MSB = 0) => 50%
         if (imm[31])
            prob = 8'd90;
         else
            prob = 8'd50;
         predict_branch_type_o = 3'b011;
      end else begin
         // Fallback for unrecognized instructions
         imm = imm_b_type;
         prob = 8'd0;
         predict_branch_type_o = 3'd0;
      end
      
      // Set confidence level and determine if branch is predicted taken (only if probability > 50%)
      predict_confidence_o = prob;
      predict_branch_taken_o = (prob > 8'd50);
      
      // Output the branch offset and calculate the predicted branch target address
      predict_branch_offset_o = imm;
      predict_branch_pc_o = fetch_pc_i + imm;
      
      // Misalignment detection: if the program counter is not word-aligned, flag an exception
      predict_exception_o = (fetch_pc_i[1:0] != 2'b00);
    end
  end
  
endmodule