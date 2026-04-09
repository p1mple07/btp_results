
module ffifo_async #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 64
)(
    input w_clk,
    input w_rst,
    input w_inc,
    input w_data,
    input r_clk,
    input r_rst,
    input r_inc,

    output reg w_full,
    output reg r_empty,
    output reg [DATA_WIDTH-1:0] r_data,

    output reg [DEPTH*2-1:0] w_ptr,
    output reg [DEPTH*2-1:0] r_ptr
);
