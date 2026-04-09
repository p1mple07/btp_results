module axi_alu (
    input  wire        axi_clk_in,
    input  wire        fast_clk_in,
    input  wire        reset_in,
    input  wire [31:0] axi_awvalid_i,
    input  wire [3:0]  axi_wstrb_i,
    input  wire        axi_wvalid_i,
    input  wire [31:0] axi_wdata_i,
    input  wire [63:0] result_o
);
    
    wire [31:0] operand_a, operand_b, operand_c;
    wire [1:0]  op_select;
    wire start;
    wire [31:0] data_a, data_b, data_c;
    wire [63:0] result;
    wire [31:0] operand_a_cdc, operand_b_cdc, operand_c_cdc;
    wire [1:0]  op_select_cdc;
    wire start_cdc;
    wire [31:0] data_a_cdc, data_b_cdc, data_c_cdc;
    wire [64'h000000:64'h000000] memory_data;
    
    // AXI Interface
    wire [31:0] axi_awvalid_o, axi_wready_o, axi_bvalid_o, axi_arready_o, axi_rvalid_o;
    wire [31:0] axi_arvalid_o, axi_arread_o, axi_rvalid_o;
    wire [31:0] axi_rvalid_o;
    
    // AXI Control
    wire [31:0] axi_awvalid_i, axi_awready_i, axi_wvalid_i, axi_wready_i, axi_rvalid_i;
    
    // AXI to CSR
    wire [31:0] axi_awready_o, axi_wready_o, axi_bvalid_o, axi_rvalid_o;
    wire [31:0] axi_arvalid_o, axi_arready_o, axi_rvalid_o;
    wire [31:0] axi_rvalid_o;
    
    // DSP
    wire [63:0] dsp_result;
    
    // Clock Control
    wire clock_control;
    
    // AXI to CSR Block (With Burst Support)
    axi_csr_block (
        .axi_a (axi_clk_in),
        .axi_a_reset_in(reset_in),
        .axi_awvalid_i(axi_awvalid_i),
        .axi_awready_i(axi_awready_i),
        .axi_wvalid_i(axi_wvalid_i),
        .axi_wready_i(axi_wready_i),
        .axi_rvalid_i(axi_rvalid_i),
        .start(start),
        .clock(clock_control),
        .axi_awlen_i(8),
        .axi_awsize_i(32),
        .axi_awburst_i(0),
        .axi_wlast_i(0),
        .axi_arlen_i(8),
        .axi_arsize_i(32),
        .axi_arburst_i(0),
        .axi_rlast_o(0),
        .axi_bvalid_o(0),
        .axi_arready_o(0),
        .axi_rvalid_o(0),
        .axi_rdata_o(dsp_result)
    );
    
    // Memory Block
    memory_block (
        .clk(clock_control),
        .reset_in(reset_in),
        .address_a (operand_a_cdc),
        .address_b (operand_b_cdc),
        .address_c (operand_c_cdc),
        .data_a (data_a_cdc),
        .data_b (data_b_cdc),
        .data_c (data_c_cdc),
        .op_select (op_select_cdc),
        .start (start_cdc),
        .result_address (result)
    );
    
    // DSP Block
    dsp_block (
        .clk(clock_control),
        .reset_in(reset_in),
        .operand_a (operand_a_cdc),
        .operand_b (operand_b_cdc),
        .operand_c (operand_c_cdc),
        .op_select (op_select_cdc),
        .start (start_cdc),
        .result (dsp_result)
    );
    
    // CDC Synchronizers
    cdc_synchronizer #(.WIDTH(32)) u_cdc_operand_a (.clk(clock_control), .clk_src(axi_clk_in), .data_in(operand_a_cdc), .data_out(operand_a));
    cdc_synchronizer #(.WIDTH(32)) u_cdc_operand_b (.clk(clock_control), .clk_src(axi_clk_in), .data_in(operand_b_cdc), .data_out(operand_b));
    cdc_synchronizer #(.WIDTH(32)) u_cdc_operand_c (.clk(clock_control), .clk_src(axi_clk_in), .data_in(operand_c_cdc), .data_out(operand_c));
    cdc_synchronizer #(.WIDTH(1))  u_cdc_start (.clk(clock_control), .clk_src(axi_clk_in), .data_in(start_cdc), .data_out(start));
    cdc_synchronizer #(.WIDTH(1))  u_cdc_rvalid_o (.clk(clock_control), .clk_src(axi_clk_in), .data_in(axi_rvalid_o), .data_out(0));