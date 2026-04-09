module precision_counter_axi #(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 8
)(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input axi_awvalid,
    input axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input axi_wvalid,
    input axi_bready,
    output axi_awready,
    output axi_wready,
    output [1:0] axi_bresp,
    output axi_bvalid,
    output axi_arready,
    output axi_rdata,
    output [1:0] axi_rresp,
    output axi_rvalid,
    output axi_ap_done,
    output irq
);

// ... implement registers and logic

endmodule
