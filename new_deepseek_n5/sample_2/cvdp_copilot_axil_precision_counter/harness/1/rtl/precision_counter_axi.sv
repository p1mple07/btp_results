module precision_counter_axi(
    parameter C_S_AXI_DATA_WIDTH,
    parameter C_S_AXI_ADDR_WIDTH
);

  // AXI4-Lite protocol-related signals
  input axi_aclk;
  input axi_aresetn;
  input axi_awaddr;
  input axi_araddr;
  input axi_awvalid;
  input axi_arvalid;
  input axi_wdata;
  input axi_wstrb;
  input axi_wvalid;
  input axi_rdata;
  output axi_rvalid;

  output axi_bvalid;
  output axi_bready;
  output axi_rready;
  output axi_ap_done;
  output irq;

  // Control and status registers
  register [C_S_AXI_DATA_WIDTH-1:0] axi_wdata_reg;
  register [C_S_AXI_DATA_WIDTH-1:0] axi_rdata_reg;
  register [C_S_AXI_ADDR_WIDTH-1:0] axi_waddr_reg;
  register [C_S_AXI_ADDR_WIDTH-1:0] axi_raddr_reg;
  register [31:0] slv_reg_ctl;
  register [31:0] slv_reg_t;
  register [31:0] slv_reg_v;
  register [31:0] slv_reg_irq_mask;
  register [31:0] slv_reg_irq_thresh;

  // Module state
  reg done;

  // Parameters
  parameter AXI4LITE_WIDTH = 32;

  // Module initialization
  initial begin
    done = 0;
    // Initialize all registers to 0
    axi_wdata_reg = 0;
    axi_rdata_reg = 0;
    axi_waddr_reg = 0;
    axi_raddr_reg = 0;
    slv_reg_v = 0;
    slv_reg_t = 0;
    slv_reg_irq_mask = 0;
    slv_reg_irq_thresh = 0;
  end

  // Start/Stop control
  always @*+begin
    if (axi_awvalid && axi_arvalid) begin
      if (slv_reg_v == 0 && done == 0) begin
        // Start countdown
        slv_reg_v = 0;
        done = 1;
      end
    end
  end
  always @*+end

  // Write operation
  always @*+begin
    if (axi_wvalid && axi_awvalid) begin
      if (done == 0) begin
        axi_awready = 1;
        axi_wdata_reg = axi_wdata;
        axi_wstrb = axi_wstrb;
        axi_wvalid = 1;
      end else begin
        // Wait for write ready
        while (!axi_wready) continue;
      end
    end
  end
  always @*+end

  // Read operation
  always @*+begin
    if (axi_rvalid && axi_arvalid) begin
      if (done == 0) begin
        axi_arready = 1;
        axi_rdata_reg = axi_rdata;
        axi_rvalid = 1;
      end else begin
        // Wait for read ready
        while (!axi_rready) continue;
      end
    end
  end
  always @*+end

  // AXI4-Lite handshake completion
  always @*+begin
    if (axi_awvalid && axi_arvalid) begin
      if (done == 0) begin
        axi_bvalid = 1;
        axi_bready = 1;
      end else begin
        // Wait for handshake completion
        while (!axi_bready && !axi_rready) continue;
      end
    end
  end
  always @*+end

  // Interrupt handling
  always @*+begin
    if (irq) begin
      if (slv_reg_irq_mask & 1) begin
        if (slv_reg_v == slv_reg_irq_thresh) begin
          irq = 1;
        end
      end
      // Mask the irq signal
      irq = ~ (irq & slv_reg_irq_mask);
    end
  end
  always @*+end
endmodule