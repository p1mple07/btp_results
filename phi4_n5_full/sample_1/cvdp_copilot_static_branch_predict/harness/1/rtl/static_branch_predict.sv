module static_branch_predict (
  input  wire [31:0] fetch_rdata_i,  // Fetched 32-bit instruction
  input  wire [31:0] fetch_pc_i,     // Current program counter
  input  wire        fetch_valid_i,  // 1'b1 if the fetched instruction is valid
  output reg  [0:0]  predict_branch_taken_o, // 1'b1 if branch/jump is predicted as taken
  output reg [31:0]  predict_branch_pc_o     // Predicted target address if taken
);

  // Local parameters for opcodes
  localparam OPCODE_BRANCH = 7'h63;
  localparam OPCODE_JAL    = 7'h6F;
  localparam OPCODE_JALR   = 7'h67;

  //-------------------------------------------------------------------------
  // Intermediate signal declarations
  //-------------------------------------------------------------------------

  // Opcode extracted from the lower 7 bits of the instruction.
  wire [6:0] opcode;
  assign opcode = fetch_rdata_i[6:0];

  // Uncompressed branch immediate extraction:
  // For a 32-bit branch instruction, the immediate is:
  //   imm_b_type = {{19{instr[12]}}, instr[12:1], 1'b0};
  wire [31:0] imm_uncompressed_branch;
  assign imm_uncompressed_branch = {{19{fetch_rdata_i[12]}}, fetch_rdata_i[12:1], 1'b0};

  // Compressed branch immediate extraction:
  // For C.BEQZ/C.BNEZ, the equivalent 32-bit uncompressed encoding is:
  //   imm_cb_type = {{7{imm_cb[24]}}, imm_cb}
  // where
  //   imm_cb = { {4{instr[12]}}, instr[6:5], instr[2], 5'b0, 2'b01, instr[9:7],
  //              2'b00, instr[13], instr[11:10], instr[4:3], instr[12] }.
  wire [24:0] imm_cb_temp;
  assign imm_cb_temp = { {4{fetch_rdata_i[12]}},
                         fetch_rdata_i[6:5],
                         fetch_rdata_i[2],
                         5'b0,
                         2'b01,
                         fetch_rdata_i[9:7],
                         2'b00,
                         fetch_rdata_i[13],
                         fetch_rdata_i[11:10],
                         fetch_rdata_i[4:3],
                         fetch_rdata_i[12] };
  wire [31:0] imm_compressed_branch;
  assign imm_compressed_branch = {{7{imm_cb_temp[24]}}, imm_cb_temp};

  // Uncompressed jump (JAL) immediate extraction:
  // For JAL, the immediate is:
  //   imm_j_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
  wire [31:0] imm_jump;
  assign imm_jump = {{12{fetch_rdata_i[31]}},
                     fetch_rdata_i[19:12],
                     fetch_rdata_i[20],
                     fetch_rdata_i[30:21],
                     1'b0};

  // Uncompressed jump register (JALR) immediate extraction:
  // For JALR, the immediate is:
  //   imm_jalr = {{20{instr[31]}}, instr[31:20]};
  wire [31:0] imm_jalr;
  assign imm_jalr = {{20{fetch_rdata_i[31]}}, fetch_rdata_i[31:20]};

  // Signals for final immediate value, branch prediction and target address calculation.
  wire [31:0] branch_imm;
  wire        taken;
  wire [31:0] target;

  //-------------------------------------------------------------------------
  // Combinational logic for branch/jump prediction
  //-------------------------------------------------------------------------

  always_comb begin
    if (!fetch_valid_i) begin
      // When the fetched instruction is not valid, predict not-taken.
      taken    = 1'b0;
      target   = fetch_pc_i;
    end
    else begin
      case (opcode)
        // For branch instructions (BXXX, C.BEQZ, C.BNEZ)
        OPCODE_BRANCH: begin
          // Distinguish between uncompressed and compressed branch.
          // Uncompressed branches have rs2 in bits [24:20] (nonzero typically),
          // while compressed branches have these bits = 5'b00000.
          if (fetch_rdata_i[24:20] == 5'b00000)
            branch_imm = imm_compressed_branch;
          else
            branch_imm = imm_uncompressed_branch;
          // For branch instructions, predict taken if the sign bit of the immediate is 1.
          taken = branch_imm[31];
          // Target address is PC plus the sign-extended immediate.
          target = fetch_pc_i + branch_imm;
        end

        // For jump instructions (JAL, C.JAL) - always predict taken.
        OPCODE_JAL: begin
          branch_imm = imm_jump;
          taken      = 1'b1;
          target     = fetch_pc_i + branch_imm;
        end

        // For jump register instructions (JALR) - always predict taken.
        OPCODE_JALR: begin
          branch_imm = imm_jalr;
          taken      = 1'b1;
          // For JALR, add the rs1 register value (bits [19:15]) to the target.
          target     = fetch_pc_i + branch_imm + fetch_rdata_i[19:15];
        end

        // For any other instructions, predict not-taken.
        default: begin
          taken = 1'b0;
          target = fetch_pc_i;
        end
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------------------------

  // Only drive outputs when fetch_valid_i is high.
  assign predict_branch_taken_o = fetch_valid_i ? taken : 1'b0;
  assign predict_branch_pc_o     = fetch_valid_i ? target   : fetch_pc_i;

endmodule