// Load Store Unit (LSU) RTL Module

module load_store_unit
(
    // Inputs
    input clk,
    input rst_n,
    input ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [31:0] ex_if_addr_offset_i,
    input [31:0] ex_if_addr_base_i,
    input ex_if_we_i,

    // Outputs
    output reg ex_if_ready_o,
    output reg dmem_req_o,
    output reg dmem_gnt_i,
    output reg dmem_req_addr_o,
    output reg dmem_req_we_o,
    output reg dmem_req_be_o,
    output reg dmem_req_wdata_o,
    output reg wb_if_rvalid_o,
    output reg [31:0] wb_if_rdata_o
);

    // Internal signals
    reg [31:0] ex_if_addr_i;
    reg [31:0] dmem_req_addr_i;
    reg [31:0] dmem_req_wdata_i;
    reg [31:0] dmem_req_be_i;

    // Address calculation
    always @ (posedge clk) begin
        if (rst_n == 0) begin
            ex_if_addr_i <= 0;
            dmem_req_addr_i <= 0;
            dmem_req_wdata_i <= 0;
            dmem_req_be_i <= 0;
        end else begin
            ex_if_addr_i <= ex_if_addr_base_i + ex_if_addr_offset_i;
            dmem_req_addr_i <= ex_if_addr_i;
            dmem_req_wdata_i <= {ex_if_type_i, ex_if_addr_i};
            dmem_req_be_i = {ex_if_type_i == 0 ? ex_if_addr_i[31:2] : 0};
        end
    end

    // Load Store Unit behavior
    always @ (*) begin
        if (rst_n) begin
            ex_if_ready_o <= 1;
            dmem_req_o <= 1;
            dmem_gnt_i <= 0;
            wb_if_rvalid_o <= 0;
            wb_if_rdata_o <= 0;
        end else begin
            if (ex_if_req_i) begin
                if (ex_if_ready_o && ex_if_req_i) begin
                    dmem_req_addr_o <= dmem_req_addr_i;
                    dmem_req_be_o <= dmem_req_be_i;
                    dmem_req_wdata_o <= dmem_req_wdata_i;
                    dmem_req_we_o <= ex_if_we_i;
                    dmem_req_o <= 1;
                    ex_if_ready_o <= 0;
                end
            end else begin
                dmem_req_o <= 0;
                ex_if_ready_o <= 1;
            end
        end

        // Handle writeback stage data
        if (dmem_gnt_i && wb_if_rvalid_o) begin
            wb_if_rvalid_o <= 1;
            wb_if_rdata_o <= dmem_rsp_rdata_i;
        end else begin
            wb_if_rvalid_o <= 0;
        end
    end
endmodule
