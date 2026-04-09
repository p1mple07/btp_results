module load_store_unit #(
    parameter WORD_SIZE = 4
) (
    input wire clk,
    input wire rst_n,
    input wire ex_if_req_i,
    input wire ex_if_we_i,
    input wire [31:0] ex_if_addr_base_i,
    input wire [31:0] ex_if_addr_offset_i,
    input wire ex_if_type_i,
    input wire ex_if_wdata_i[31:0],
    input wire ex_if_addr_we_o,
    input wire ex_if_req_o,
    input wire dmem_req_o,
    output reg dmem_gnt_i,
    output reg [3:0] dmem_req_be_o[3:0],
    output reg dmem_req_wdata_o[31:0],
    input wire dmem_rvalid_i,
    input wire dmem_rsp_rdata_i[31:0],
    output reg wb_if_rvalid_o,
    output reg [31:0] wb_if_rdata_o[31:0],
    output reg ex_if_ready_o
);

initial begin
    if (!rst_n) begin
        dmem_gnt_i <= 0;
        dmem_req_o <= 0;
        dmem_req_addr_o <= 0;
        dmem_req_be_o <= 4'b0;
        dmem_req_wdata_o <= 0;
        dmem_rvalid_i <= 0;
        dmem_rsp_rdata_i <= 0;
        wb_if_rvalid_o <= 0;
        wb_if_rdata_o <= 0;
        ex_if_ready_o <= 1'b1;
        ex_if_ready_o <= 0;
    end else begin
        if (ex_if_ready_o) begin
            if (ex_if_type_i == 0x0) begin
                dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
                dmem_req_be_o <= 4'b0;
            end else if (ex_if_type_i == 0x1) begin
                dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
                dmem_req_be_o <= 4'b10;
            end else if (ex_if_type_i == 0x2) begin
                dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
                dmem_req_be_o <= 4'b11;
                dmem_req_wdata_o[31:0] = ex_if_wdata_i;
            end else begin
                dmem_req_addr_o <= 0;
                dmem_req_be_o <= 0;
                dmem_req_wdata_o <= 0;
            end

            dmem_gnt_i <= 1;
        end
    end
end

// End of module
endmodule
