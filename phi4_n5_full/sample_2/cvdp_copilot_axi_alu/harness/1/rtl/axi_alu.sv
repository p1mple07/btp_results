rtl/axi_alu.sv
------------------------------------------------------------
// RTL for AXI ALU with fixed CDC, burst AXI interface, memory write support,
// and DSP result capture.
//------------------------------------------------------------

module axi_alu (
    input  wire        axi_clk_in,
    input  wire        fast_clk_in,
    input  wire        reset_in,
    
    // AXI Write Address Channel
    input  wire        axi_awvalid_i,
    input  wire        axi_wvalid_i,
    input  wire        axi_bready_i,
    input  wire        axi_arvalid_i,
    input  wire        axi_rready_i,
    output wire        axi_awready_o,
    output wire        axi_wready_o,
    output wire        axi_bvalid_o,
    output wire        axi_arready_o,
    output wire        axi_rvalid_o,
    input  wire [31:0] axi_awaddr_i,
    input  wire [31:0] axi_wdata_i,
    input  wire [31:0] axi_araddr_i,
    input  wire [3:0]  axi_wstrb_i,
    output wire [31:0] axi_rdata_o,
    output wire [63:0] result_o,
    
    // Burst transaction signals
    input  wire [7:0]  axi_awlen_i,
    input  wire [2:0]  axi_awsize_i,
    input  wire [1:0]  axi_awburst_i,
    input  wire        axi_wlast_i,
    input  wire [7:0]  axi_arlen_i,
    input  wire [2:0]  axi_arsize_i,
    input  wire [1:0]  axi_ar