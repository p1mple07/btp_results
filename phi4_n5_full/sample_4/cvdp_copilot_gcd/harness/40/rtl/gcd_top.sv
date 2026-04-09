
gcd_top
#( .WIDTH(WIDTH)
) gcd_ABC_inst (
   .clk           (clk),
   .rst           (rst),
   .A             (gcd_ab),
   .B             (gcd_bc),
   .go            (go_abc),
   .OUT           (OUT),
   .done          (done)
);
