module signed_unsigned_comparator #(
  parameter WIDTH = 5
)(
  input  logic [WIDTH-1:0] i_A,
  input  logic [WIDTH-1:0] i_B,
  input  logic              i_enable,
  input  logic              i_mode,  // High = signed mode, Low = magnitude (unsigned) mode
  output logic              o_greater,
  output logic              o_less,
  output logic              o_equal
);

  // When i_enable is low, all outputs are inactive.
  // When enabled, perform the comparison based on the selected mode.

  // Equality check: same for both signed and unsigned.
  assign o_equal = i_enable ? (i_A == i_B) : 1'b0;

  // Greater-than and less-than comparisons.
  // For signed mode, use $signed() to cast the inputs; for magnitude mode, use default unsigned comparison.
  assign o_greater = i_enable ? ((i_mode) ? ($signed(i_A) > $signed(i_B)) : (i_A > i_B)) : 1'b0;
  assign o_less    = i_enable ? ((i_mode) ? ($signed(i_A) < $signed(i_B)) : (i_A < i_B)) : 1'b0;

endmodule