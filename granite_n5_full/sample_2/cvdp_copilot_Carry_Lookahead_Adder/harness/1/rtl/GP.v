module GP(
  output logic o_generate, 
  output logic o_propagate,
  output logic o_Cout,
  input logic i_A, 
  input logic i_B, 
  input logic i_Cin
);

  assign o_generate = i_A & i_B; // Carry generation occurs when A and B are both 1s
  assign o_propagate = i_A | i_B; // Carry propagation occurs when A or B is 1
  assign o_Cout = o_generate ^ i_Cin; // Compute the carry-out based on the generate, propagate, and carry-in signals

endmodule