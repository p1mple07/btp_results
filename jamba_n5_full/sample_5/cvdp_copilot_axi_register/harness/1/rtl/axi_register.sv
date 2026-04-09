module axi_register #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input clk_i,
    input rst_n_i,
    input [ADDR_WIDTH-1:0] awaddr_i,
    input awvalid_i,
    input [DATA_WIDTH-1:0] wdata_i,
    input wvalid_i,
    input [(DATA_WIDTH/8)-1:0] wstrb_i,
    input bready_i,
    input [ADDR_WIDTH-1:0] araddr_i,
    input arvalid_i,
    input rready_i,
    input done_i,
    output awready_o,
    output wready_o,
    output [1:0] bresp_o,
    output bvalid_o,
    output arready_o,
    output [DATA_WIDTH-1:0] rdata_o,
    output rvalid_o,
    output [1:0] rresp_o,
    output beat_o,
    output start_o,
    output writeback_o
);

// ... implement handshake, counters, registers, etc.

endmodule
