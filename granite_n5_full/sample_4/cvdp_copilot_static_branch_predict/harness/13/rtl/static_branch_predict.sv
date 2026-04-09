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

  logic instr_b_taken;
  
  assign instr = fetch_rdata_i;
  assign reg_addr = register_addr_i;

  
  
// Decoding the instruction
always @(*) begin
  instr_jal = ((instr & 32'hf800000) == 32'h7000000);
  instr_jalr = ((instr & 32'hf800000) == 32'h6000000);
  instr_b = ((instr & 32'hfc00000) == 32'h6300000);
  instr_cj = ((instr & 32'hff00000) == 32'h7300000);
  instr_cb = ((instr & 32'hff00000) == 32'h7380000);
end

// Assigning the immediate values
assign imm_jal_type = {instr[31], instr[19:12], 12'b0};
assign imm_jalr_type = {instr[31], instr[19:12], reg_addr[11:5], 5'b0};
assign imm_b_type = {{instr[31]}, instr[30], instr[14:12], 12'b0};
assign imm_cj_type = {instr[31], instr[19:12], 12'b0};
assign imm_cb_type = {instr[31], instr[19:12], reg_addr[11:5], 5'b0};

// Selecting the immediate value
always @(*) begin
  if (instr_b_taken) begin
    branch_imm = imm_b_type;
  end else begin
    branch_imm = 0;
  end
end

// Predicting branch taken and calculating target address
always @(*) begin
  predict_branch_taken_o = 0;
  if (instr_jal || instr_jalr || instr_b || instr_cj || instr_cb) begin
    if (instr_b) begin
      if (instr[31] == 1'b1 && (instr[30] == 1'b1)) begin
        predict_branch_taken_o = 1;
      end else begin
        predict_branch_taken_o = 0;
      end
    end
    
    if (instr_cj) begin
      if (instr[31] == 1'b1 && (instr[30] == 1'b1)) begin
        predict_branch_taken_o = 1;
      end else begin
        predict_branch_taken_o = 0;
      end
    end
    
    if (instr_cb) begin
      if (instr[31] == 1'b1 && (instr[30] == 1'b1)) begin
        predict_branch_taken_o = 1;
      end else begin
        predict_branch_taken_o = 0;
      end
    end
  end
end

// Predicted target address
assign predict_branch_pc_o = branch_imm + fetch_pc_i;