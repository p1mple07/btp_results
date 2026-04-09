module static_branch_predict(
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,

  // Additional outputs
  output logic [7:0]  predict_confidence_o,   // Confidence level in prediction
  output logic        predict_exception_o,    // Exception/misalignment detection
  output logic [2:0]  predict_branch_type_o,  // Type of branch
  output logic [31:0] predict_branch_offset_o // Calculated branch offset
);

  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  // Main combinational block for branch prediction and target calculation
  always_comb begin
    // Assign internal registers
    instr    = fetch_rdata_i;
    reg_addr = register_addr_i;

    // Immediate calculations based on instruction fields
    imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
    imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
    imm_b_type   = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
    imm_cj_type  = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
    imm_cb_type  = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };

    // Instruction type decoding
    instr_jal   = (instr[6:0] == 7'h6F);
    instr_jalr  = (instr[6:0] == 7'h67);
    instr_b     = (instr[6:0] == 7'h63);
    // For compressed instructions, we assume:
    //   If not JAL, JALR, or B-type and bit[12] == 1, then CJ;
    //   If not JAL, JALR, or B-type and bit[12] == 0, then CB.
    instr_cj    = (!instr_jal && !instr_jalr && !instr_b && (instr[12] == 1'b1));
    instr_cb    = (!instr_jal && !instr_jalr && !instr_b && (instr[12] == 1'b0));

    // Exception detection: Check if PC is aligned (assumed 2-byte alignment required)
    predict_exception_o = (fetch_pc_i[1:0] != 2'b00) ? 1'b1 : 1'b0;

    if (!fetch_valid_i) begin
      predict_confidence_o    = 8'd0;
      predict_branch_taken_o  = 1'b0;
      predict_branch_pc_o     = fetch_pc_i;
      predict_branch_offset_o = 32'd0;
      predict_branch_type_o   = 3'b000;
    end else begin
      if (instr_jal) begin
        predict_confidence_o    = 8'd100;
        predict_branch_taken_o  = 1'b1;
        predict_branch_offset_o = imm_jal_type;
        predict_branch_pc_o     = fetch_pc_i + imm_jal_type;
        predict_branch_type_o   = 3'b001;
      end else if (instr_jalr) begin
        predict_confidence_o    = 8'd100;
        predict_branch_taken_o  = 1'b1;
        predict_branch_offset_o = imm_jalr_type;
        predict_branch_pc_o     = fetch_pc_i + imm_jalr_type;
        predict_branch_type_o   = 3'b010;
      end else if (instr_b) begin
        predict_confidence_o    = (imm_b_type[31]) ? 8'd90 : 8'd50;
        predict_branch_taken_o  = (imm_b_type[31]);
        predict_branch_offset_o = imm_b_type;
        predict_branch_pc_o     = fetch_pc_i + imm_b_type;
        predict_branch_type_o   = 3'b011;
      end else if (instr_cj) begin
        predict_confidence_o    = 8'd100;
        predict_branch_taken_o  = (imm_cj_type[31]);
        predict_branch_offset_o = imm_cj_type;
        predict_branch_pc_o     = fetch_pc_i + imm_cj_type;
        predict_branch_type_o   = 3'b100;
      end else if (instr_cb) begin
        predict_confidence_o    = (imm_cb_type[31]) ? 8'd90 : 8'd50;
        predict_branch_taken_o  = (imm_cb_type[31]);
        predict_branch_offset_o = imm_cb_type;
        predict_branch_pc_o     = fetch_pc_i + imm_cb_type;
        predict_branch_type_o   = 3'b101;
      end else begin
        // Default case: no recognized branch instruction
        predict_confidence_o    = 8'd0;
        predict_branch_taken_o  = 1'b0;
        predict_branch_offset_o = 32'd0;
        predict_branch_pc_o     = fetch_pc_i;
        predict_branch_type_o   = 3'b000;
      end
    end
  end

endmodule