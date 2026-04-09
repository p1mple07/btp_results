module load_store_unit;

    localparam RST_N_PIN = 1;
    localparam CLK_PIN   = 1;
    localparam EX_REQ_PIN= 1;

    input clk,
        rst_n,
        dmem_req_o,
        dmem_gnt_i,
        dmem_req_addr_o[31:0],
        dmem_req_we_o,
        dmem_req_be_o[3:0],
        dmem_req_wdata_o[31:0],
        dmem_rvalid_i,
        dmem_rsp_rdata_i[31:0];

    output ex_if_ready_o,
        ex_if_we_i,
        ex_if_type_i[1:0],
        ex_if_wdata_i[31:0],
        ex_if_addr_base_i[31:0],
        ex_if_addr_offset_i[31:0],
        ex_if_ready_o,
        wb_if_rdata_o[31:0],
        wb_if_rvalid_o;

    reg [31:0] ex_if_addr_base_i;
    reg [31:0] ex_if_addr_offset_i;
    reg [3:0] ex_if_type_i;
    reg [3:0] ex_if_wdata_i;
    reg dmem_req_o;
    reg dmem_req_we_o;
    reg dmem_req_be_o[3:0];
    reg dmem_req_wdata_o[31:0];
    reg ex_if_ready_o;
    reg wb_if_rdata_o[31:0];
    reg wb_if_rvalid_o;

    always @(posedge clk) begin
        if (rst_n) begin
            ex_if_ready_o <= 0;
            ex_if_we_i <= 0;
            ex_if_type_i <= 2'b00;
            ex_if_wdata_i <= 32'h0;
            ex_if_addr_base_i <= 0;
            ex_if_addr_offset_i <= 0;
            ex_if_ready_o <= 1;
            dmem_req_o <= 0;
            dmem_req_we_o <= 0;
            dmem_req_be_o[0:0] <= 0;
            dmem_req_wdata_o[0:0] <= 0;
            dmem_req_addr_o <= 32'd0;
            dmem_req_addr_o <= 0;
            wb_if_rdata_o[0:0] <= 0;
            wb_if_rvalid_o <= 1;
        end else begin
            if (ex_if_ready_o && ex_if_req_i) begin
                if (ex_if_addr_offset_i == 0) begin
                    ex_if_addr_base_i = dmem_req_addr_o;
                    ex_if_addr_offset_i = 32'h0;
                end else if (ex_if_addr_offset_i == 16'h0) begin
                    ex_if_addr_base_i = dmem_req_addr_o;
                    ex_if_addr_offset_i = 16'h0;
                end else if (ex_if_addr_offset_i == 32'h0) begin
                    ex_if_addr_base_i = dmem_req_addr_o;
                    ex_if_addr_offset_i = 32'h0;
                end else begin
                    ex_if_ready_o <= 0;
                end

                if (ex_if_type_i[0] == 1'b0) begin
                    dmem_req_be_o[0:0] <= 1'b1;
                    dmem_req_wdata_o[0:0] <= dmem_req_wdata_o[0];
                end else if (ex_if_type_i[0] == 1'b1) begin
                    dmem_req_be_o[0:0] <= 1'b0;
                    dmem_req_wdata_o[1:0] <= dmem_req_wdata_o[1:0];
                end else if (ex_if_type_i[0] == 1'b2) begin
                    dmem_req_be_o[0:0] <= 1'b1;
                    dmem_req_wdata_o[2:0] <= dmem_req_wdata_o[2:0];
                end

                if (ex_if_addr_offset_i != 0 && ex_if_addr_base_i & (32'h00000000 ^ (ex_if_addr_offset_i >> 3))) begin
                    ex_if_ready_o <= 0;
                } else begin
                    ex_if_addr_base_i = dmem_req_addr_o + 32'h0;
                    dmem_req_addr_o = ex_if_addr_base_i;
                end

                ex_if_addr_base_i <= ex_if_addr_base_i;
                ex_if_addr_offset_i <= ex_if_addr_offset_i;
                dmem_req_addr_o <= ex_if_addr_base_i;
                dmem_req_addr_o <= ex_if_addr_base_i;

                dmem_req_we_o <= 1'b1;
                ex_if_ready_o <= 1;
            end else if (ex_if_ready_o && ex_if_req_i) begin
                // Continue existing transaction
            end else if (!ex_if_ready_o && !ex_if_req_i) begin
                ex_if_ready_o <= 0;
            end
        end
    end

    always @(posedge clk) begin
        if (wb_if_rvalid_o) begin
            wb_if_rdata_o[31:0] <= dmem_rsp_rdata_i;
            wb_if_rvalid_o <= 1'b1;
            wb_if_rvalid_o <= 1'b0;
        end
    end

endmodule
