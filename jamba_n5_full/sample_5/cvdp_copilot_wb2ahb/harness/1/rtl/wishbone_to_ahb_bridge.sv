module wishbone_to_ahb_bridge (
    input clk_i,
    input rst_i,
    input cyc_i,
    input stb_i,
    input sel_i[3:0],
    input we_i,
    input addr_i[31:0],
    input data_i[31:0],

    output reg hclk,
    output hreset_n,
    output hready,
    output hrdata[31:0],
    output hresp[1:0],
    output htrans[1:0],
    output hsize[2:0],
    output hburst[2:0],
    output hwrite,
    output haddr[31:0],
    output hwdata[31:0],

    output data_o[31:0],
    output ack_o
);

// ... implement code

endmodule
