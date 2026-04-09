module static_branch_predict (
    input  logic [31:0] fetch_rdata_i,
    input  logic fetch_pc_i,
    input  logic fetch_valid_i,
    output logic predict_branch_taken_o,
    output logic [31:0] predict_branch_pc_o
);

always @(*) begin
    logic signed imm_signed;
    imm_signed = {fetch_rdata_i[31:12]};

    if (imm_signed < 0) begin
        // Predict taken – sign bit indicates branch direction
        predict_branch_taken_o = 1'b1;
        predict_branch_pc_o = fetch_pc_i + imm_signed;
    else
        predict_branch_taken_o = 1'b0;
        predict_branch_pc_o = fetch_pc_i;
    end
end

endmodule
