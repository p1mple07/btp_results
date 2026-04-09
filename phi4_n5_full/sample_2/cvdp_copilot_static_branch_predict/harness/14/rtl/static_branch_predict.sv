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

  // Combinational always block for branch prediction logic
  always_comb begin
    // Default assignments when fetch is not valid
    if (!fetch_valid_i) begin
      predict_confidence_o   = 8'd0;
      predict_branch_taken_o = 1'b0;
      predict_branch_pc_o    = 32'd0;
      predict_exception_o    = 1'b0;
      predict_branch_type_o  = 3'd0;
      predict_branch_offset_o= 32'd0;
    end
    else begin
      // Assign internal registers
      instr  = fetch_rdata_i;
      reg_addr = register_addr_i;

      // Decode the instruction type based on opcode bits
      instr_jal  = (instr[6:0] == 7'h6F); // JAL
      instr_jalr = (instr[6:0] == 7'h67); // JALR
      instr_b    = (instr[6:0] == 7'h63); // B-type

      // For compressed instructions, assume that if none of the above match,
      // then the instruction is compressed. Use bit[12] to differentiate:
      //   - CJ: if instr[12] == 1
      //   - CB: if instr[12] == 0
      instr_cj = (~instr_jal & ~instr_jalr & ~instr_b) & (instr[12] == 1);
      instr_cb = (~instr_jal & ~instr_jalr & ~instr_b) & (instr[12] == 0);

      // Calculate immediate values based on instruction type
      if (instr_jal) begin
        imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
        imm_jalr_type = '0;
        imm_b_type = '0;
        imm_cj_type = '0;
        imm_cb_type = '0;
      end
      else if (instr_jalr) begin
        imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
        imm_jal_type = '0;
        imm_b_type = '0;
        imm_cj_type = '0;
        imm_cb_type = '0;
      end
      else if (instr_b) begin
        imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
        imm_jal_type = '0;
        imm_jalr_type = '0;
        imm_cj_type = '0;
        imm_cb_type = '0;
      end
      else if (instr_cj) begin
        imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7],
                        instr[2], instr[11], instr[5:3], 1'b0 };
        imm_jal_type = '0;
        imm_jalr_type = '0;
        imm_b_type = '0;
        imm_cb_type = '0;
      end
      else if (instr_cb) begin
        imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
        imm_jal_type = '0;
        imm_jalr_type = '0;
        imm_b_type = '0;
        imm_cj_type = '0;
      end

      // Default assignments for outputs
      predict_branch_pc_o    = fetch_pc_i;
      predict_confidence_o   = 8'd0;
      predict_branch_taken_o = 1'b0;
      predict_branch_type_o  = 3'd0;
      predict_branch_offset_o= 32'd0;

      // Exception detection: check for proper PC alignment (assumed 4-byte alignment)
      predict_exception_o = (fetch_pc_i[1:0] != 2'b00);

      // Branch prediction decision and target address calculation
      if (instr_jal) begin
        // JAL: always taken with full confidence
        predict_branch_type_o  = 3'b000; // Encoding for JAL
        predict_confidence_o   = 8'd100;
        predict_branch_taken_o = 1'b1;
        predict_branch_offset_o= imm_jal_type;
        predict_branch_pc_o    = fetch_pc_i + imm_jal_type;
      end
      else if (instr_jalr) begin
        // JALR: always taken with full confidence
        predict_branch_type_o  = 3'b001; // Encoding for JALR
        predict_confidence_o   = 8'd100;
        predict_branch_taken_o = 1'b1;
        predict_branch_offset_o= imm_jalr_type;
        predict_branch_pc_o    = fetch_pc_i + imm_jalr_type;
      end
      else if (instr_b) begin
        // B-type: taken if sign bit of immediate is set, otherwise not taken
        predict_branch_type_o  = 3'b010; // Encoding for B-type
        if (imm_b_type[31]) begin
          predict_confidence_o   = 8'd90;
          predict_branch_taken_o = 1'b1;
        end
        else begin
          predict_confidence_o   = 8'd50;
          predict_branch_taken_o = 1'b0;
        end
        predict_branch_offset_o= imm_b_type;
        predict_branch_pc_o    = fetch_pc_i + imm_b_type;
      end
      else if (instr_cj) begin
        // CJ: similar logic as B-type using imm_cj_type
        predict_branch_type_o  = 3'b011; // Encoding for CJ
        if (imm_cj_type[31]) begin
          predict_confidence_o   = 8'd90;
          predict_branch_taken_o = 1'b1;
        end
        else begin
          predict_confidence_o   = 8'd50;
          predict_branch_taken_o = 1'b0;
        end
        predict_branch_offset_o= imm_cj_type;
        predict_branch_pc_o    = fetch_pc_i + imm_cj_type;
      end
      else if (instr_cb) begin
        // CB: similar logic as B-type using imm_cb_type
        predict_branch_type_o  = 3'b100; // Encoding for CB
        if (imm_cb_type[31]) begin
          predict_confidence_o   = 8'd90;
          predict_branch_taken_o = 1'b1;
        end
        else begin
          predict_confidence_o   = 8'd50;
          predict_branch_taken_o = 1'b0;
        end
        predict_branch_offset_o= imm_cb_type;
        predict_branch_pc_o    = fetch_pc_i + imm_cb_type;
      end
      else begin
        // If none of the known branch types match, assume no branch
        predict_branch_type_o  = 3'b000;
        predict_confidence_o   = 8'd0;
        predict_branch_taken_o = 1'b0;
        predict_branch_offset_o= 32'd0;
        predict_branch_pc_o    = fetch_pc_i;
      end
    end
  end

endmodule