module static_branch_predict (
    input  logic [31:0] fetch_rdata_i,  // Fetched 32-bit instruction
    input  logic [31:0] fetch_pc_i,     // Current program counter
    input  logic        fetch_valid_i,  // Indicates valid instruction
    output logic        predict_branch_taken_o, // 1 if branch/jump is predicted taken
    output logic [31:0] predict_branch_pc_o    // Predicted target address
);

  // Local parameters for instruction opcodes
  localparam logic [6:0] OPCODE_BRANCH = 7'h63; // Uncompressed branch (BXXX, C.BEQZ/C.BNEZ)
  localparam logic [6:0] OPCODE_JAL    = 7'h6F; // Uncompressed jump (JAL, C.JAL)
  localparam logic [6:0] OPCODE_JALR   = 7'h67; // Uncompressed jump and link register (JALR)

  // Wires for immediate extraction and prediction logic
  logic [31:0] imm_j_type;  // Immediate for jump instructions (JAL or JALR)
  logic [31:0] imm_b_type;  // Immediate for branch instructions (BXXX or compressed branch)
  logic        taken;       // Internal signal: 1 if branch/jump is predicted taken
  logic [31:0] branch_imm;  // Final immediate/sign-extended offset used for target address calculation

  always_comb begin
    // Default assignments
    predict_branch_taken_o = 1'b0;
    predict_branch_pc_o    = 32'd0;
    taken                  = 1'b0;
    branch_imm             = 32'd0;

    if (fetch_valid_i) begin
      // Decode the opcode from bits [6:0] of the instruction
      case (fetch_rdata_i[6:0])
        // For jump instructions (JAL or C.JAL): Always predict as taken.
        OPCODE_JAL: begin
          // Immediate extraction for JAL:
          // {imm[20], imm[10:1], imm[11], imm[30:21], 1'b0} sign-extended with {{12{instr[31]}}}
          imm_j_type = {{12{fetch_rdata_i[31]}}, fetch_rdata_i[19:12], fetch_rdata_i[20], fetch_rdata_i[30:21], 1'b0};
          taken      = 1'b1;
          branch_imm = imm_j_type;
        end

        // For jump and link register (JALR): Always predict as taken.
        OPCODE_JALR: begin
          // Immediate extraction for JALR:
          // {imm[11:0]} sign-extended with {{20{instr[31]}}}
          imm_j_type = {{20{fetch_rdata_i[31]}}, fetch_rdata_i[31:20]};
          taken      = 1'b1;
          branch_imm = imm_j_type;
        end

        // For branch instructions (BXXX, C.BEQZ/C.BNEZ):
        OPCODE_BRANCH: begin
          // Immediate extraction for branch:
          // {imm[12], imm[10:5], imm[4:1], imm[11]} with sign extension:
          // imm_b_type = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
          imm_b_type = {{19{fetch_rdata_i[31]}}, fetch_rdata_i[31], fetch_rdata_i[7],
                        fetch_rdata_i[30:25], fetch_rdata_i[11:8], 1'b0};
          // For static branch prediction, if the sign bit of the immediate is 1, predict branch as taken.
          taken      = imm_b_type[31];
          branch_imm = imm_b_type;
        end

        // For any other instruction, do not predict as taken.
        default: begin
          taken      = 1'b0;
          branch_imm = 32'd0;
        end
      endcase

      // Calculate the predicted target address by adding the sign-extended immediate to the current PC.
      predict_branch_taken_o = taken;
      predict_branch_pc_o    = fetch_pc_i + branch_imm;
    end
  end

endmodule