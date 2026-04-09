module load_store_unit (
    input clk,
    input rst_n,
    input ex_if_req_i,
    input ex_if_we_i,
    input ex_if_type_i[1:0],
    input ex_if_wdata_i[31:0],
    input ex_if_addr_base_i[31:0],
    input ex_if_addr_offset_i[31:0],
    input ex_if_ready_o,
    output dmem_req_o,
    output dmem_gnt_i,
    output dmem_req_addr_o[31:0],
    output dmem_req_we_o,
    output dmem_req_be_o[3:0],
    output dmem_req_wdata_o[31:0],
    output dmem_rvalid_i,
    output wb_if_rdata_o[31:0],
    output wb_if_rvalid_o,
    output ex_if_ready_o_next
);

always_ff @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        dmem_req_o <= 1'b0;
        dmem_gnt_i <= 1'b0;
        dmem_req_addr_o <= 0;
        dmem_req_we_o <= 1'b0;
        dmem_req_be_o <= 0;
        dmem_req_wdata_o <= 32'b0;
        dmem_rvalid_i <= 1'b0;
        wb_if_rdata_o <= 0;
        wb_if_rvalid_o <= 1'b0;
        ex_if_ready_o_next <= 1'b0;
    end else begin
        if (ex_if_ready_o && ex_if_req_i) begin
            if (ex_if_addr_offset_i[0] == 1'b0) begin
                dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
                dmem_req_be_o[3:0] = ex_if_type_i;
                dmem_req_wdata_o[31:0] = ex_if_wdata_i;
                dmem_rvalid_i = 1'b1;
                wb_if_rdata_o[31:0] = ex_if_wdata_i;
                wb_if_rvalid_o = 1'b1;
                ex_if_ready_o_next = 1'b1;
            end
        end else if (ex_if_we_i && ex_if_req_i) begin
            dmem_gnt_i <= 1'b1;
            dmem_req_o <= 1'b0;
            dmem_req_we_o <= 1'b1;
            dmem_req_be_o <= 0;
            dmem_req_wdata_o <= 32'b0;
        end else if (ex_if_req_i && ex_if_we_i) begin
            dmem_gnt_i <= 1'b0;
        end else if (!ex_if_ready_o && !ex_if_req_i) begin
            end
        end
    end
end

endmodule
