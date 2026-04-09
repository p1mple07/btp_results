module load_store_unit #(
    parameter CLK_FREQ = 50,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire rst_n,
    input wire ex_if_req_i,
    input wire ex_if_we_i,
    input wire ex_if_type_i,
    input wire ex_if_wdata_i,
    input wire ex_if_addr_base_i,
    input wire ex_if_addr_offset_i,
    input wire ex_if_ready_o,
    input wire dmem_req_o,
    input wire dmem_gnt_i,
    input wire dmem_req_addr_o,
    input wire dmem_req_we_o,
    input wire dmem_req_be_o[3:0],
    input wire dmem_req_wdata_o,
    input wire dmem_rvalid_i,
    input wire dmem_rsp_rdata_i,
    output reg ex_if_ready_o,
    output reg wb_if_rvalid_o,
    output reg [31:0] wb_if_rdata_o,
    output reg [31:0] wb_if_raddr_o,
    output reg [3:0] wb_if_rdata_wdata,
    output reg [3:0] wb_if_raddr_write
);

// Reset logic
always @(*) begin
    if (rst_n) begin
        ex_if_ready_o <= 1'b1;
        wb_if_rvalid_o <= 1'b0;
        wb_if_rdata_o <= 0;
        wb_if_raddr_o <= 0;
        wb_if_raddr_offset_o <= 0;
        wb_if_rdata_wdata <= 0;
        wb_if_raddr_write <= 1'b0;
    end
end

// Execute stage interface
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        ex_if_ready_o <= 1'b1;
        wb_if_rvalid_o <= 1'b0;
        wb_if_rdata_o <= 0;
        wb_if_raddr_o <= 0;
        wb_if_raddr_offset_o <= 0;
        wb_if_rdata_wdata <= 0;
        wb_if_raddr_write <= 1'b0;
    end else begin
        if (ex_if_ready_o && ex_if_req_i && !ex_if_we_i) begin
            if (ex_if_addr_base_i[31:0] == ex_if_addr_offset_i[31:0] + ex_if_addr_offset_i) begin
                if (ex_if_addr_offset_i[3:1] == 0) begin
                    // byte access
                    dmem_req_wdata_o <= ex_if_wdata_i;
                    dmem_req_be_o[3:0] <= ex_if_be_mask;
                    dmem_req_addr_o <= ex_if_addr_base_i + ex_if_addr_offset_i;
                    dmem_req_wdata_o <= ex_if_wdata_i;
                    dmem_req_we_o <= 1'b1;
                end else begin
                    // halfword
                    dmem_req_wdata_o <= ex_if_wdata_i[1:0];
                    dmem_req_be_o[3:2] <= ex_if_be_mask;
                    dmem_req_addr_o <= ex_if_addr_base_i + ex_if_addr_offset_i;
                    dmem_req_wdata_o <= ex_if_wdata_i[1:0];
                    dmem_req_be_o[2:1] <= ex_if_be_mask[1:0];
                    dmem_req_addr_o <= ex_if_addr_base_i + ex_if_addr_offset_i;
                end
            end else begin
                // misaligned
                dmem_req_o <= 1'b0;
                dmem_req_we_o <= 1'b0;
            end
        end else begin
            dmem_req_o <= 1'b0;
            dmem_req_we_o <= 1'b0;
        end
    end
end

// Writeback stage
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        wb_if_rvalid_o <= 1'b0;
        wb_if_rdata_o <= 0;
        wb_if_raddr_o <= 0;
        wb_if_raddr_offset_o <= 0;
        wb_if_rdata_wdata <= 0;
        wb_if_raddr_write <= 1'b0;
    end else begin
        if (wb_if_rvalid_o && wb_if_raddr_o == ex_if_addr_base_i) begin
            wb_if_rdata_o <= dmem_rsp_rdata_i;
            wb_if_raddr_o <= ex_if_addr_base_i;
            wb_if_raddr_offset_o <= ex_if_addr_offset_i;
            wb_if_rdata_wdata <= dmem_rsp_rdata_i;
            wb_if_raddr_write <= 1'b0;
        end else begin
            wb_if_rvalid_o <= 1'b0;
            wb_if_rdata_o <= 0;
            wb_if_raddr_o <= 0;
            wb_if_raddr_offset_o <= 0;
            wb_if_rdata_wdata <= 0;
            wb_if_raddr_write <= 1'b0;
        end
    end
end

endmodule
