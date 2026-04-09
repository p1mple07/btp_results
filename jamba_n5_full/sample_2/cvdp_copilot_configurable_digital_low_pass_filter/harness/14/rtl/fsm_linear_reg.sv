module fsm_linear_reg #(parameter DATA_WIDTH = 16) (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [DATA_WIDTH-1:0] x_in,
    input wire [DATA_WIDTH-1:0] w_in,
    input wire [DATA_WIDTH-1:0] b_in,
    output reg [2*DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH+1:0] result2,
    output wire done
);
