module load_store_unit;

    parameter CLK_PERIOD = 5; // In time units? Not necessary, just keep simple.

    reg clk;
    reg rst_n;

    wire ex_if_ready_o;
    wire dmem_req_o;
    wire dmem_req_we_o;
    wire dmem_req_addr_o[31:0];
    wire dmem_req_be_o[3:0];
    wire dmem_req_wdata_o[31:0];
    wire dmem_rvalid_i;
    wire dmem_rsp_rdata_i[31:0];

    wire ex_if_type_i;
    wire ex_if_wdata_i[31:0];
    wire ex_if_addr_base_i[31:0];
    wire ex_if_addr_offset_i[31:0];
    wire ex_if_ready_o;
    wire ex_if_we_i;
    wire ex_if_type_i[1:0];
    wire ex_if_wdata_i[31:0];
    wire ex_if_addr_base_i[31:0];
    wire ex_if_addr_offset_i[31:0];

    wire wb_if_rdata_o[31:0];
    wire wb_if_rvalid_o;

    always_ff @(posedge clk) begin
        if (rst_n) begin
            ex_if_ready_o <= 1'b1;
            dmem_req_o <= 1'b0;
            dmem_req_we_o <= 1'b0;
            dmem_req_addr_o[31:0] <= 0;
            dmem_req_be_o <= 4'b0;
            dmem_req_wdata_o[31:0] <= 0;
            dmem_rvalid_i <= 1'b0;
            dmem_rsp_rdata_i <= 32'b0;
            ex_if_ready_o <= 1'b1;
            ex_if_we_i <= 1'b0;
            ex_if_type_i <= 2'b0;
            ex_if_wdata_i <= 32'b0;
            ex_if_addr_base_i <= 32'b0;
            ex_if_addr_offset_i <= 32'b0;
        end else begin
            ex_if_ready_o <= ex_if_ready_o;
            dmem_req_o <= dmem_req_o;
            dmem_req_we_o <= dmem_req_we_o;
            dmem_req_addr_o[31:0] <= dmem_req_addr_o;
            dmem_req_be_o <= dmem_req_be_o;
            dmem_req_wdata_o[31:0] <= dmem_req_wdata_o;
            dmem_rvalid_i <= dmem_rvalid_i;
            dmem_rsp_rdata_i <= dmem_rsp_rdata_i;
            ex_if_ready_o <= ex_if_ready_o;
            ex_if_we_i <= ex_if_we_i;
            ex_if_type_i <= ex_if_type_i;
            ex_if_wdata_i <= ex_if_wdata_i;
            ex_if_addr_base_i <= ex_if_addr_base_i;
            ex_if_addr_offset_i <= ex_if_addr_offset_i;
        end
    end

    assign dmem_req_addr_o = ex_if_addr_base_i + ex_if_addr_offset_i;

    assign dmem_req_be_o = (ex_if_type_i == 0x0) ? 1'b1 : (ex_if_type_i == 0x1) ? 1'b1 : 4'b0;

    assign dmem_req_wdata_o[31:0] = ex_if_wdata_i;

    assign wb_if_rdata_o = (wb_if_rvalid_o) ? dmem_rsp_rdata_i : 32'b0;

    assign ex_if_type_i = (ex_if_type_i == 0x2) ? 2'b10 : (ex_if_type_i == 0x1) ? 2'b01 : 2'b00;

    assign ex_if_ready_o = (dmem_gnt_i & ex_if_ready_o);

    assign ex_if_we_i = (ex_if_type_i == 0x2) && (ex_if_wdata_i != 32'b0);

    assign wb_if_rvalid_o = dmem_rvalid_i;

endmodule
