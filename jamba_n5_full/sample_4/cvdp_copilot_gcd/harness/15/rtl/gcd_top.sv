module lcm_3_ip #(
    parameter WIDTH = 4
) (
    input         clk,
    input         rst,
    input         [WIDTH-1:0] A,
    input         [WIDTH-1:0] B,
    input         [WIDTH-1:0] C,
    input         go,
    output logic [3*WIDTH-1:0] OUT,
    output logic  done
);

    logic [WIDTH-1:0] prod1, prod2, prod3;
    logic [WIDTH-1:0] gcd_val;

    gcd_top gcd_3_ip_inst (
        .WIDTH(WIDTH),
        .A(prod1),
        .B(prod2),
        .C(prod3),
        .rst(rst),
        .go(go),
        .OUT(gcd_3_ip_output),
        .done(done_gcd)
    );

    assign gcd_val = gcd_3_ip_inst.OUT;

    assign OUT = (A * B * C) / gcd_val;

endmodule
