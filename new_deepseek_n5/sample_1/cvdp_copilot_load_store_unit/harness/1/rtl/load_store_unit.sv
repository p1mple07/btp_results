module load_store_unit(
    input clock,
    input rst_n,
    output dmem_req_o,
    input dmem_gnt_i,
    output dmem_req_addr_o,
    output dmem_req_we_o,
    output dmem_req_be_o,
    output dmem_req_wdata_o,
    input ex_if_req_i,
    input ex_if_we_i,
    input ex_if_type_i,
    input ex_if_addr_base_i,
    input ex_if_addr_offset_i,
    output ex_if_ready_o,
    output wb_if_rdata_o,
    output wb_if_rvalid_o
);

    // Address calculation and BE mask generation
    function [32:0] addr, [3:0] be_mask;
        addr = ex_if_addr_base_i ^ ex_if_addr_offset_i;
        be_mask = (ex_if_type_i == 0b00) ? (0b000) : 
                 (ex_if_type_i == 0b01) ? (0b010) : 
                 (ex_if_type_i == 0b10) ? (0b111) : 0b000;
    endfunction

    // Load/Store request generation
    if (ex_if_req_i && ex_if_ready_o) {
        dmem_req_o = 1;
        dmem_req_addr_o = addr;
        dmem_req_we_o = ex_if_we_i;
        dmem_req_be_o = be_mask;
        dmem_req_wdata_o = ex_if_wdata_i;
    } else {
        dmem_req_o = 0;
        dmem_req_addr_o = 0;
        dmem_req_we_o = 0;
        dmem_req_be_o = 0;
        dmem_req_wdata_o = 0;
    }

    // Memory interface
    wire dmem_gnt_i to dmem_rvalid_i;

    // Memory requests and responses
    if (dmem_req_o) {
        // Memory requests
        // ...
    }

    // Memory responses
    if (dmem_gnt_i) {
        // Load: set writeback response
        wb_if_rvalid_o = 1;
        wb_if_rdata_o = dmem_rsp_rdata_i;
    }

    // Ready signal management
    ex_if_ready_o = 1;
    // One-cycle latency after handling transaction
    after(1) ex_if_ready_o = 0;
endmodule