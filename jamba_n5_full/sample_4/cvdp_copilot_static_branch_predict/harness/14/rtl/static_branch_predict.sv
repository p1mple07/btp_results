module static_branch_predict(
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
logic instr_jal, instr_jalr, instr_b, instr_cj, instr_cb;
logic [31:0] offset;
logic [31:0] target;
logic [7:0] predict_confidence_o;
logic [31:0] predict_branch_pc_o;
logic predict_branch_taken_o;
logic predict_exception_o;
logic [2:0] predict_branch_type_o;

// Decode instruction type
always_comb begin
  assign instr_jal = (instr[6:0] == 7'h6F);
  assign instr_jalr = (instr[6:0] == 7'h67);
  assign instr_b = (instr[6:0] == 7'h63);
  assign instr_cj = (instr[6:0] == 7'h63);
  assign instr_cb = (instr[6:0] == 7'h63);
end

// Compute offset based on type
always_comb begin
  assign offset = case (instr_jal) {
    7'h6F => 32'h00000000;
    default => 0
  };
  assign offset = case (instr_jalr) {
    7'h67 => 12'h00000000;
    default => 0
  };
  assign offset = case (instr_b) {
    7'h63 => 32'h00000000;
    default => 0
  };
  assign offset = case (instr_cj) {
    7'h63 => 32'h00000000;
    default => 0
  };
  assign offset = case (instr_cb) {
    7'h63 => 32'h00000000;
    default => 0
  };
end

// Calculate target address
target = fetch_pc_i + offset;

// Determine prediction confidence
always_comb begin
  assign predict_confidence_o = (instr_b || instr_cj) ? 90 : 50;
end

// Determine branch type
always_comb begin
  assign predict_branch_type_o = (instr_jal || instr_jalr) ? 1 : 0;
end

// Predict taken status
always_comb begin
  assign predict_branch_taken_o = (predict_confidence_o > 50);
end

// Exception detection
always_comb begin
  assign predict_exception_o = (fetch_pc_i < 0) ? 1 : 0;
end

// Output signals
assign predict_branch_pc_o = target;
assign predict_branch_offset_o = offset;
assign predict_confidence_o = predict_confidence_o;
assign predict_branch_taken_o = predict_branch_taken_o;
assign predict_branch_type_o = predict_branch_type_o;

endmodule
