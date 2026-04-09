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

  // Internal signals
  logic [31:0] reg_addr;
  logic [31:0] instr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] branch_offset;
  logic [7:0]  confidence;
  logic        taken;
  logic [2:0]  branch_type;

  // Opcode definitions
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  // Assignments for immediate extraction
  assign instr    = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
                         instr[2], instr[11], instr[5:3], 1'b0 };

  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10],
                         instr[4:3], 1'b0};

  // Instruction type detection
  assign instr_b    = (instr[6:0] == OPCODE_BRANCH);
  assign instr_jal  = (instr[6:0] == OPCODE_JAL);
  assign instr_jalr = (instr[6:0] == OPCODE_JALR);
  assign instr_cb   = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b110) | (instr[15:13] == 3'b111));
  assign instr_cj   = (instr[1:0] == 2'b01) & ((instr[15:13] == 3'b101) | (instr[15:13] == 3'b001));

  // Combinational logic for branch prediction using Value Range Propagation
  always_comb begin
    // Default assignments
    confidence   = 8'd0;
    branch_type  = 3'b000;
    branch_offset = 32'd0;
    taken        = 1'b0;

    if (!fetch_valid_i) begin
      // Invalid instruction: default values
      confidence   = 8'd0;
      branch_type  = 3'b000;
      branch_offset = 32'd0;
      taken        = 1'b0;
    end else begin
      // Determine instruction type, branch offset, and confidence
      if (instr_jal) begin
        branch_type  = 3'b001;  // JAL
        branch_offset = imm_jal_type;
        confidence   = 8'd100;  // Jump always taken
      end else if (instr_jalr) begin
        branch_type  = 3'b010;  // JALR
        branch_offset = imm_jalr_type;
        confidence   = 8'd100;  // Jump always taken
      end else if (instr_cj) begin
        branch_type  = 3'b100;  // Compressed Jump
        branch_offset = imm_cj_type;
        confidence   = 8'd100;  // Jump always taken
      end else if (instr_cb) begin
        branch_type  = 3'b101;  // Compressed Branch
        branch_offset = imm_cb_type;
        // For compressed branch: negative offset (MSB==1) => 90%, forward => 50%
        if (imm_cb_type[31])
          confidence = 8'd90;
        else
          confidence = 8'd50;
      end else if (instr_b) begin
        branch_type  = 3'b011;  // Branch
        branch_offset = imm_b_type;
        // For branch: negative offset (MSB==1) => 90%, forward => 50%
        if (imm_b_type[31])
          confidence = 8'd90;
        else
          confidence = 8'd50;
      end else begin
        // Unrecognized instruction: defaults
        branch_type  = 3'b000;
        branch_offset = 32'd0;
        confidence   = 8'd0;
      end

      // Prediction: if confidence > 50 then branch is taken
      if (confidence > 8'd50)
        taken = 1'b1;
      else
        taken = 1'b0;
    end
  end

  // Output assignments
  assign predict_branch_taken_o    = taken;
  assign predict_branch_pc_o       = fetch_pc_i + branch_offset;
  assign predict_confidence_o      = confidence;
  assign predict_exception_o       = (fetch_pc_i[1:0] != 2'b00);
  assign predict_branch_type_o     = branch_type;
  assign predict_branch_offset_o   = branch_offset;

endmodule