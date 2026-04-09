module static_branch_predict (
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o
);

  // Internal signals for register address and immediate values
  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] branch_imm;
  logic [31:0] instr;

  // Instruction type flags
  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  // Connect inputs
  assign instr   = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Immediate Calculation Assignments
  // For JAL: 20-bit immediate from bits [31:20] with sign extension
  assign imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

  // For JALR: 12-bit immediate from bits [31:20] zero extended then added to register address
  assign imm_jalr_type = reg_addr + {{20{1'b0}}, instr[31:20]};

  // For B-type: 20-bit immediate constructed per RISC-V spec
  assign imm_b_type = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

  // For CJ (Compressed Jump): similar extraction as JAL immediate (example)
  assign imm_cj_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

  // For CB (Compressed Branch): similar extraction as B-type immediate (example)
  assign imm_cb_type = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

  // Branch Prediction Logic (combinational)
  always @(*) begin
    if (fetch_valid_i) begin
      // Decode the instruction based on opcode (bits [6:0])
      if (instr[6:0] == 7'h6F) begin
        // JAL instruction
        branch_imm = imm_jal_type;
        instr_jal  = 1'b1;
        instr_jalr = 1'b0;
        instr_b    = 1'b0;
        instr_cj   = 1'b0;
        instr_cb   = 1'b0;
      end else if (instr[6:0] == 7'h67) begin
        // JALR instruction
        branch_imm = imm_jalr_type;
        instr_jal  = 1'b0;
        instr_jalr = 1'b1;
        instr_b    = 1'b0;
        instr_cj   = 1'b0;
        instr_cb   = 1'b0;
      end else if (instr[6:0] == 7'h63) begin
        // B-type branch instruction
        branch_imm = imm_b_type;
        instr_jal  = 1'b0;
        instr_jalr = 1'b0;
        instr_b    = 1'b1;
        instr_cj   = 1'b0;
        instr_cb   = 1'b0;
      end else begin
        // Compressed instructions: differentiate between CJ and CB using additional bits.
        // (For this example, we assume that if bits [12:7] equal 7'h1F, it is CJ;
        //  if they equal 7'h0F, it is CB; otherwise default to B-type.)
        if (instr[12:7] == 7'h1F) begin
          branch_imm = imm_cj_type;
          instr_cj   = 1'b1;
          instr_cb   = 1'b0;
        end else if (instr[12:7] == 7'h0F) begin
          branch_imm = imm_cb_type;
          instr_cj   = 1'b0;
          instr_cb   = 1'b1;
        end else begin
          // Default to B-type if compressed instruction not recognized
          branch_imm = imm_b_type;
          instr_b    = 1'b1;
        end
      end

      // Branch Taken Decision
      // For JAL, JALR, and CJ the branch is always predicted taken.
      // For B-type and CB, the branch is taken if the sign bit of the immediate is set.
      if (instr_jal || instr_jalr || instr_cj)
        predict_branch_taken_o = 1'b1;
      else if (instr_b || instr_cb)
        predict_branch_taken_o = (branch_imm[31]) ? 1'b1 : 1'b0;
      else
        predict_branch_taken_o = 1'b0;

      // Calculate the predicted branch target address by adding the immediate to the current PC.
      predict_branch_pc_o = fetch_pc_i + branch_imm;
    end else begin
      // When fetch is not valid, drive default values.
      branch_imm      = 32'd0;
      instr_jal       = 1'b0;
      instr_jalr      = 1'b0;
      instr_b         = 1'b0;
      instr_cj        = 1'b0;
      instr_cb        = 1'b0;
      predict_branch_taken_o = 1'b0;
      predict_branch_pc_o   = fetch_pc_i;
    end
  end

endmodule