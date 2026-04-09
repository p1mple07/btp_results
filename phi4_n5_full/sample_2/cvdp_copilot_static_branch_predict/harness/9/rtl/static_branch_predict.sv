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
  
  // Internal signals for immediate extraction and instruction decoding
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

  // Opcode definitions
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  // Connect inputs to internal signals
  assign instr  = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Immediate extraction for jump and branch instructions
  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
                          instr[2], instr[11], instr[5:3], 1'b0 };

  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
                          instr[4:3], 1'b0};

  // Instruction type detection based on opcode and compressed format
  assign instr_b    = (instr[6:0] == OPCODE_BRANCH);
  assign instr_jal  = (instr[6:0] == OPCODE_JAL);
  assign instr_jalr = (instr[6:0] == OPCODE_JALR);

  assign instr_cb = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));

  // Combinational logic implementing Value Range Propagation for static branch prediction
  always_comb begin
    // Default assignments for outputs
    predict_branch_taken_o     = 1'b0;
    predict_confidence_o       = 8'd0;
    predict_branch_type_o      = 3'd0;
    predict_branch_offset_o    = 32'd0;
    branch_imm                 = 32'd0;

    if(fetch_valid_i) begin
      if(instr_jal) begin
         branch_imm = imm_jal_type;
         predict_confidence_o = 8'd100;  // Jump instructions always predicted taken
         predict_branch_type_o = 3'b001; // JAL type
      end else if(instr_jalr) begin
         branch_imm = imm_jalr_type;
         predict_confidence_o = 8'd100;  // JALR always predicted taken
         predict_branch_type_o = 3'b010; // JALR type
      end else if(instr_b) begin
         branch_imm = imm_b_type;
         // For branch instructions: negative offset (backward) gets 90% confidence; forward gets 50%
         if(imm_b_type[31])
            predict_confidence_o = 8'd90;
         else
            predict_confidence_o = 8'd50;
         predict_branch_type_o = 3'b011; // Branch type
      end else if(instr_cj) begin
         branch_imm = imm_cj_type;
         predict_confidence_o = 8'd100;  // Compressed jump always taken
         predict_branch_type_o = 3'b100; // Compressed Jump type
      end else if(instr_cb) begin
         branch_imm = imm_cb_type;
         // For compressed branch: negative offset gets 90% confidence; forward gets 50%
         if(imm_cb_type[31])
            predict_confidence_o = 8'd90;
         else
            predict_confidence_o = 8'd50;
         predict_branch_type_o = 3'b101; // Compressed Branch type
      end else begin
         // For unrecognized instructions, defaults remain (0% confidence, not taken)
      end

      // Prediction decision: if confidence > 50%, predict branch taken
      if(predict_confidence_o > 8'd50)
         predict_branch_taken_o = 1'b1;
      else
         predict_branch_taken_o = 1'b0;

      // Output the branch offset as the extracted immediate value
      predict_branch_offset_o = branch_imm;
    end
  end

  // Calculate the predicted target address by adding the sign-extended immediate to the fetch PC
  assign predict_branch_pc_o = fetch_pc_i + branch_imm;

  // Misalignment detection: if fetch_pc_i is not word aligned (lower 2 bits not zero), flag an exception
  assign predict_exception_o = (fetch_pc_i[1:0] != 2'b00);

endmodule