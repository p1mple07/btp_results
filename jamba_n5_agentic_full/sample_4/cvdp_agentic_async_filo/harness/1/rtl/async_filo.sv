module async_filo #(
    parameter DATA_WIDTH = 16,
    parameter DEPTH = 8
)(
    input  logic w_clk,
    input  logic r_clk,
    input  logic w_rst,
    input  logic r_rst,
    input  logic push,
    input  logic pop,
    input  logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic r_empty,
    output logic w_full
);
