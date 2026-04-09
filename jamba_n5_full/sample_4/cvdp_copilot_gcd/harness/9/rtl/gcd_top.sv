module gcd_3_ip #(parameter WIDTH=4) (
   input         clk,
   input         rst,
   input         A, B, C,
   output        OUT
);

// First instance: compute GCD of A and B
gcd_top_inst1 u1 (
   .clk(clk),
   .rst(rst),
   .A(A), .B(B),
   .go(go),
   .equal(equal1),
   .greater_than(greater1),
   .OUTPUT(gcd1_out)
);

// Second instance: compute GCD of B and C
gcd_top_inst2 u2 (
   .clk(clk),
   .rst(rst),
   .A(B), .B(C),
   .go(go),
   .equal(equal2),
   .greater_than(greater2),
   .OUTPUT(gcd2_out)
);

// Third instance: compute GCD of gcd1_out and gcd2_out
gcd_top_final u3 (
   .clk(clk),
   .rst(rst),
   .A(gcd1_out), .B(gcd2_out),
   .go(go),
   .equal(equal3),
   .greater_than(greater3),
   .OUTPUT(final_output)
);

endmodule
