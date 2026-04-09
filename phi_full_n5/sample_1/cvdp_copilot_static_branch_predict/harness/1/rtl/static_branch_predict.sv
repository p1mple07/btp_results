module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output reg predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    reg [31:0] imm_j_type, imm_b_type, imm_cj_type, imm_cb_type;
    logic instr_j, instr_b, instr_cj, instr_cb;
    logic instr_b_taken;

    always_comb {
        // Instruction type decoding
        imm_j_type = (fetch_rdata_i == 32'h6F); // JAL
        imm_b_type = (fetch_rdata_i == 32'h63); // BXXX
        imm_cj_type = (fetch_rdata_i == 32'h67); // C.J
        imm_cb_type = (fetch_rdata_i == 32'h63); // C.J

        // Sign extension
        imm_b_type = {31'b0, imm_b_type[30:0], fetch_rdata_i[31]};
        imm_cj_type = {31'b0, imm_cj_type[30:0], fetch_rdata_i[31]};

        // Uncompressed Branch/Jump Detection
        instr_j = (imm_cj_type == 32'h67);
        instr_b = (imm_b_type == 32'h63) | (imm_cj_type == 32'h67);

        // Compressed Branch/Jump Detection
        instr_cb = (fetch_valid_i && (fetch_rdata_i == {19'b0, 18'h0, 12'h0, imm_cb_type[11:0]});

        // Offset-Based Prediction
        instr_b_taken = (imm_b_type[31] == 1);

        // Prediction Logic
        predict_branch_taken_o = (instr_j || instr_cb) || instr_b_taken;
        predict_branch_pc_o = (predict_branch_taken_o) ? fetch_pc_i + imm_b_type : 32'h0;
    }
endmodule
