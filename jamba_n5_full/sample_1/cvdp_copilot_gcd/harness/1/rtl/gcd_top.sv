module gcd_top #(parameter WIDTH=4) (
    input clk,
    input rst,
    input go,
    input equal,
    input greater_than,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    output reg [WIDTH-1:0] OUT,
    output reg done
);

    // instantiate modules
    gcd_controlpath uut (
        .clk(clk),
        .rst(rst),
        .go(go),
        .equal(equal),
        .greater_than(greater_than),
        .controlpath_state(uout_state)
    );

    gcd_datapath udp (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .OUT(OUT),
        .done(done)
    );

endmodule
