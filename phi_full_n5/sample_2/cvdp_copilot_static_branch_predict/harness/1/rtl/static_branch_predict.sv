module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output [1:0] predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    localparam OPCODE_BRANCH = 7'h63;
    localparam OPCODE_JAL = 7'h6F;
    localparam OPCODE_JALR = 7'h67;

    reg [31:0] imm_j_type, imm_b_type, imm_cj_type, imm_cb_type;

    always @ (fetch_rdata_i)
    begin
        // Extract and sign-extend immediate for jump instructions
        imm_j_type = {fetch_rdata_i[31:21], fetch_rdata_i[20], fetch_rdata_i[19:16], fetch_rdata_i[15], fetch_rdata_i[14], fetch_rdata_i[13], fetch_rdata_i[12]};
        imm_j_type = {imm_j_type[31], imm_j_type[30], imm_j_type[29], imm_j_type[28], imm_j_type[27], imm_j_type[26], imm_j_type[25], imm_j_type[24], imm_j_type[23], imm_j_type[22], imm_j_type[21], imm_j_type[20], imm_j_type[19], imm_j_type[18], imm_j_type[17], imm_j_type[16], imm_j_type[15], imm_j_type[14], imm_j_type[13], imm_j_type[12], 0};

        // Extract and sign-extend immediate for branch instructions
        imm_b_type = {fetch_rdata_i[31:21], fetch_rdata_i[20], fetch_rdata_i[19], fetch_rdata_i[18], fetch_rdata_i[17], fetch_rdata_i[16], fetch_rdata_i[15], fetch_rdata_i[14], fetch_rdata_i[13], fetch_rdata_i[12], fetch_rdata_i[11], fetch_rdata_i[10], fetch_rdata_i[9], fetch_rdata_i[8], fetch_rdata_i[7], fetch_rdata_i[6], fetch_rdata_i[5], fetch_rdata_i[4], fetch_rdata_i[3], fetch_rdata_i[2], fetch_rdata_i[1], 0};
        imm_b_type = {imm_b_type[31], imm_b_type[30], imm_b_type[29], imm_b_type[28], imm_b_type[27], imm_b_type[26], imm_b_type[25], imm_b_type[24], imm_b_type[23], imm_b_type[22], imm_b_type[21], imm_b_type[20], imm_b_type[19], imm_b_type[18], imm_b_type[17], imm_b_type[16], imm_b_type[15], imm_b_type[14], imm_b_type[13], imm_b_type[12], 0};

        // Determine instruction type
        reg instr_j, instr_b, instr_cj, instr_cb;
        if (fetch_rdata_i == OPCODE_JAL || fetch_rdata_i == OPCODE_JALR)
            instr_j = 1;
        else if (fetch_rdata_i == OPCODE_BRANCH || fetch_rdata_i == OPCODE_BEQ || fetch_rdata_i == OPCODE_BNE || fetch_rdata_i == OPCODE_BLT || fetch_rdata_i == OPCODE_BLTU || fetch_rdata_i == OPCODE_BGE || fetch_rdata_i == OPCODE_BGEU)
            instr_b = 1;
        else if (fetch_rdata_i == OPCODE_CJ || fetch_rdata_i == OPCODE_CJAL || fetch_rdata_i == OPCODE_CBEQZ || fetch_rdata_i == OPCODE_CBNEZ)
            instr_cb = 1;
        else
            instr_b = instr_cj = instr_j = instr_cb = 0;

        // Sign extension of immediate
        imm_j_type = {imm_j_type[31], imm_j_type[30], imm_j_type[29], imm_j_type[28], imm_j_type[27], imm_j_type[26], imm_j_type[25], imm_j_type[24], imm_j_type[23], imm_j_type[22], imm_j_type[21], imm_j_type[20], imm_j_type[19], imm_j_type[18], imm_j_type[17], imm_j_type[16], imm_j_type[15], imm_j_type[14], imm_j_type[13], imm_j_type[12], imm_j_type[11], imm_j_type[10], imm_j_type[9], imm_j_type[8], imm_j_type[7], imm_j_type[6], imm_j_type[5], imm_j_type[4], imm_j_type[3], imm_j_type[2], imm_j_type[1], imm_j_type[0], imm_j_type[31], imm_j_type[30], imm_j_type[29], imm_j_type[28], imm_j_type[27], imm_j_type[26], imm_j_type[25], imm_j_type[24], imm_j_type[23], imm_j_type[22], imm_j_type[21], imm_j_type[20], imm_j_type[19], imm_j_type[18], imm_j_type[17], imm_j_type[16], imm_j_type[15], imm_j_type[14], imm_j_type[13], imm_j_type[12], imm_j_type[11], imm_j_type[10], imm_j_type[9], imm_j_type[8], imm_j_type[7], imm_j_type[6], imm_j_type[5], imm_j_type[4], imm_j_type[3], imm_j_type[2], imm_j_type[1], imm_j_type[0], imm_j_type[31], imm_j_type[30], imm_j_type[29], imm_j_type[28], imm_j_type[27], imm_j_type[26], imm_j_type[25], imm_j_type[24], imm_j_type[23], imm_j_type[22], imm_j_type[21], imm_j_type[20], imm_j_type[19], imm_j_type[18], imm_j_type[17], imm_j_type[16], imm_j_type[15], imm_j_type[14], imm_j_type[13], imm_j_type[12], imm_j_type[11], imm_j_type[10], imm_j_type[9], imm_j_type[8], imm_j_type[7], imm_j_type[6], imm_j_type[5], imm_j_type[4], imm_j_type[3], imm_j_type[2], imm_j_type[1], imm_j_type[0]};
        imm_b_type = {imm_b_type[31], imm_b_type[30], imm_b_type[29], imm_b_type[28], imm_b_type[27], imm_b_type[26], imm_b_type[25], imm_b_type[24], imm_b_type[23], imm_b_type[22], imm_b_type[21], imm_b_type[20], imm_b_type[19], imm_b_type[18], imm_b_type[17], imm_b_type[16], imm_b_type[15], imm_b_type[14], imm_b_type[13], imm_b_type[12], imm_b_type[11], imm_b_type[10], imm_b_type[9], imm_b_type[8], imm_b_type[7], imm_b_type[6], imm_b_type[5], imm_b_type[4], imm_b_type[3], imm_b_type[2], imm_b_type[1], imm_b_type[0], imm_b_type[31], imm_b_type[30], imm_b_type[29], imm_b_type[28], imm_b_type[27], imm_b_type[26], imm_b_type[25], imm_b_type[24], imm_b_type[23], imm_b_type[22], imm_b_type[21], imm_b_type[20], imm_b_type[19], imm_b_type[18], imm_b_type[17], imm_b_type[16], imm_b_type[15], imm_b_type[14], imm_b_type[13], imm_b_type[12], imm_b_type[11], imm_b_type[10], imm_b_type[9], imm_b_type[8], imm_b_type[7], imm_b_type[6], imm_b_type[5], imm_b_type[4], imm_b_type[3], imm_b_type[2], imm_b_type[1], imm_b_type[0]};

        // Predict branch/jump
        reg taken_b;
        always @ (instr_b or instr_j or instr_cb)
        begin
            if (instr_b)
                taken_b = imm_b_type[31] == 1; // Negative offset means branch is taken
            else
                taken_b = 1; // Jumps are always taken

            predict_branch_taken_o = taken_b;
            predict_branch_pc_o = fetch_pc_i + imm_b_type;
        end
    end
endmodule