module precision_counter_axi #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 8
)(
    input axis_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input axi_awvalid,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input axi_wvalid,
    input axi_bready,
    output axi_bresp,
    output axi_bvalid,
    output axi_awready,
    output axi_wready,
    output axi_ap_done,
    output irq
);

localparam AXI_ADDR_WIDTH = C_S_AXI_ADDR_WIDTH;
localparam AXI_DATA_WIDTH = C_S_AXI_DATA_WIDTH;

reg [AXI_ADDR_WIDTH-1:0] slv_reg_ctl;
reg [AXI_DATA_WIDTH-1:0] slv_reg_v;
reg [AXI_DATA_WIDTH-1:0] slv_reg_t;
reg [AXI_DATA_WIDTH-1:0] slv_reg_irq_mask;
reg [AXI_DATA_WIDTH-1:0] slv_reg_irq_thresh;

always @(posedge axis_aclk) begin
    if (axi_aresetn) begin
        slv_reg_ctl <= 32'd0;
        slv_reg_v <= 32'd0;
        slv_reg_t <= 32'd0;
        slv_reg_irq_mask <= 32'd0;
        slv_reg_irq_thresh <= 32'd0;
    end else begin
        if (axi_awvalid) begin
            slv_reg_ctl <= axi_awaddr;
            slv_reg_v <= 0;
        end
        if (axi_wvalid) begin
            slv_reg_t <= axi_wdata;
            slv_reg_ctl <= axi_awaddr;
        end
        if (axi_arvalid) begin
            slv_reg_irq_thresh <= axi_rdata;
        end
        if (axi_rvalid) begin
            slv_reg_irq_mask <= axi_rresp;
        end
    end
end

always @(*) begin
    axi_ap_done = slv_reg_v == 0;
end

always @(*) begin
    axi_irq = (slv_reg_irq_mask & slv_reg_irq_thresh) && axi_aresetn;
end

endmodule
