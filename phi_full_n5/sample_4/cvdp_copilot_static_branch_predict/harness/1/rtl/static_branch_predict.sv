module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output reg [1:0] predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    reg [31:0] imm_b_type, imm_cj_type, imm_j_type, imm_cb_type;

    parameter OPCODE_BRANCH = 7'h63;
    parameter OPCODE_JAL = 7'h6F;
    parameter OPCODE_JALR = 7'h67;

    always @(fetch_rdata_i) begin
        case (fetch_rdata_i[31:0])
            OPCODE_JAL: imm_j_type = fetch_rdata_i;
            OPCODE_JALR: imm_j_type = fetch_rdata_i;
            OPCODE_BRANCH: imm_b_type = fetch_rdata_i;
            default: imm_b_type = 32'h00000000;
        endcase
    end

    always @(fetch_rdata_i) begin
        case (fetch_rdata_i[31:0])
            OPCODE_JAL: imm_cj_type = 32'h00000000;
            OPCODE_JALR: imm_cj_type = fetch_rdata_i;
            OPCODE_BRANCH: imm_cb_type = fetch_rdata_i;
            default: imm_cb_type = 32'h00000000;
        endcase
    end

    assign imm_j_type = (fetch_rdata_i == OPCODE_JAL) | (fetch_rdata_i == OPCODE_JALR);
    assign imm_b_type = (fetch_rdata_i == OPCODE_BRANCH);
    assign imm_cj_type = (fetch_rdata_i == OPCODE_JAL) | (fetch_rdata_i == OPCODE_JALR);
    assign imm_cb_type = (fetch_rdata_i == OPCODE_BRANCH);

    assign instr = fetch_rdata_i;
    assign instr_j = imm_j_type;
    assign instr_b = imm_b_type;
    assign instr_cj = imm_cj_type;
    assign instr_cb = imm_cb_type;

    // Sign extension for immediate values
    assign imm_j_type_se = {31'b0, imm_j_type[30:0], {1'b0, imm_j_type[31]}};
    assign imm_b_type_se = {31'b0, imm_b_type[30:0], {1'b0, imm_b_type[31]}};
    assign imm_cj_type_se = {31'b0, imm_cj_type[30:0], {1'b0, imm_cj_type[31]}};
    assign imm_cb_type_se = {31'b0, imm_cb_type[30:0], {1'b0, imm_cb_type[31]}};

    // Prediction logic
    always @(fetch_valid_i) begin
        if (fetch_valid_i) begin
            predict_branch_taken_o = (instr_b | instr_cj) & instr_b_taken;
            predict_branch_pc_o = fetch_pc_i + imm_b_type_se;
        end else begin
            predict_branch_taken_o = 1'b0;
            predict_branch_pc_o = 32'h00000000;
        end
    end

    // Determine if branch is taken based on sign of offset
    always @(fetch_rdata_i) begin
        case (instr_b)
            imm_b_type[31] = imm_b_type[30]; // Sign extension
        endcase
    end

    // Predict jumps as always taken
    always @(fetch_valid_i) begin
        predict_branch_taken_o = |instr_j;
        predict_branch_pc_o = fetch_pc_i + imm_j_type_se;
    end

endmodule