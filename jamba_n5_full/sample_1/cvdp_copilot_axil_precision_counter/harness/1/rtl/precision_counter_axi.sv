module precision_counter_axi (
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input axi_awvalid,
    input axi_wdata,
    input [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb,
    input axi_wvalid,
    input axi_bready,
    output axi_bvalid,
    output [1:0] axi_bresp,
    output axi_awready,
    output axi_wready,
    output axi_rready,
    output [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output [1:0] axi_rresp,
    output axi_rvalid
);

// ... implementation

endmodule
