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

  // Internal registers and wires
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
  logic instr_compressed;
  logic instr_cj;
  logic instr_cb;

  // Assign internal registers
  assign reg_addr = register_addr_i;
  assign instr    = fetch_rdata_i;

  // Instruction decoding
  assign instr_jal  = (instr[6:0] == 7'h6F);  // JAL opcode
  assign instr_jalr = (instr[6:0] == 7'h67);  // JALR opcode
  assign instr_b    = (instr[6:0] == 7'h63);  // B-type branch opcode
  assign instr_compressed = ~(instr_jal | instr_jalr | instr_b);
  // For compressed instructions, use bit[12] to distinguish CJ vs CB
  assign instr_cj   = instr_compressed ? instr[12] : 1'b0;
  assign instr_cb   = instr_compressed ? ~instr[12] : 1'b0;

  // Immediate calculations according to specification
  assign imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  assign imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  assign imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  assign imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
  assign imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };

  // Combinational logic for branch prediction, target calculation, and exception detection
  always_comb begin
      // Default assignments
      predict_confidence_o   = 8'd0;
      predict_branch_taken_o = 1'b0;
      predict_branch_pc_o    = 32'd0;
      predict_branch_type_o  = 3'b111; // Unknown type
      predict_branch_offset_o= 32'd0;
      predict_exception_o    = 1'b0;

      if (fetch_valid_i) begin
          if (instr_jal) begin
              // JAL: Always taken with full confidence
              predict_branch_type_o  = 3'b000; // Encoding for JAL
              predict_confidence_o   = 8'd100;
              predict_branch_taken_o = 1'b1;
              predict_branch_offset_o= imm_jal_type;
          end else if (instr_jalr) begin
              // JALR: Always taken with full confidence
              predict_branch_type_o  = 3'b001; // Encoding for JALR
              predict_confidence_o   = 8'd100;
              predict_branch_taken_o = 1'b1;
              predict_branch_offset_o= imm_jalr_type;
          end else if (instr_b) begin
              // B-type: Prediction based on sign bit of immediate
              predict_branch_type_o  = 3'b010; // Encoding for B-type
              if (imm_b_type[31])
                  predict_confidence_o = 8'd90;
              else
                  predict_confidence_o = 8'd50;
              predict_branch_taken_o = (imm_b_type[31]) ? 1'b1 : 1'b0;
              predict_branch_offset_o= imm_b_type;
          end else if (instr_cj) begin
              // CJ: Prediction based on sign bit of immediate
              predict_branch_type_o  = 3'b011; // Encoding for CJ
              if (imm_cj_type[31])
                  predict_confidence_o = 8'd90;
              else
                  predict_confidence_o = 8'd50;
              predict_branch_taken_o = (imm_cj_type[31]) ? 1'b1 : 1'b0;
              predict_branch_offset_o= imm_cj_type;
          end else if (instr_cb) begin
              // CB: Prediction based on sign bit of immediate
              predict_branch_type_o  = 3'b100; // Encoding for CB
              if (imm_cb_type[31])
                  predict_confidence_o = 8'd90;
              else
                  predict_confidence_o = 8'd50;
              predict_branch_taken_o = (imm_cb_type[31]) ? 1'b1 : 1'b0;
              predict_branch_offset_o= imm_cb_type;
          end else begin
              // No recognized branch instruction; default to unknown type
              predict_branch_type_o = 3'b111;
          end

          // Calculate predicted branch target address by adding the offset to the current PC
          predict_branch_pc_o = fetch_pc_i + predict_branch_offset_o;
      end

      // Exception detection: Check if the PC is properly aligned (assumed 4-byte alignment)
      if (fetch_pc_i[1:0] != 2'b00)
          predict_exception_o = 1'b1;
      else
          predict_exception_o = 1'b0;
  end

endmodule