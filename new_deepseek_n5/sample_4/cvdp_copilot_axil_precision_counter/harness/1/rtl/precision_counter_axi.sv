module precision_counter_axi(
    input wire [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input wire [(C_S_AXI_DATA_WIDTH/8-1):0] axi_wstrb,
    input wire axi_wvalid,
    input wire axi_aclk,
    input wire axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input wire axi_awvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_bdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_bstrb,
    output wire axi_bvalid,
    output wire axi_bready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input wire axi_arvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_rstrb,
    output wire axi_rvalid,
    output wire axi_rready,
    output wire axi_ap_done,
    output wire irq,
    input wire [C_S_AXI Data_WIDTH-1:0] axi_aclk,
    input wire axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input wire axi_awvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_wstrb,
    output wire axi_wvalid,
    output wire axi_wready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input wire axi_arvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_rstrb,
    output wire axi_rvalid,
    output wire axi_rready,
    output wire axi_ap_done,
    output wire irq,
    input wire [C_S_AXI Data_WIDTH-1:0] axi_aclk,
    input wire axi_aresetn,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input wire axi_awvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_wstrb,
    output wire axi_wvalid,
    output wire axi_wready,
    input wire [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input wire axi_arvalid,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output reg [(C_S_AXI_DATA_WIDTH/8-1):0] axi_rstrb,
    output wire axi_rvalid,
    output wire axi_rready,
    output wire axi_ap_done,
    output wire irq
);

always @(posedge axi_aclk) begin
    if (axi_aresetn) begin
        slv_reg_ctl[7:0] = 0x00;
        slv_reg_t[7:0] = 0x00;
        slv_reg_v[7:0] = 0x00;
        slv_reg_irq_mask[7:0] = 0x00;
        slv_reg_irq_thresh[7:0] = 0x00;
        slv_reg_ap_done = 0;
        irq = 0x00;
    end else begin
        if (axi_awvalid && axi_wvalid) begin
            axi_awready = 1;
            axi_wdata[7:0] = axi_wdata[7:0];
            axi_wstrb[7:0] = axi_wstrb[7:0];
            axi_wvalid = 1;
            axi_wready = 1;
        end else begin
            axi_awready = 0;
            axi_wvalid = 0;
            axi_wready = 0;
        end
    end
end

always @(posedge axi_aclk) begin
    if (slv_reg_ctl[0] == 1 && slv_reg_v[0] == 0) begin
        axi_ap_done = 1;
        slv_reg_v[0] = 0x00;
    end else if (slv_reg_v[0] == 0) begin
        slv_reg_v[0] = (slv_reg_v[1:0] + 1);
    end
end

always @(posedge axi_aclk) begin
    if (slv_reg_v[0] == 0 && slv_reg_t[0] == 0) begin
        axi_rdone = 1;
        slv_reg_t[0] = 1;
    end else if (slv_reg_v[0] == 0) begin
        slv_reg_t[0] = (slv_reg_t[1:0] + 1);
    end
end

// Add AXI write transaction handling
always @(posedge axi_aclk) begin
    if (slv_reg_ctl[0] == 1 && axi_awvalid && axi_wvalid) begin
        axi_bvalid = 1;
        axi_bresp[0] = 0;
    end else begin
        axi_bvalid = 0;
        axi_bresp[0] = 1;
    end
end

// Add AXI read transaction handling
always @(posedge axi_aclk) begin
    if (slv_reg_ctl[0] == 1 && axi_arvalid && axi_rvalid) begin
        axi_rvalid = 1;
        axi_rresp[0] = 0;
    end else begin
        axi_rvalid = 0;
        axi_rresp[0] = 1;
    end
end

// Add interrupt handling
always @(posedge axi_aclk) begin
    if (slv_reg_irq_mask[0] == 1 && slv_reg_v[0] == slv_reg_irq_thresh[0]) begin
        irq = 1;
    end else begin
        irq = 0;
    end
end