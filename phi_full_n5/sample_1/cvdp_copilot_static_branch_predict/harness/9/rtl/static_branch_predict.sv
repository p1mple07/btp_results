module static_branch_predict (
  
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction outputs
  output logic [7:0] predict_confidence_o,
  output logic [1:0] predict_exception_o,
  output logic [3:0] predict_branch_type_o,
  output logic [31:0] predict_branch_offset_o,

  // Instruction types
  output logic [31:0] imm_jal_type,
  output logic [31:0] imm_jalr_type,
  output logic [31:0] imm_b_type,
  output logic [31:0] imm_cj_type,
  output logic [31:0] imm_cb_type,

  output logic predict_branch_taken_o,

  // Branch prediction logic
  always_comb begin
    case(fetch_valid_i)
     1'b1 : begin
        // Jump instructions
        if (instr[1:0] == 3'b001 || instr[1:0] == 3'b010) begin
          predict_branch_type_o = {3'b011, fetch_rdata_i[15:13]};
          if (fetch_rdata_i[15:13] == 3'b110 || fetch_rdata_i[15:13] == 3'b111) begin
            predict_branch_taken_o = 1'b1;
            predict_confidence_o = 8'd90;
          end else begin
            predict_branch_taken_o = 1'b0;
            predict_confidence_o = 8'd50;
          end
        end else if (fetch_rdata_i[15:13] == 3'b101 || fetch_rdata_i[15:13] == 3'b001) begin
            predict_branch_taken_o = 1'b1;
            predict_confidence_o = 8'd90;
          end else begin
            predict_branch_taken_o = 1'b0;
            predict_confidence_o = 8'd50;
          end
        end
      end
      // Branch instructions
      default: begin
        if (instr[1:0] == OPCODE_BRANCH) begin
          imm_b_type = {{19{fetch_rdata_i[31]}},fetch_rdata_i[31],fetch_rdata_i[7],fetch_rdata_i[30:25],fetch_rdata_i[11:8],1'b0};
          if (imm_b_type[31] == 1) begin
            predict_branch_taken_o = 1'b1;
            predict_confidence_o = 8'd90;
          end else begin
            predict_branch_taken_o = 1'b0;
            predict_confidence_o = 8'd50;
          end
        end else if (imm_b_type[31] == 0) begin
          predict_branch_taken_o = 1'b0;
          predict_confidence_o = 8'd50;
        end
        // Compressed branch instructions
        else if (fetch_rdata_i[15:13] == 3'b100 || fetch_rdata_i[15:13] == 3'b101) begin
          imm_cb_type = {{23{fetch_rdata_i[12]}},fetch_rdata_i[12],fetch_rdata_i[31],fetch_rdata_i[7],fetch_rdata_i[30:25],fetch_rdata_i[11:8],1'b0};
          if (imm_cb_type[31] == 1) begin
            predict_branch_taken_o = 1'b1;
            predict_confidence_o = 8'd90;
          end else begin
            predict_branch_taken_o = 1'b0;
            predict_confidence_o = 8'd50;
          end
        end
        // Invalid or unrecognized instructions
        else if (!fetch_valid_i) begin
          predict_branch_taken_o = 1'b0;
          predict_confidence_o = 8'd0;
        end
      end
    end
  end

  // Immediate Extraction
  assign imm_jal_type = {{20{instr[31]}},instr[31:20]}+register_addr_i;
  assign imm_jalr_type = {{20{instr[31]}},instr[31:20];
  assign imm_cj_type = { {20{instr[12]}},instr[12],instr[8],instr[10:9],instr[6],instr[7],
    instr[2],instr[11],instr[5:3],1'b0};
  assign imm_cb_type = {{23{instr[12]}},instr[12],instr[6:5],instr[2],instr[11:10],
    instr[4:3],1'b0};

  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;
);
