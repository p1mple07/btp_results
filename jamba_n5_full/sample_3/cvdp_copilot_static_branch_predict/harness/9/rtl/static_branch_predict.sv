module static_branch_predict (
  
    // Input ports
    input  logic [31:0] fetch_rdata_i,
    input  logic [31:0] fetch_pc_i,
    input  logic [31:0] register_addr_i,
    input  logic        fetch_valid_i,

    // Outputs
    output logic        predict_branch_taken_o,
    output logic [31:0] predict_branch_pc_o,
    output logic        predict_confidence_o,
    output logic predict_exception_o,
    output logic [2:0] predict_branch_type_o,
    output logic predict_branch_offset_o
);

    // Internal registers
    logic [31:0] reg_addr;
    logic [31:0] imm_jal_type;
    logic [31:0] imm_jalr_type;
    logic [31:0] imm_b_type;
    logic [31:0] imm_cj_type;
    logic [31:0] imm_cb_type;

    logic [31:0] branch_imm;
  logic [31:0] pred_branch_pc_o;
  logic [2:0] predict_branch_type_o;
  logic predict_branch_offset_o;
  logic predict_confidence_o;
  logic predict_exception_o;

  // --- Branch detection and prediction --------------------------------
  logic [31:0] branch_imm;
  logic [31:0] pred_branch_pc_o;

  always_comb begin
    // Extract branch opcode
    assign pred_branch_pc_o = (fetch_opcode_i == 7'b63) ? fetch_pc_i : 32'h0;

    // Immediate extraction for branch instructions
    assign imm_b_type = {
        {19{fetch_rdata_i[31]}}, fetch_rdata_i[31], fetch_rdata_i[7], fetch_rdata_i[30:25], fetch_rdata_i[11:8], 1'b0
    };

    // Sign‑extend to 32 bits
    assign branch_imm = imm_b_type;

    // Branch type detection
    if (imm_b_type[31] == 1) begin
        predict_branch_taken_o = 1'b1;
        predict_branch_pc_o = fetch_pc_i + branch_imm;
        predict_confidence_o = 8'b00000000;  // Low confidence, not taken
        predict_exception_o = 1'b0;
        predict_branch_type_o = 3'b011;
    end else if (imm_b_type[1:0] == 3'b110) begin
        predict_branch_taken_o = 1'b1;
        predict_branch_pc_o = fetch_pc_i + branch_imm;
        predict_confidence_o = 8'b00000010;  // Backward branch, 90% chance
        predict_exception_o = 1'b0;
        predict_branch_type_o = 3'b001;
    end else if (imm_b_type[1:0] == 3'b101) begin
        predict_branch_taken_o = 1'b1;
        predict_branch_pc_o = fetch_pc_i + branch_imm;
        predict_confidence_o = 8'b00000001;  // Forward branch, 50% chance
        predict_exception_o = 1'b0;
        predict_branch_type_o = 3'b010;
    end else begin
        predict_branch_taken_o = 1'b0;
        predict_branch_pc_o = fetch_pc_i + branch_imm;
        predict_confidence_o = 8'b00000000;  // No branch
        predict_exception_o = 1'b1;
        predict_branch_type_o = 3'b000;
    end

  end

  // --- Confidence, exception, and type --------------------------------
  assign predict_confidence_o = 8'b00000000;  // Default confidence
  assign predict_exception_o = 1'b0;
  assign predict_branch_type_o = 3'b000;
  assign predict_branch_offset_o = branch_imm;

endmodule
