module axi_register #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    output wire awready_o,
    input [DATA_WIDTH-1:0] wdata_i,
    output wire wvalid_i,
    input [(DATA_WIDTH/8)-1:0] wstrb_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    output wire arvalid_i,
    output rready_o,
    output [DATA_WIDTH-1:0] rdata_o,
    output rvalid_o,
    output [1:0] bresp_o,
    output bvalid_o,
    output arready_o,
    input done_i,
    input start_o,
    output writeback_o
);

// ... implementation ...
