module wishbone_to_ahb_bridge #(
    parameter DATA_WIDTH = 32
)(
    input wire clk_i,
    input wire rst_i,
    input wire cyc_i,
    input wire stb_i,
    input wire [3:0] sel_i[3:0],
    input wire we_i,
    input wire addr_i[31:0],
    input wire [31:0] data_i[31:0],

    output reg hclk,
    output reg hreset_n,
    output wire hrdata[31:0],
    output wire hresp[1:0],
    output reg hready,

    output reg htrans[1:0],
    output reg hsize[2:0],
    output reg hburst[2:0],
    output reg hwrite,
    output reg haddr[31:0],
    output wire hwdata[31:0]
);

// ... implementation ...

endmodule
