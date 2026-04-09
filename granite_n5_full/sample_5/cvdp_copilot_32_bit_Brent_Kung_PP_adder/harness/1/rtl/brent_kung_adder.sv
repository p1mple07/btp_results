module brent_kung_adder(input logic signed [31:0] a, b, c, carry_in, carry_out;

   assign sum = a + b;
   assign carry_out = c;
endmodule