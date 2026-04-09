module load_store_unit (
    input clk,
    input rst_n,
    input ex_if_req_i,
    input [1:0] ex_if_type_i,
    input [31:0] ex_if_addr_base_i,
    input [31:0] ex_if_addr_offset_i,
    output reg ex_if_we_o,
    output reg ex_if_ready_o,
    output reg dmem_req_o,
    output reg dmem_gnt_i,
    output reg [31:0] dmem_req_addr_o,
    output reg dmem_req_we_o,
    output reg [3:0] dmem_req_be_o,
    output reg dmem_req_wdata_o,
    input dmem_rvalid_i,
    output reg [31:0] dmem_rsp_rdata_o
);

    reg [1:0] byte_enable;
    reg [3:0] byte_offset;
    reg [31:0] word_offset;

    always @(posedge clk) begin
        if (rst_n) begin
            byte_enable <= 4'b0;
            byte_offset <= 0;
            word_offset <= 32'h0;
            ex_if_ready_o <= 1'b1;
            dmem_req_o <= 1'b0;
            dmem_gnt_i <= 1'b0;
            dmem_req_addr_o <= 32'h0;
            dmem_req_we_o <= 1'b0;
            dmem_req_be_o <= 4'b0;
            dmem_req_wdata_o <= 32'h0;
        end else begin
            case (ex_if_type_i)
                2'b00: begin
                    byte_enable = 4'b1000;
                    byte_offset = ex_if_addr_base_i + ex_if_addr_offset_i;
                end
                2'b01: begin
                    byte_enable = 4'b1100;
                    byte_offset = (ex_if_addr_base_i + ex_if_addr_offset_i) & 3; // Align to even address
                end
                2'b10: begin
                    byte_enable = 4'b0000;
                    word_offset = ex_if_addr_base_i + ex_if_addr_offset_i;
                end
                default: begin
                    byte_enable = 4'b0000;
                    byte_offset = 32'h0;
                end
            endcase

            if (ex_if_req_i) begin
                dmem_req_o <= 1'b1;
                dmem_req_addr_o <= byte_offset;
                dmem_req_be_o <= byte_enable;
                if (ex_if_type_i == 2'b00 || ex_if_type_i == 2'b01) begin
                    dmem_req_wdata_o <= ex_if_wdata_i;
                    dmem_req_we_o <= ex_if_we_i;
                end else if (ex_if_type_i == 2'b10) begin
                    dmem_req_wdata_o <= ex_if_wdata_i;
                    dmem_req_we_o <= ex_if_we_i;
                    word_offset <= ex_if_addr_base_i + ex_if_addr_offset_i;
                end
                ex_if_ready_o <= 0;
            end else begin
                ex_if_ready_o <= 1;
            end
        end else begin
            dmem_req_o <= 1'b0;
            dmem_req_addr_o <= 32'h0;
            dmem_req_be_o <= 4'b0;
            dmem_req_wdata_o <= 32'h0;
            dmem_req_we_o <= 1'b0;
            ex_if_ready_o <= 1;
            dmem_gnt_i <= 1'b0;
        end
    end

    always @(posedge dmem_gnt_i or posedge rst_n) begin
        if (!rst_n) begin
            byte_enable <= 4'b0;
            byte_offset <= 0;
            word_offset <= 32'h0;
        end else begin
            casez (dmem_gnt_i)
                1'b1: begin
                    ex_if_ready_o <= 1'b0;
                    dmem_req_o <= 1'b0;
                    dmem_req_addr_o <= byte_offset;
                    dmem_req_we_o <= 1'b0;
                    dmem_req_be_o <= byte_enable;
                    dmem_req_wdata_o <= 32'h0;
                end
                default: begin
                    ex_if_ready_o <= 1'b1;
                    dmem_req_o <= 1'b1;
                    dmem_req_addr_o <= word_offset;
                    dmem_req_we_o <= ex_if_we_i;
                    dmem_req_wdata_o <= ex_if_wdata_i;
                    byte_offset <= 32'h0;
                    word_offset <= ex_if_addr_base_i + ex_if_addr_offset_i;
                    byte_enable <= 4'b0000;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (ex_if_we_o && ex_if_req_i) begin
            dmem_rsp_rdata_o <= dmem_rvalid_i ? dmem_rsp_rdata_i : 32'h0;
        end
    end
endmodule
