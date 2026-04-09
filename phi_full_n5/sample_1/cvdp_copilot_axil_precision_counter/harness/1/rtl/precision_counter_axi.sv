module precision_counter_axi(
    input axi_aclk,
    input axi_aresetn,
    input [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr,
    input [C_S_AXI_DATA_WIDTH-1:0] axi_wdata,
    input [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb,
    input axi_wvalid,
    output axi_awready,
    output axi_bready,
    output axi_bresp,
    output slv_reg_ctl[31:0],
    output slv_reg_v[31:0],
    output slv_reg_t[31:0],
    output slv_reg_irq_mask[31:0],
    output slv_reg_irq_thresh[31:0],
    output irq
);

    reg [31:0] slv_reg_ctl;
    reg [31:0] slv_reg_v;
    reg [31:0] slv_reg_t;
    reg [31:0] slv_reg_irq_mask;
    reg [31:0] slv_reg_irq_thresh;
    logic irq;

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
            if (axi_wvalid) begin
                slv_reg_v <= slv_reg_v - axi_wdata;
                if (slv_reg_v == 0) begin
                    slv_reg_t <= 32'h00000000;
                    irq <= 1;
                end else begin
                    slv_reg_t <= slv_reg_t + 1'b1;
                end
            end else begin
                slv_reg_t <= slv_reg_t;
            end
        end
    end

    // Elapsed Time Register (slv_reg_t)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl) begin
            if (axi_wready) begin
                slv_reg_t <= slv_reg_t + 1;
            end else begin
                slv_reg_t <= slv_reg_t;
            end
        end
    end

    // Interrupt Mask Register (slv_reg_irq_mask)
    always @(posedge axi_aclk) begin
        if (axi_aresetn) begin
            slv_reg_irq_mask <= 0;
        end else begin
            slv_reg_irq_mask <= (axi_awaddr == 0x24) ? 1 : 0;
        end
    end

    // Interrupt Threshold Register (slv_reg_irq_thresh)
    always @(posedge axi_aclk) begin
        if (axi_aresetn) begin
            slv_reg_irq_thresh <= 0;
        end else begin
            slv_reg_irq_thresh <= axi_awaddr[15];
        end
    end

    // Write Response (axi_bresp)
    always @(posedge axi_aclk) begin
        if (axi_wvalid && axi_awready) begin
            axi_bresp <= (axi_awaddr == 0) ? 2'b00 : (axi_awaddr == 0x20) ? (axi_wdata == slv_reg_v) ? 2'b00 : 2'b10;
        end
    end

    // Read Response (axi_rdata)
    always @(posedge axi_aclk) begin
        if (axi_arvalid && axi_arready) begin
            axi_rdata <= (axi_araddr == 0x10) ? slv_reg_t : 32'h00000000;
            axi_rresp <= (axi_araddr == 0x20) ? slv_reg_v : 2'b00;
        end
    end

    // Interrupt Signal (irq)
    always @(posedge axi_aclk) begin
        if (slv_reg_ctl && (slv_reg_irq_mask && slv_reg_v == slv_reg_irq_thresh)) begin
            irq <= 1;
        end else begin
            irq <= 0;
        end
    end

endmodule