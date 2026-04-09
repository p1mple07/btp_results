// load_store_unit.sv

module load_store_unit #(parameter DATA_WIDTH = 32) (
    input clk,
    input rst_n,
    input ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [DATA_WIDTH-1:0] ex_if_addr_offset_i,
    input [DATA_WIDTH-1:0] ex_if_addr_base_i,
    output reg ex_if_ready_o,
    output reg [DATA_WIDTH-1:0] dmem_req_addr_o,
    output reg dmem_req_we_o,
    output reg [DATA_WIDTH-1:0] dmem_req_be_o,
    output reg dmem_req_wdata_o,
    input dmem_rvalid_i,
    input [DATA_WIDTH-1:0] dmem_rsp_rdata_i,
    output reg wb_if_rdata_o,
    output reg wb_if_rvalid_o
);

    // Internal signals
    reg [DATA_WIDTH-1:0] tmp_addr;
    reg [DATA_WIDTH-1:0] tmp_be;

    // Transaction address and byte enable
    always @(posedge clk) begin
        if (rst_n) begin
            tmp_addr <= 0;
            tmp_be <= 0;
        end else begin
            case (ex_if_type_i)
                2'b00: tmp_be = {DATA_WIDTH{1'b0}}, // Align to word boundary
                2'b01: tmp_be = {DATA_WIDTH{ex_if_addr_base_i[15:0]}, 16'b0}; // Align to halfword boundary
                2'b10: tmp_be = {DATA_WIDTH{ex_if_addr_base_i[15:0]}, 16'b1}; // Align to halfword boundary
                2'b11: tmp_be = {DATA_WIDTH{ex_if_addr_base_i[DATA_WIDTH-1:0]}; // Align to word boundary
                default: tmp_be = 16'b0; // Mismatched alignment, discard
            endcase
            tmp_addr = ex_if_addr_base_i + ex_if_addr_offset_i;
        end
    end

    // Address generation
    always @(posedge clk) begin
        if (rst_n) begin
            dmem_req_addr_o <= 0;
            dmem_req_be_o <= 0;
        end else begin
            dmem_req_addr_o = tmp_addr;
            dmem_req_be_o = tmp_be;
        end
    end

    // Transaction control
    always @(posedge clk) begin
        if (rst_n) begin
            dmem_req_we_o <= 0;
            dmem_req_wdata_o <= 0;
        end else if (ex_if_req_i && !ex_if_ready_o) begin
            dmem_req_we_o <= ex_if_we_i;
            dmem_req_addr_o <= dmem_req_addr_o;
            dmem_req_be_o <= dmem_req_be_o;
            dmem_req_wdata_o <= ex_if_wdata_i;
            dmem_req_o <= 1;
            ex_if_ready_o <= 1;
        end else if (ex_if_ready_o) begin
            dmem_req_we_o <= 0;
            dmem_req_addr_o <= 0;
            dmem_req_be_o <= 0;
            dmem_req_wdata_o <= 0;
        end
    end

    // Memory interaction
    always @(posedge clk) begin
        if (rst_n) begin
            if (dmem_req_o) begin
                dmem_req_we_o <= 0;
            end else begin
                dmem_req_o <= 0;
            end
        end else if (dmem_req_o) begin
            if (ex_if_we_i) begin
                // Store transaction
                dmem_req_wdata_o <= ex_if_wdata_i;
            end
        end
    end

    // Memory response
    always @(posedge clk) begin
        if (rst_n) begin
            if (dmem_gnt_i) begin
                ex_if_ready_o <= 1;
            end else begin
                ex_if_ready_o <= 0;
            end
        end
    end

    // Writeback response
    always @(posedge clk) begin
        if (rst_n) begin
            wb_if_rvalid_o <= 0;
            wb_if_rdata_o <= 0;
        end else if (dmem_rvalid_i) begin
            wb_if_rvalid_o <= dmem_rvalid_i;
            wb_if_rdata_o <= dmem_rsp_rdata_i;
        end
    end

endmodule
