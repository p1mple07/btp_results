
module wishbone_to_ahb_bridge #(
    parameter DATA_WIDTH = 32 // default 32-bit, but we can set in parameters?
) (
    input wire clk_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire [3:0] sel_i[3:0],
    input wire we_i,
    input wire [31:0] addr_i,
    input wire [31:0] data_i,

    output wire hclk,
    output wire hreset_n,
    output wire hrdata[31:0],
    output wire hresp[1:0],
    output wire hready,

    output wire data_o[31:0],
    output wire ack_o,

    output wire htrans[1:0],
    output wire hsize[2:0],
    output wire hburst[2:0],
    output wire hwrite,
    output wire haddr[31:0],
    output wire hwdata[31:0]
);
