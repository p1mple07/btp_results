module static_branch_predict (
    input logic [31:0] fetch_rdata_i,
    input logic [31:0] fetch_pc_i,
    input logic fetch_valid_i,
    output logic predict_branch_taken_o,
    output logic [31:0] predict_branch_pc_o
);

    logic is_branch;
    logic [3:0] imm_val;

    assign is_branch = ({fetch_rdata_i[31:27]} == 3'b1000);

    if (is_branch) begin
        // Extract the 32‑bit immediate and sign‑extend it
        assign imm_val = (
            {fetch_rdata_i[31:20]} << 12 |
            {fetch_rdata_i[19:12]} << 6 |
            {fetch_rdata_i[11:7]} << 2 |
            {fetch_rdata_i[5:0]}
        );

        // Predict taken and target address
        assign predict_branch_taken_o = 1'b1;
        assign predict_branch_pc_o = fetch_pc_i + imm_val;

    end else begin
        // For jumps, always predict taken
        assign predict_branch_taken_o = 1'b1;
        assign predict_branch_pc_o = fetch_pc_i;

    end

endmodule
