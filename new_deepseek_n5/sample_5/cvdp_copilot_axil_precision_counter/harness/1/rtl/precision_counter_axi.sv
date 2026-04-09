Module for precision_counter_axi implementation
module precision_counter_axi (
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input axi_arvalid,
    input axi_wvalid,
    input axi_bvalid,
    input axi_rvalid,
    output axi_awready,
    output axi_wready,
    output axi_bresp,
    output axi_rresp,
    output axi_ap_done,
    output wire irq
);

// Parameters
parameter C_S_AXI_DATA_WIDTH = 32;
parameter C_S_AXI_ADDR_WIDTH = 8;

// Internal registers
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_ctl = 0;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_t = 0;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_v = 0;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_irq_mask = 0;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg_irq_thresh = 0;

// Start/Stop control
always @(posedge axi_aclk) begin
    if (axi_aresetn) begin
        slv_reg_ctl = 0;
        slv_reg_t = 0;
        slv_reg_v = 0;
    end else if (axi_arvalid) begin
        if (slv_reg_v == 0) begin
            slv_reg_t = 0;
        end else if (slv_reg_v > 0) begin
            slv_reg_t = slv_reg_t + 1;
            slv_reg_v = slv_reg_v - 1;
        end
    end
end

// Interrupt handling
always @(axi_aclk) begin
    if (axi_aresetn) begin
        slv_reg_irq_mask = 0;
        slv_reg_irq_thresh = 0;
    end else if (axi_rvalid && (slv_reg_v == slv_reg_irq_thresh)) begin
        if (slv_reg_irq_mask & 0x00000001) begin
            irq = 1;
        end
        slv_reg_irq_thresh = slv_reg_irq_thresh + 1;
    end
end

// Write transaction
always @(posedge axi_aclk) begin
    if (axi_aresetn) begin
        slv_reg_awvalid = 0;
    end else if (axi_awvalid) begin
        if (axi_arvalid) begin
            if (slv_reg_wvalid) begin
                if (slv_reg_awready) begin
                    slv_reg_bvalid = 1;
                    slv_reg_arvalid = 1;
                end
            end
        end
    end
end

// Read transaction
always @(posedge axi_aclk) begin
    if (axi_aresetn) begin
        slv_reg_arvalid = 0;
    end else if (axi_arvalid) begin
        if (slv_reg_rvalid) begin
            if (slv_reg_rready) begin
                slv_reg_rvalid = 1;
                slv_reg_arvalid = 1;
            end
        end
    end
end

// Register outputs
wire [C_S_AXI_DATA_WIDTH-1:0] slv_reg_awdata;
wire [C_S_AXI_DATA_WIDTH-1:0] slv_reg_wdata;
wire [C_S_AXI_DATA_WIDTH/8-1:0] slv_reg_wstrb;

endmodule