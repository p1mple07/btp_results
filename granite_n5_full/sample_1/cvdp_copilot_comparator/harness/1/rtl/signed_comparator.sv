module signed_unsigned_comparator #(parameter WIDTH = 5) (
  input wire [WIDTH-1:0] i_A,
  input wire [WIDTH-1:0] i_B,
  input wire i_enable,
  input wire i_mode,
  output wire o_greater,
  output wire o_less,
  output wire o_equal
);

  assign o_greater = (i_enable && ((i_A > i_B) || (i_A == i_B)))? 1'b1 : 1'b0;
  assign o_less = (i_enable && (i_A < i_B))? 1'b1 : 1'b0;
  assign o_equal = (i_enable && (i_A == i_B))? 1'b1 : 1'b0;

endmodule