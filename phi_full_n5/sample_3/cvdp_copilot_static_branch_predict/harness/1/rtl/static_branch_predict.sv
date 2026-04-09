module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output reg [1:0] predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    reg [31:0] imm_j_type, imm_b_type, imm_cj_type, imm_cb_type;
    reg instr, instr_j, instr_b, instr_cj, instr_cb;
    reg instr_b_taken;

    // Instruction type decoding
    always @(posedge fetch_valid_i) begin
        imm_j_type = (fetch_rdata_i == OPCODE_JAL) ? fetch_rdata_i : 32'h0;
        imm_b_type = (fetch_rdata_i == OPCODE_BXXX) ? fetch_rdata_i : 32'h0;
        imm_cj_type = (fetch_rdata_i == OPCODE_CJ) ? fetch_rdata_i : 32'h0;
        imm_cb_type = (fetch_rdata_i == OPCODE_CJAL) ? fetch_rdata_i : 32'h0;

        instr = fetch_rdata_i;
        instr_j = (fetch_rdata_i == OPCODE_JAL) ? 1'b1 : 1'b0;
        instr_b = (fetch_rdata_i == OPCODE_BXXX) ? 1'b1 : 1'b0;
        instr_cj = (fetch_rdata_i == OPCODE_CJ) ? 1'b1 : 1'b0;
        instr_cb = (fetch_rdata_i == OPCODE_CJAL) ? 1'b1 : 1'b0;
    end

    // Sign extension
    assign imm_j_type = {8'b{fetch_rdata_i[7:0]}, fetch_rdata_i[7:0]};
    assign imm_b_type = {8'b{fetch_rdata_i[12]}, fetch_rdata_i[12:1], 1'b0};
    assign imm_cj_type = {12'b{fetch_rdata_i[15:4], fetch_rdata_i[15], fetch_rdata_i[14:0]}, fetch_rdata_i[14]};
    assign imm_cb_type = {12'b{fetch_rdata_i[15:4], fetch_rdata_i[15], fetch_rdata_i[14:0]}, fetch_rdata_i[14]};

    // Branch or jump prediction logic
    always @(posedge fetch_valid_i) begin
        // Jumps are always predicted as taken
        if (instr_j || instr_cj) begin
            predict_branch_taken_o = 1'b1;
            predict_branch_pc_o = fetch_pc_i + imm_j_type;
        end else if (instr_b) begin
            // Branches are predicted based on the sign of the offset
            instr_b_taken = (imm_b_type[31] == 1'b1);
            predict_branch_taken_o = instr_b_taken;
            predict_branch_pc_o = fetch_pc_i + imm_b_type;
        end else
            predict_branch_taken_o = 1'b0;
    end

endmodule

// Constants
localparam OPCODE_JAL = 7'h6F;
localparam OPCODE_BXXX = 7'h63;
localparam OPCODE_CJ = 7'h6C;
localparam OPCODE_CJAL = 7'h67;

// Example usage
static_branch_predict instance_name(
    .fetch_rdata_i(fetch_rdata_i),
    .fetch_pc_i(fetch_pc_i),
    .fetch_valid_i(fetch_valid_i),
    .predict_branch_taken_o(predict_branch_taken_o),
    .predict_branch_pc_o(predict_branch_pc_o)
);

// End of module
 module static_branch_predict(
    input [31:0] fetch_rdata_i,
    input [31:0] fetch_pc_i,
    input fetch_valid_i,
    output reg [1:0] predict_branch_taken_o,
    output [31:0] predict_branch_pc_o
);

    // Instruction type decoding
    always @(posedge fetch_valid_i) begin
        // Uncompressed jump instructions
        if (fetch_rdata_i == OPCODE_JAL || fetch_rdata_i == OPCODE_JALR) begin
            imm_j_type = fetch_rdata_i;
        end else if (fetch_rdata_i == OPCODE_BXXX) begin
            imm_b_type = {19{fetch_rdata_i[12]}, fetch_rdata_i[12:1], 1'b0};
        end else if (fetch_rdata_i == OPCODE_CJ || fetch_rdata_i == OPCODE_CJAL) begin
            imm_cj_type = {12'b{fetch_rdata_i[15:4], fetch_rdata_i[15], fetch_rdata_i[14:0]}, fetch_rdata_i[14]};
        end
        // Other instructions are not supported
        imm_cb_type = 32'h0;
        instr = fetch_rdata_i;
        instr_j = (fetch_rdata_i == OPCODE_JAL || fetch_rdata_i == OPCODE_JALR) ? 1'b1 : 1'b0;
        instr_b = (fetch_rdata_i == OPCODE_BXXX) ? 1'b1 : 1'b0;
        instr_cj = (fetch_rdata_i == OPCODE_CJ || fetch_rdata_i == OPCODE_CJAL) ? 1'b1 : 1'b0;
        instr_cb = 1'b0;
    end

    // Sign extension
    assign imm_j_type = {8'b{fetch_rdata_i[7:0]}, fetch_rdata_i[7:0]};
    assign imm_b_type = {8'b{fetch_rdata_i[12]}, fetch_rdata_i[12:1], 1'b0};
    assign imm_cj_type = {12'b{fetch_rdata_i[15:4], fetch_rdata_i[15], fetch_rdata_i[14:0]}, fetch_rdata_i[14]};

    // Branch or jump prediction logic
    always @(posedge fetch_valid_i) begin
        // Jumps are always predicted as taken
        if (instr_j || instr_cj) begin
            predict_branch_taken_o = 1'b1;
            predict_branch_pc_o = fetch_pc_i + imm_j_type;
        // Branches are predicted based on the sign of the offset
        } else if (instr_b) begin
            predict_branch_taken_o = (imm_b_type[31] == 1'b1);
            predict_branch_pc_o = fetch_pc_i + imm_b_type;
        end else
            predict_branch_taken_o = 1'b0;
    end

endmodule