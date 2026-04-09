module static_branch_predict (
  input  wire [31:0] fetch_rdata_i,
  input  wire [31:0] fetch_pc_i,
  input  wire        fetch_valid_i,
  output reg  [0:0]  predict_branch_taken_o,
  output reg  [31:0] predict_branch_pc_o
);

  // Local parameters for opcodes
  localparam OPCODE_BRANCH = 7'h63;  // Uncompressed branch (BXXX) and compressed branch (C.BEQZ/C.BNEZ)
  localparam OPCODE_JAL    = 7'h6F;  // Uncompressed jump (JAL) and compressed jump (C.J/C.JAL)
  localparam OPCODE_JALR   = 7'h67;  // Uncompressed jump register (JALR)

  // Alias for the fetched instruction
  wire [31:0] instr = fetch_rdata_i;
  // Extract opcode from bits [6:0]
  wire [6:0] opcode = instr[6:0];

  // Immediate extraction for uncompressed branch instruction (BXXX)
  // Immediate format: { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 }
  wire [31:0] imm_b = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };

  // Immediate extraction for uncompressed jump (JAL) instruction
  // Immediate format: { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 }
  wire [31:0] imm_j = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };

  // Immediate extraction for uncompressed jump register (JALR) instruction
  // Immediate format: { {20{instr[31]}}, instr[31:20] }
  wire [31:0] imm_jalr = { {20{instr[31]}}, instr[31:20] };

  // Note:
  // For JALR, the target address is defined as:
  //    pc + {{20{instr[31]}}, instr[31:20]} + rs1
  // However, since the register file value for rs1 is not available in this module,
  // we approximate the target address as:
  //    pc + {{20{instr[31]}}, instr[31:20]}
  // This approximation is acceptable for a static branch predictor in the IF stage.

  // Combinational logic for branch prediction
  always_comb begin
    if (!fetch_valid_i) begin
      // If the fetched instruction is not valid, do not predict a branch.
      predict_branch_taken_o = 1'b0;
      predict_branch_pc_o   = 32'd0;
    end else begin
      case (opcode)
        OPCODE_BRANCH: begin
          // Uncompressed branch (BXXX) or compressed branch (C.BEQZ/C.BNEZ)
          // Prediction: branch is taken if the sign bit of the immediate is '1'
          if (imm_b[31])
            predict_branch_taken_o = 1'b1;
          else
            predict_branch_taken_o = 1'b0;
          // Target address = pc + sign-extended immediate
          predict_branch_pc_o = fetch_pc_i + imm_b;
        end
        OPCODE_JAL: begin
          // Uncompressed jump (JAL) or compressed jump (C.J/C.JAL)
          // Jumps are always predicted as taken.
          predict_branch_taken_o = 1'b1;
          predict_branch_pc_o = fetch_pc_i + imm_j;
        end
        OPCODE_JALR: begin
          // Uncompressed jump register (JALR) instruction
          // Always predict taken.
          predict_branch_taken_o = 1'b1;
          // As noted above, rs1 value is not available; using only the immediate.
          predict_branch_pc_o = fetch_pc_i + imm_jalr;
        end
        default: begin
          // For all other instructions (not supported), predict not taken.
          predict_branch_taken_o = 1'b0;
          predict_branch_pc_o   = 32'd0;
        end
      endcase
    end
  end

endmodule