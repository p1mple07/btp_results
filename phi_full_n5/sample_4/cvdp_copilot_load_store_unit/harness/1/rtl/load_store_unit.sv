module load_store_unit (
    input clk,
    input rst_n,
    input ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [31:0] ex_if_addr_base_i,
    input [31:0] ex_if_addr_offset_i,
    output reg ex_if_ready_o,
    output reg dmem_req_o,
    output reg dmem_req_we_o,
    output reg [3:0] dmem_req_be_o,
    output reg [31:0] dmem_req_addr_o,
    output reg [31:0] dmem_req_wdata_o,
    input dmem_rvalid_i,
    input [31:0] dmem_rsp_rdata_i,
    output reg wb_if_rvalid_o,
    output reg [31:0] wb_if_rdata_o
);

    // Internal signals
    reg [31:0] effective_addr_o;
    reg [3:0] byte_enable_o;
    reg [1:0] access_type_o;

    // Reset
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            ex_if_ready_o <= 1'b1;
            dmem_req_o <= 1'b0;
            dmem_req_we_o <= 1'b0;
            dmem_req_be_o <= 3'b0;
            dmem_req_addr_o <= 32'h0;
            dmem_req_wdata_o <= 32'h0;
            wb_if_rvalid_o <= 1'b0;
            wb_if_rdata_o <= 32'h0;
        end else begin
            ex_if_ready_o <= 1'b0;
        end
    end

    // Transaction address calculation
    always @(posedge clk) begin
        if (ex_if_req_i) begin
            access_type_o = ex_if_type_i;
            effective_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;
            byte_enable_o = calculate_byte_enable(effective_addr_o, access_type_o);
        end
    end

    // Transaction request processing
    always @(posedge clk) begin
        if (ex_if_req_i && ex_if_ready_o) begin
            if (access_type_o == 0'b0 && is_aligned(effective_addr_o)) begin
                dmem_req_o <= 1'b1;
                dmem_req_we_o <= ex_if_req_i;
                dmem_req_addr_o <= effective_addr_o;
                dmem_req_be_o <= byte_enable_o;
                dmem_req_wdata_o <= 32'h0;
            end
        end

        // Store transaction
        if (ex_if_req_i && ex_if_req_we_o) begin
            dmem_req_we_o <= ex_if_req_we_o;
        end

        // Load transaction
        if (dmem_rvalid_i && ex_if_ready_o) begin
            wb_if_rvalid_o <= dmem_rvalid_i;
            wb_if_rdata_o <= dmem_rsp_rdata_i;
        end
    end

    // Byte enable calculation
    function [3:0] calculate_byte_enable(input [31:0] addr, input [1:0] type);
        [3:0] byte_enable;
        case (type)
            2'b10: byte_enable = {4'b0000, addr[31:2]}; // Halfword
            2'b01: byte_enable = {addr[31:2], addr[2:0]}; // Word
            2'b00: byte_enable = addr[31:0]; // Byte
            default: byte_enable = 4'b0000; // Misaligned access
        endcase
        return byte_enable;
    endfunction

    // Address alignment check
    function bool is_aligned(input [31:0] addr);
        return (addr[31:2] == 3'b00) || (addr[2:0] == 3'b00);
    endfunction

endmodule
