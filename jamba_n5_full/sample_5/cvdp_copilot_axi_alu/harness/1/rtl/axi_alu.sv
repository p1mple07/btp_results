wire [31:0] operand_a_cdc, operand_b_cdc, operand_c_cdc;
wire [1:0]  op_select_cdc;
wire        start_cdc;
wire [31:0] operand_a_sync, operand_b_sync, operand_c_sync;
wire [1:0]  op_select_sync;
wire        start_sync;

clock_control u_clock_control (
    .axi_clk_in  (axi_clk_in),
    .fast_clk_in (fast_clk_in),
    .clk_ctrl    (clock_control),
    .clk         (clk)
);

axi_csr_block u_axi_csr_block (
    .axi_aclk_i    (axi_clk_in),
    .axi_areset_i  (reset_in),
    .axi_awvalid_i   (axi_awvalid_i),
    .axi_awready_o   (axi_awready_o),
    .axi_awaddr_i    (axi_awaddr_i),
    .axi_wvalid_i    (axi_wvalid_i),
    .axi_wready_o    (axi_wready_o),
    .axi_wdata_i     (axi_wdata_i),
    .axi_wstrb_i     (axi_wstrb_i),
    .axi_bvalid_o    (axi_bvalid_o),
    .axi_bready_i    (axi_bready_i),
    .axi_arvalid_i   (axi_arvalid_i),
    .axi_arready_o   (axi_arready_o),
    .axi_araddr_i    (axi_araddr_i),
    .axi_rvalid_o    (axi_rvalid_o),
    .axi_rready_i    (axi_rready_i),
    .axi_rdata_o     (axi_rdata_o),
    .operand_a     (operand_a_cdc),
    .operand_b     (operand_b_cdc),
    .operand_c     (operand_c_cdc),
    .op_select     (op_select_cdc),
    .start         (start_cdc),
    .clock_control (clock_control)
);

