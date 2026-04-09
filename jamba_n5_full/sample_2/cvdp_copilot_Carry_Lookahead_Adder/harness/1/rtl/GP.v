module gp (input i_A, input i_B, input i_Cin, output reg o_generate, output reg o_propagate, output reg o_Cout);

always @(*) begin
  o_generate = i_A & i_B;
  o_propagate = i_A | i_B;
  o_Cout = i_Cin + (i_A ^ i_B) + (i_A & i_B & i_Cin);
end

endmodule
