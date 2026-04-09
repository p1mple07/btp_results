
module sorting_engine #(
    parameter N = 8,
    parameter WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [N*WIDTH-1:0] in_data,
    output reg done,
    output reg [N*WIDTH-1:0] out_data
);
