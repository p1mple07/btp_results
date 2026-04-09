module static_branch_predict #(
    parameter WIDTH = 32,
    parameter OPCODE_BRANCH = 7'h63,
    parameter OPCODE_JAL = 7'h6F,
    parameter OPCODE_JALR = 7'h67,
    parameter OPCODE_BEQZ = 7'h63,
    parameter OPCODE_BNEZ = 7'h6F,
    parameter OPCODE_CJ = 7'h6F,
    parameter OPCODE_CJAL = 7'h67,
    // Add other opcodes if required
) (
    input logic [WIDTH-1:0] fetch_rdata_i,
    input logic [WIDTH-1:0] fetch_pc_i,
    input logic fetch_valid_i,

    output logic [1:0] predict_branch_taken_o,
    output logic [WIDTH-1:0] predict_branch_pc_o
);

localparam [31:0] imm_j_type = 32'b0;
localparam [31:0] imm_b_type = 32'b0;
localparam [31:0] imm_cj_type = 32'b0;
localparam [31:0] imm_cb_type = 32'b0;

always_comb begin
    predict_branch_taken_o = 1'b0;
    predict_branch_pc_o = 32'b0;

    if (is_branch) begin
        logic [31:0] imm;
        imm = fetch_rdata_i[31:0];

        // Determine sign extension
        logic [31:0] imm_signed;
        imm_signed = imm;

        // Predict taken if the immediate is negative
        if (imm_signed[31]) predict_branch_taken_o = 1'b1;
        else predict_branch_taken_o = 1'b0;

        // Target address is PC plus the signed immediate
        assign predict_branch_pc_o = fetch_pc_i + imm;
    end else begin
        predict_branch_taken_o = 1'b0;
        predict_branch_pc_o = 32'b0;
    end
end

endmodule
