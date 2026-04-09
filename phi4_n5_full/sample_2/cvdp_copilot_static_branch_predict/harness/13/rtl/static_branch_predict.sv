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

  // Assign fetched values
  assign instr  = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  // Combinational logic for branch prediction
  always_comb begin
      // Calculate immediates based on instruction format

      // JAL immediate: bits [31:20] sign-extended, bits [19:12], bit[20], bits[30:21], and LSB = 0
      imm_jal_type = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

      // JALR immediate: 12-bit immediate sign-extended, then added to register address
      imm_jalr_type = reg_addr + {{20{instr[31]}}, instr[31:20]};

      // B-type immediate: sign-extend bit31, then bits [7], [30:25], [11:8], and LSB = 0
      imm_b_type = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

      // CJ immediate: for compressed jump, extract immediate from bits [15:2]
      imm_cj_type = {{14{instr[15]}}, instr[12:10], instr[6:2], 1'b0};

      // CB immediate: for compressed branch, extract immediate similarly
      imm_cb_type = {{14{instr[15]}}, instr[12:10], instr[6:2], 1'b0};

      // Decode instruction types based on opcode fields
      instr_jal  = (instr[6:0] == 7'h6F);  // JAL
      instr_jalr = (instr[6:0] == 7'h67);  // JALR
      instr_b    = (instr[6:0] == 7'h63);  // B-type branch

      // For compressed instructions, use bits [15:13]
      instr_cj   = (instr[15:13] == 3'b110); // CJ compressed jump
      instr_cb   = (instr[15:13] == 3'b111); // CB compressed branch

      // Select branch immediate based on the decoded instruction type
      if (instr_jal) begin
          branch_imm = imm_jal_type;
      end else if (instr_jalr) begin
          branch_imm = imm_jalr_type;
      end else if (instr_b) begin
          branch_imm = imm_b_type;
      end else if (instr_cj) begin
          branch_imm = imm_cj_type;
      end else if (instr_cb) begin
          branch_imm = imm_cb_type;
      end else begin
          // Default fallback (should not occur for branch instructions)
          branch_imm = imm_b_type;
      end

      // Branch taken decision
      // For JAL, JALR, and CJ, branch is always predicted as taken.
      if (instr_jal || instr_jalr || instr_cj) begin
          predict_branch_taken_o = 1'b1;
      end
      // For B-type and CB-type, branch is taken if the sign bit of the immediate is set.
      else if (instr_b || instr_cb) begin
          predict_branch_taken_o = (instr_b ? imm_b_type[31] : 1'b0) |
                                   (instr_cb ? imm_cb_type[31] : 1'b0);
      end
      else begin
          predict_branch_taken_o = 1'b0;
      end

      // Calculate predicted branch target address by adding the immediate to the current PC
      predict_branch_pc_o = fetch_pc_i + branch_imm;
  end

endmodule