module gcd_top #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input go,
    input equal,
    input greater_than,
    input A_in,
    input B_in,
    output reg out,
    output done
);
