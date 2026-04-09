module wishbone_to_ahb_bridge #(
    parameter WORD_WIDTH = 32
)(
    input wire clk_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire [3:0] sel_i[3:0],
    input wire we_i,
    input wire addr_i[31:0],
    input wire data_i[31:0],

    output reg hclk,
    output wire hreset_n,
    output wire hrdata[31:0],
    output wire hresp[1:0],
    output wire hready,

    output reg data_o[31:0],
    output reg [31:0] ack_o,

    output reg htrans[1:0],
    output reg hsize[2:0],
    output reg hburst[2:0],
    output reg hwrite,
    output reg haddr[31:0],
    output reg hwdata[31:0]
);
