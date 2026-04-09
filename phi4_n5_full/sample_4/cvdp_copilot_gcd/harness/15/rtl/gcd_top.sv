
gcd_3_ip #(.WIDTH(2*WIDTH)) gcd_inst (
   .clk(clk),
   .rst(rst),
   .A(AB_reg),
   .B(BC_reg),
   .C(CA_reg),
   .go(go),
   .OUT(gcd_val), // note: gcd_val is 2*WIDTH bits
   .done(gcd_done)
);
