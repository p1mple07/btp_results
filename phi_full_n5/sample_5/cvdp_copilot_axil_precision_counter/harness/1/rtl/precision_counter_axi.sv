module precision_counter_axi(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb,
    input axi_wvalid,
    input axi_awready,
    output axi_bresp,
    output axi_bvalid,
    output axi_bready,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr,
    input axi_arvalid,
    input axi_arready,
    output reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata,
    output reg axi_rresp,
    output reg ap_done,
    output reg irq
);

    parameter C_S_AXI_DATA_WIDTH = 32;
    parameter C_S_AXI_ADDR_WIDTH = 8;

    reg [31:0] slv_reg_ctl;
    reg [31:0] slv_reg_t;
    reg [31:0] slv_reg_v;
    reg [31:0] slv_reg_irq_mask;
    reg [31:0] slv_reg_irq_thresh;

    // Control Register (slv_reg_ctl)
    always @(posedge axi_aclk) begin
        if (axi_aresetn) begin
            slv_reg_ctl <= 0;
        end else begin
            slv_reg_ctl <= (axi_awaddr == 0) ? 0 : 1;
        end
    end

    // Countdown Register (slv_reg_v)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl) begin
            if (slv_reg_v == 32'hFFFF) begin
                slv_reg_v <= 0;
                ap_done <= 1;
            end else begin
                slv_reg_v <= slv_reg_v - 1;
            end
        end
    end

    // Elapsed Time Register (slv_reg_t)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl) begin
            if (slv_reg_v == 0) begin
                slv_reg_t <= slv_reg_t + 1;
            end else begin
                slv_reg_t <= slv_reg_t;
            end
        end
    end

    // Interrupt Mask Register (slv_reg_irq_mask)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl) begin
            slv_reg_irq_mask <= (axi_araddr == 0) ? 0 : slv_reg_irq_mask;
        end
    end

    // Interrupt Threshold Register (slv_reg_irq_thresh)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl) begin
            slv_reg_irq_thresh <= axi_araddr;
        end
    end

    // Interrupt Signal (irq)
    always @(posedge axi_aclk) begin
        if (slv_reg_v == slv_reg_irq_thresh && slv_reg_irq_mask) begin
            irq <= 1;
        end else begin
            irq <= 0;
        end
    end

    // Write Data Response
    always @(posedge axi_wvalid or posedge axi_awready) begin
        if (axi_wready) begin
            if (axi_wvalid) begin
                if (axi_awaddr == C_S_AXI_ADDR_WIDTH-1) begin
                    slv_reg_v <= axi_wdata;
                    axi_bresp <= 32'b00;
                    axi_bvalid <= 1;
                    axi_bready <= 1;
                end else begin
                    axi_bresp <= 32'b10; // SLVERR
                end
            end else begin
                axi_bresp <= 32'b11; // Busy
                axi_bvalid <= 0;
                axi_bready <= 0;
            end
        end
    end

    // Read Data Response
    always @(posedge axi_arvalid or posedge axi_arready) begin
        if (axi_arready) begin
            if (axi_arvalid) begin
                if (axi_araddr == C_S_AXI_ADDR_WIDTH-1) begin
                    axi_rdata <= slv_reg_v;
                    axi_rresp <= 32'b00;
                end else if (axi_araddr == C_S_AXI_ADDR_WIDTH-2) begin
                    ap_done <= slv_reg_ctl;
                end else if (axi_araddr == C_S_AXI_ADDR_WIDTH-3) begin
                    slv_reg_irq_mask <= axi_rdata;
                end else if (axi_araddr == C_S_AXI_ADDR_WIDTH-4) begin
                    slv_reg_irq_thresh <= axi_rdata;
                end
                axi_rresp <= 32'b00;
            end else {
                axi_rdata <= 32'h00000000;
                axi_rresp <= 32'b11; // SLVERR
            }
        end
    end

endmodule