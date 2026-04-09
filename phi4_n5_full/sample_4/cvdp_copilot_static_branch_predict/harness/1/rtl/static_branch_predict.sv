module static_branch_predict (
  input  logic [31:0] fetch_rdata_i,  // Fetched 32-bit instruction
  input  logic [31:0] fetch_pc_i,     // Program counter of the fetched instruction
  input  logic        fetch_valid_i,  // High when the fetched instruction is valid
  output logic        predict_branch_taken_o, // High if branch/jump is predicted taken
  output logic [31:0] predict_branch_pc_o    // Predicted target address (PC + immediate)
);

  //-------------------------------------------------------------------------
  // Local parameters for opcodes
  //-------------------------------------------------------------------------
  localparam OPCODE_BRANCH = 7'h63; // Branch instructions (BXXX)
  localparam OPCODE_JAL    = 7'h6F; // Uncompressed JAL instruction
  localparam OPCODE_JALR   = 7'h67; // Uncompressed JALR instruction

  //-------------------------------------------------------------------------
  // Internal signals
  //-------------------------------------------------------------------------
  logic [31:0] instr;      // Alias for fetch_rdata_i
  logic [31:0] branch_imm; // Sign-extended immediate value
  logic        taken;      // Prediction flag (1 = taken, 0 = not-taken)

  //-------------------------------------------------------------------------
  // Main combinational logic
  //-------------------------------------------------------------------------
  always_comb begin
    // Default assignments
    predict_branch_taken_o = 1'b0;
    predict_branch_pc_o    = 32'd0;
    taken                  = 1'b0;
    branch_imm             = 32'd0;
    instr                  = fetch_rdata_i;

    if (fetch_valid_i) begin
      //-------------------------------------------------------------------------
      // Decode instruction type based on opcode (lower 7 bits)
      //-------------------------------------------------------------------------
      if (instr[6:0] == OPCODE_BRANCH) begin
        //-----------------------------------------------------------------------
        // Branch Instruction (BXXX)
        // Immediate extraction for uncompressed branch:
        //   imm_b_type = {19{instr[31]}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}
        // Prediction: branch is taken if the sign bit (MSB of the immediate) is 1.
        //-----------------------------------------------------------------------
        branch_imm = {19{instr[31]}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        taken      = branch_imm[31];
        
      end else if (instr[6:0] == OPCODE_JAL) begin
        //-----------------------------------------------------------------------
        // Jump Instruction (JAL or compressed jump equivalent)
        // Immediate extraction for uncompressed JAL:
        //   imm_j_type = {12{instr[31]}, instr[19:12], instr[20], instr[30:21], 1'b0}
        // Prediction: always taken.
        //-----------------------------------------------------------------------
        branch_imm = {12{instr[31]}, instr[19:12], instr[20], instr[30:21], 1'b0};
        taken      = 1'b1;
        
      end else if (instr[6:0] == OPCODE_JALR) begin
        //-----------------------------------------------------------------------
        // JALR Instruction
        // Immediate extraction for uncompressed JALR:
        //   imm_jalr_type = {20{instr[31]}, instr[31:20]}
        // Prediction: always taken.
        //-----------------------------------------------------------------------
        branch_imm = {20{instr[31]}, instr[31:20]};
        taken      = 1'b1;
        
      end else begin
        //-----------------------------------------------------------------------
        // For any other instruction, prediction is not taken.
        //-----------------------------------------------------------------------
        taken      = 1'b0;
        branch_imm = 32'd0;
      end

      //-------------------------------------------------------------------------
      // Output assignment: target PC = fetch_pc_i + branch_imm
      //-------------------------------------------------------------------------
      predict_branch_taken_o = taken;
      predict_branch_pc_o    = fetch_pc_i + branch_imm;
    end
    // If fetch_valid_i is low, outputs remain 0.
  end

endmodule