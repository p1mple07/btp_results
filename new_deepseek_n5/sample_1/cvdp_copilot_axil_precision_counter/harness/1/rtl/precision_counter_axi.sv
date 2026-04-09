module precision_counter_axi(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input [C_S_AXI_WDATA_WIDTH-1:0] axi_wvalid,
    output axi_awready,
    output [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    output [1:0] axi_bresp,
    output axi_bready,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input axi_arvalid,
    input axi_arready,
    output axi_rdata,
    output [1:0] axi_rresp,
    output axi_rready,
    output axi_ap_done,
    output axi_irq
);

// AXI4-Lite Slave implementation
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_wdata;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_rdata;
reg [C_S_AXI_ADDR_WIDTH-1:0] slv_reg_araddr;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_v;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_t;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_bvalid;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_rvalid;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_awvalid;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_arvalid;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_bresp;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_rresp;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_awready;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_arready;
reg [C_S_AXI Data_WIDTH-1:0] slv_reg_rready;

always begin
    // Initialize registers
    slv_reg_v = 0;
    slv_reg_t = 0;
    slv_reg_awvalid = 0;
    slv_reg_arvalid = 0;
    slv_reg_bvalid = 0;
    slv_reg_rvalid = 0;
    slv_reg_awready = 0;
    slv_reg_arready = 0;
    slv_reg_rready = 0;
    slv_reg_bresp = 0b00;
    slv_reg_rresp = 0b00;
end

// Write transaction
always AXI4LITE_WRITE initiate AXI4LITE_WRITE #(axi_awaddr, axi_wdata, axi_wstrb, axi_wvalid, axi_awready) (
    slv_reg_awvalid,
    slv_reg_wdata,
    slv_reg_wstrb,
    slv_reg_wvalid,
    slv_reg_awready
);

// Read transaction
always AXI4LITE_READ initiate AXI4LITE_READ #(axi_araddr, axi_arvalid, axi_arready) (
    slv_reg_arvalid,
    slv_reg_araddr,
    slv_reg_arready
);

// Elapsed time
always AXI4LITE_READ initiate AXI4LITE_READ #(slv_reg_araddr, axi_rdata, axi_arvalid, axi_arready) (
    slv_reg_t,
    axi_rdata,
    1
);

// Countdown
always AXI4LITE_WRITE initiate AXI4LITE_WRITE #(slv_reg_araddr, slv_reg_v, axi_wstrb, axi_wvalid, axi_awready) (
    slv_reg_v,
    slv_reg_v,
    axi_wstrb,
    1,
    1
);

// interrupts
always AXI4LITE_INTERRUPT initiate AXI4LITE_INTERRUPT #(slv_reg_araddr, axi_irq) (
    slv_reg_v,
    axi_irq
);

// Main logic
always AXI4LITE_SLAVE initiate AXI4LITE_SLAVE #(axi_aclk, axi_aresetn, axi_awaddr, axi_araddr, axi_wdata, axi_arvalid, axi_wstrb, axi_arvalid, axi_wvalid, axi_wvalid, axi_awready, axi_arready, axi_rready, axi_rvalid, axi_rdata, axi_bresp, axi_rresp, axi_bvalid, axi_ap_done, axi_irq) (
    axi_awaddr,
    axi_araddr,
    axi_wdata,
    axi_arvalid,
    axi_wstrb,
    axi_arvalid,
    axi_wvalid,
    axi_wvalid,
    axi_awready,
    axi_arready,
    axi_rready,
    axi_rvalid,
    axi_rdata,
    axi_bresp,
    axi_rresp,
    axi_bvalid,
    axi_ap_done,
    axi_irq
);

endmodule