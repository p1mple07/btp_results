module load_store_unit (
    input clk,
    input rst_n,
    input ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [31:0] ex_if_addr_base_i,
    input [31:0] ex_if_addr_offset_i,
    input ex_if_we_i,
    output reg ex_if_ready_o,

    input [31:0] dmem_req_addr_o,
    input dmem_req_we_o,
    input dmem_req_be_o,
    output reg dmem_req_o,
    input [31:0] dmem_req_wdata_o,

    input dmem_rvalid_i,
    input [31:0] dmem_rsp_rdata_i,

    output reg wb_if_rvalid_o,
    output [31:0] wb_if_rdata_o
);

    // Internal Signals
    logic [1:0] byte_enable;
    logic [31:0] addr_offset;
    logic [31:0] addr_base;

    // On Reset
    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n) begin
            ex_if_ready_o = 1;
            dmem_req_o = 1;
            dmem_req_addr_o = 0;
            dmem_req_be_o = 0;
            dmem_req_wdata_o = 0;
            wb_if_rvalid_o = 0;
            wb_if_rdata_o = 0;
        end else begin
            ex_if_ready_o = 0;
        end
    end

    // Transaction Address and Byte Enable
    always_comb begin
        addr_offset = ex_if_addr_offset_i;
        addr_base = ex_if_addr_base_i;

        case (ex_if_type_i)
            0b00: byte_enable = {addr_base[0], addr_base[1], 0, 0};
            0b01: byte_enable = {addr_base[1], addr_base[2], 0, 0};
            0b10: byte_enable = {addr_base[2], addr_base[3], 0, 0};
            0b11: byte_enable = {addr_base[3], addr_base[3], addr_base[3], addr_base[3]};
            default: byte_enable = 32'b0;
        endcase
    end

    // Processing Execute Stage Request
    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n) begin
            ex_if_ready_o = 0;
        end else begin
            if (ex_if_req_i && ex_if_ready_o) begin
                if (addr_offset < 32'd2 && (byte_enable & addr_offset)) begin
                    dmem_req_addr_o = addr_base + addr_offset;
                    dmem_req_be_o = byte_enable;
                    dmem_req_wdata_o = dmem_req_wdata_o;
                    dmem_req_o = 1;
                    ex_if_ready_o = 0; // Signal ready for next transaction
                end
            end
        end
    end

    // Processing Writeback Stage Response
    always_ff @(posedge clk, posedge rst_n) begin
        if (rst_n) begin
            wb_if_rvalid_o = 0;
            wb_if_rdata_o = 0;
        end else begin
            if (ex_if_we_i) begin
                wb_if_rvalid_o = dmem_rvalid_i;
                wb_if_rdata_o = dmem_rsp_rdata_i;
            end
        end
    end
endmodule
