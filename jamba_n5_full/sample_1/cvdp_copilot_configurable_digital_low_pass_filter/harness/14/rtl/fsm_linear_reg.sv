module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
)(
    input  clk,
    input  reset,
    input  start,
    input  x_in,
    input  w_in,
    input  b_in,
    output reg [DATA_WIDTH-1:0] result1,
    output reg [DATA_WIDTH:0] result2,
    output bit done
);
