module restoring_division #(
    parameter WIDTH = 6
)(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [WIDTH-1:0] dividend,
    input wire [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);
