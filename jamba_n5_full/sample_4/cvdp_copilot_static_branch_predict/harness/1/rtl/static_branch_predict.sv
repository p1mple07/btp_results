module static_branch_predict #(
    parameter WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] fetch_rdata_i,
    input logic fetch_pc_i,
    input logic fetch_valid_i,
    output logic predict_branch_taken_o,
    output logic [31:0] predict_branch_pc_o
);

    localparam WIDTH = 32;
    localparam DATA_WIDTH = WIDTH;

    assign imm = fetch_rdata_i[DATA_WIDTH/4*3 : DATA_WIDTH/4];

    assign instr_b = (imm[31:28] == 3'b63);
    assign instr_j = (imm[31:28] == 3'b67);
    assign instr_cb = (imm[31:28] == 3'b6F);
    assign instr_cb_b = (imm[31:28] == 3'b63);

    assign predict_branch_taken_o = instr_b || instr_j || instr_cb || instr_cb_b;

    if (predict_branch_taken_o) begin
        assign predict_branch_pc_o = fetch_pc_i + imm;
    end else begin
        assign predict_branch_pc_o = fetch_pc_i;
    end

endmodule
