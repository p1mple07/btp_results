module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input 1     fetch_valid_i,
    output 1     predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    // Extract immediate value from instruction
    input [31:0] imm_b_type, imm_cj_type, imm_cb_type;

    // Determine instruction type
    localparam OPCODE_BRANCH = 7'h63;
    localparam OPCODE_JAL = 7'h6F;
    localparam OPCODE_JALR = 7'h67;

    // Always predict jumps as taken
    if ((fetch_rdata_i[31:28] == OPCODE_JAL) || (fetch_rdata_i[31:28] == OPCODE_JALR) || 
        (fetch_rdata_i[31:28] == OPCODE_JAL) || (fetch_rdata_i[31:28] == OPCODE_JALR)) {
        predict_branch_taken_o = 1;
        predict_branch_pc_o = fetch_pc_i + imm_b_type;
    }

    // For branch instructions, predict based on immediate sign
    else if (fetch_rdata_i[31:28] == OPCODE_BRANCH) {
        if (imm_b_type[31] == 1) {
            predict_branch_taken_o = 1;
            predict_branch_pc_o = fetch_pc_i + imm_b_type;
        } else {
            predict_branch_taken_o = 0;
            predict_branch_pc_o = fetch_pc_i + imm_b_type;
        }
    }

    // Other instructions not predicted
    else {
        predict_branch_taken_o = 0;
        predict_branch_pc_o = fetch_pc_i + imm_b_type;
    }
endmodule