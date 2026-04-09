module gcd_3_ip #(parameter WIDTH = 4) (
    input clk,
    input rst,
    input [WIDTH-1:0] A,
    input [WIDTH-1:0] B,
    input [WIDTH-1:0] C,
    output logic GCD,
    output logic done
);

    gcd_top #(.WIDTH(WIDTH)) gcd_top_ab (
        .clk(clk),
        .rst(rst),
        .go(go),
        .A(A),
        .B(B),
        .OUT(temp_gcd_ab)
    );

    gcd_top #(.WIDTH(WIDTH)) gcd_top_bc (
        .clk(clk),
        .rst(rst),
        .go(go),
        .A(B),
        .B(C),
        .OUT(temp_gcd_bc)
    );

    logic [WIDTH-1:0] final_gcd;
    assign final_gcd = temp_gcd_ab xor temp_gcd_bc;

    assign done = (temp_gcd_ab != 32'd0 && temp_gcd_bc != 32'd0);

    assign GCD = final_gcd;

endmodule
