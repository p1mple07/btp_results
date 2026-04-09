
     gcd_inst (
       .clk   (clk),
       .rst   (rst),
       .A     (A_int),
       .B     (B_int),
       .C     (C_int),
       .go    (go),
       .OUT   (gcd_result), // Correctly connected
       .done  (gcd_done)
     );
     