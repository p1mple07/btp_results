module load_store_unit(
    input clock,
    input rst_n,
    input [31:0] dmem_req_o,
    input [31:0] dmem_gnt_i,
    input [31:0] dmem_req_addr_o,
    input [3:0] dmem_req_be_o,
    input [31:0] dmem_req_wdata_o,
    input [1] ex_if_req_i,
    input [1] ex_if_we_i,
    input [2:0] ex_if_type_i,
    input [31:0] ex_if_addr_base_i,
    input [31:0] ex_if_addr_offset_i,
    output [1] ex_if_ready_o,
    output [32:0] wb_if_rdata_o,
    output [1] wb_if_rvalid_o
);

    // State variables
    reg ex_if_state = 0;
    reg mem_req_valid = 0;

    // Address calculation
    wire [31:0] dmem_req_addr = ex_if_addr_base_i + ex_if_addr_offset_i;

    // Byte enable mask generation
    function [4:0] byte_enable_mask;
        if (ex_if_type_i == 0b00) return 0b0000;
        if (ex_if_type_i == 0b01) return (ex_if_addr_offset_i & 0b00) ? 0b0011 : 0b1100;
        if (ex_if_type_i == 0b10) return 0b1111;
        return 0;
    endfunction

    // Memory interface
    wire [31:0] dmem_req_wdata = ex_if_addr_base_i + ex_if_addr_offset_i;
    wire [31:0] dmem_gnt = 0;
    wire [32:0] dmem_rvalid = 0;
    wire [32:0] dmem_rsp_rdata = 0;

    // Processing logic
    always clocked begin
        if (rst_n) begin
            ex_if_state = 0;
            mem_req_valid = 0;
            dmem_req_o = 0;
            dmem_req_addr_o = 0;
            dmem_req_we_o = 0;
            dmem_req_be_o = 0;
            dmem_req_wdata_o = 0;
            dmem_gnt_i = 0;
            dmem_rvalid_i = 0;
            wb_if_rdata_o = 0;
            wb_if_rvalid_o = 0;
        else begin
            if (ex_if_state == 0) begin
                if (ex_if_ready_o && ex_if_req_i && (dmem_gnt_i == 1)) begin
                    ex_if_state = 1;
                    dmem_req_o = 1;
                    dmem_req_addr_o = dmem_req_addr;
                    dmem_req_we_o = ex_if_we_i;
                    dmem_req_be_o = byte_enable_mask(ex_if_type_i);
                    dmem_req_wdata_o = 0;
                end
            end else if (ex_if_state == 1) begin
                if (dmem_gnt_i && dmem_rvalid_i) begin
                    ex_if_state = 2;
                    dmem_gnt_i = 0;
                    dmem_rvalid_i = 0;
                    dmem_rsp_rdata_i = 0;
                end
            end else if (ex_if_state == 2) begin
                if (dmem_gnt_i && dmem_rvalid_i) begin
                    ex_if_state = 0;
                    dmem_gnt_i = 0;
                    dmem_rvalid_i = 0;
                    dmem_rsp_rdata_i = 0;
                    if (ex_if_we_i) begin
                        wb_if_rvalid_o = 1;
                        wb_if_rdata_o = dmem_rsp_rdata_i;
                    end
                end
            end
        end
    end

    // Always block for memory operations
    always clocked begin
        if (ex_if_state == 1) begin
            // Send request to memory
            dmem_req_o = 1;
            dmem_req_addr_o = dmem_req_addr;
            dmem_req_we_o = ex_if_we_i;
            dmem_req_be_o = byte_enable_mask(ex_if_type_i);
            dmem_req_wdata_o = 0;
        end else if (ex_if_state == 2) begin
            // Memory has responded
            dmem_gnt_i = 0;
            dmem_rvalid_i = 1;
        end
    end
endmodule