module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input 1-bit fetch_valid_i,
    output 1-bit predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    // Extract instruction type
    localparam OPCODE_BRANCH = 7'h63;
    localparam OPCODE_JAL = 7'h6F;
    localparam OPCODE_JALR = 7'h67;

    // Determine instruction type
    integer instr_type = (fetch_rdata_i[31] == OPCODE_JAL) ? 1 : 
                        (fetch_rdata_i[31] == OPCODE_JALR) ? 2 :
                        (fetch_rdata_i[31] == OPCODE_BRANCH) ? 3 : 0;

    // Extract immediate based on instruction type
    integer imm;
    if (instr_type == 1 || instr_type == 2) // Jumps
        imm = (fetch_rdata_i[15:12] << 19) | fetch_rdata_i[11:0];
    else // Branches
        imm = (fetch_rdata_i[15:12] << 19) | fetch_rdata_i[11:0];

    // Sign extend immediate to 32 bits
    integer sign_ext_imm;
    if (instr_type == 1 || instr_type == 2) // Jumps always taken
        sign_ext_imm = imm;
    else // Branches: check sign bit
        sign_ext_imm = (imm >> 31) ? (7'h80000000 + imm) : imm;

    // Determine taken status
    bit taken = 1;

    // Calculate target PC
    integer target_pc;
    if (instr_type == 1 || instr_type == 2) // Jumps
        target_pc = (fetch_pc_i + sign_ext_imm) & 31'hffffffff;
    else // Branches
        target_pc = (fetch_pc_i + sign_ext_imm) & 31'hffffffff;

    // Output signals
    predict_branch_taken_o = taken;
    predict_branch_pc_o = target_pc;

endmodule