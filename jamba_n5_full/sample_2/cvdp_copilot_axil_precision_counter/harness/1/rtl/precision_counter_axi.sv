module precision_counter_axi (#(parameter C_S_AXI_DATA_WIDTH=32, C_S_AXI_ADDR_WIDTH=8));

    // Internal signals
    reg axi_aclk;
    reg axi_aresetn;
    reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wdata;
    reg [C_S_AXI_DATA_WIDTH/8-1:0] axi_wstrb;
    reg axi_wvalid;
    reg axi_bready;
    reg [1:0] axi_rresp;
    reg axi_rvalid;
    input axi_ap_done;
    output irq, ap_done;

    // Registers
    reg [31:0] slv_reg_ctl;
    reg [31:0] slv_reg_t;
    reg [31:0] slv_reg_v;
    reg [31:0] slv_reg_irq_mask;
    reg [31:0] slv_reg_irq_thresh;

    // Interrupt
    wire irq;

    // Counters
    always @(posedge axi_aclk or posedge axi_aresetn) begin
        if (axi_aresetn) begin
            slv_reg_ctl <= 32'd0;
            slv_reg_t <= 0;
            slv_reg_v <= 0;
            slv_reg_irq_mask <= 32'd0;
            slv_reg_irq_thresh <= 32'd0;
        end else begin
            slv_reg_ctl <= slv_reg_ctl;
            slv_reg_t <= slv_reg_t;
            slv_reg_v <= slv_reg_v;
            slv_reg_irq_mask <= slv_reg_irq_mask;
            slv_reg_irq_thresh <= slv_reg_irq_thresh;
        end
    end

    // Write Transaction
    always @(posedge axi_aclk or negedge axi_aresetn) begin
        if (!axi_aresetn) begin
            // Start countdown
            if (axi_awaddr == 32'h0000_0000) begin
                // Write to slv_reg_ctl
                slv_reg_ctl <= 32'd1;
            end else begin
                // ... ignore
            end
        end else begin
            if (axi_awready) begin
                // Write data
                if (axi_wvalid) begin
                    slv_reg_t <= 32'd0;
                    slv_reg_v <= 32'd0;
                end
            end
        end
    end

    // Read Transaction
    always @(posedge axi_aclk or negedge axi_aresetn) begin
        if (!axi_aresetn) begin
            // Read address
            if (axi_araddr == 32'h0000_0000) begin
                // Read data
                axi_rdata <= slv_reg_t;
                axi_rresp <= slv_reg_v;
                axi_rvalid <= 1'b1;
            end else begin
                axi_rdata <= 32'd0;
                axi_rresp <= 32'd10;
                axi_rvalid <= 1'b0;
            end
        end else begin
            // Check ap_done
            if (axi_ap_done) begin
                axi_rready <= 1'b1;
            end else begin
                axi_rready <= 1'b0;
            end
        end
    end

    // Interrupt generation
    always @(posedge axi_aclk) begin
        if (slv_reg_irq_mask && (slv_reg_v == 32'hFFFF_FFFF)) begin
            irq <= 1'b1;
        end else begin
            irq <= 1'b0;
        end
    end

    // Main handshake
    assign axi_awready = axi_awvalid;
    assign axi_wready = axi_wvalid;
    assign axi_rready = axi_arready;

endmodule
