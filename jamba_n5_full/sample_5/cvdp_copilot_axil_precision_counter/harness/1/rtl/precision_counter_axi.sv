module precision_counter_axi(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input axi_awvalid,
    output axi_awready,
    output axi_bvalid,
    output axi_bready,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input axi_wvalid,
    output axi_bresp,
    output axi_bvalid,
    input axi_ap_done,
    input irq,
    output reg [1:0] axi_ap_done,
    output reg irq
);

always @(posedge axi_aclk) begin
    if (axi_aresetn) begin
        axi_awready <= 1'b0;
        axi_wready <= 1'b0;
        axi_arready <= 1'b0;
        axi_rready <= 1'b0;
        axi_bresp <= 1'b0;
        axi_bvalid <= 1'b0;
    end else begin
        // ... rest of logic
    end
end

endmodule
