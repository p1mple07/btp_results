module gcd_top #(
    parameter WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire [WIDTH-1:0] A,
    input wire [WIDTH-1:0] B,
    input wire go,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

// ... instantiate controlpath and datapath ...

endmodule
