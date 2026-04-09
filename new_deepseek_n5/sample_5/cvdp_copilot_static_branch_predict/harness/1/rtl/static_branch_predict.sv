module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input 1-bit fetch_valid_i,
    output 1-bit predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    // Extract immediate value
    wire [31:0] immediate;

    // Determine instruction type
    wire [31:0] instr_b_taken;

    // Always take jumps (JAL, JALR, C.J, C.JAL)
    if ((fetch_rdata_i[30:28] == 0x6F) || (fetch_rdata_i[30:28] == 0x67)) {
        predict_branch_taken_o = 1;
        predict_branch_pc_o = fetch_pc_i + immediate;
    } else if ((fetch_rdata_i[30:28] == 0x63) || (fetch_rdata_i[30:28] == 0x67)) {
        // For branches, check sign bit of immediate
        if (immediate[31] == 1) {
            predict_branch_taken_o = 1;
            predict_branch_pc_o = fetch_pc_i + immediate;
        } else {
            predict_branch_taken_o = 0;
            predict_branch_pc_o = fetch_pc_i;
        }
    } else {
        // Other instructions, no prediction
        predict_branch_taken_o = 0;
        predict_branch_pc_o = fetch_pc_i;
    }
endmodule