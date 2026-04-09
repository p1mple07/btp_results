module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output logic predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    logic [31:0] imm_j_type, imm_b_type, imm_cj_type, imm_cb_type;
    logic instr, instr_j, instr_b, instr_cj, instr_cb;
    logic instr_b_taken;

    // Immediate extraction
    case (fetch_rdata_i[31:0])
        32'h8C218363: imm_b_type = {19'b0, 12'h0, 12'h21, 8'h36, 3'h83};
        32'h6C2183E3: imm_j_type = {19'b0, 12'h21, 8'h36, 3'h83, 3'hE3};
        32'hFE000E63: imm_cb_type = {19'b0, 12'h0, 12'h0, 8'h0, 3'h0, 3'h63};
        default: begin
            predict_branch_taken_o = 0;
            predict_branch_pc_o = 32'h0;
        end
    endcase

    // Sign extension
    imm_b_type = {32'hFFFFF0C6, 32'h0};
    imm_j_type = {32'hFFFFF0C6, 32'h0};
    imm_cj_type = {32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 3'h63};
    imm_cb_type = {32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0};

    // Instruction type decoding
    instr_j = (fetch_rdata_i == 32'hFFFFF0C6) || (fetch_rdata_i == 32'hFFFFF0C6);
    instr_b = (fetch_rdata_i == imm_b_type) || (fetch_rdata_i == imm_b_type);
    instr_cj = (fetch_rdata_i == imm_cj_type) || (fetch_rdata_i == imm_cj_type);
    instr_cb = (fetch_rdata_i == imm_cb_type) || (fetch_rdata_i == imm_cb_type);

    // Branch prediction
    instr_b_taken = (imm_b_type[31] == 1) || (imm_cj_type[31] == 1);
    predict_branch_taken_o = instr_b_taken;

    // Target address calculation
    predict_branch_pc_o = fetch_pc_i + imm_b_type;

endmodule
 static_branch_predict.sv

module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output logic predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    logic [31:0] imm_j_type, imm_b_type, imm_cj_type, imm_cb_type;
    logic instr, instr_j, instr_b, instr_cj, instr_cb;
    logic instr_b_taken;

    // Immediate extraction
    case (fetch_rdata_i)
        32'h8C218363: imm_b_type = {19'b0, 12'h0, 12'h21, 8'h36, 3'h83};
        32'h6C2183E3: imm_j_type = {19'b0, 12'h21, 8'h36, 3'h83, 3'hE3};
        32'hFE000E63: imm_cb_type = {19'b0, 12'h0, 12'h0, 8'h0, 3'h0, 3'h63};
        default: begin
            predict_branch_taken_o = 0;
            predict_branch_pc_o = 32'h0;
        end
    endcase

    // Sign extension
    imm_b_type = {32'hFFFFF0C6, 32'h0};
    imm_j_type = {32'hFFFFF0C6, 32'h0};
    imm_cj_type = {32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 3'h63};
    imm_cb_type = {32'h0, 32'h0, 32'h0, 32'h0, 32'h0, 32'h0};

    // Instruction type decoding
    instr_j = (fetch_rdata_i == imm_j_type) || (fetch_rdata_i == imm_j_type);
    instr_b = (fetch_rdata_i == imm_b_type) || (fetch_rdata_i == imm_b_type);
    instr_cj = (fetch_rdata_i == imm_cj_type) || (fetch_rdata_i == imm_cj_type);
    instr_cb = (fetch_rdata_i == imm_cb_type) || (fetch_rdata_i == imm_cb_type);

    // Branch prediction
    instr_b_taken = (imm_b_type[31] == 1) || (imm_cj_type[31] == 1);
    predict_branch_taken_o = instr_b_taken;

    // Target address calculation
    predict_branch_pc_o = fetch_pc_i + imm_b_type;

endmodule