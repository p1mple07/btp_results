module generate_propagate (
    input bit i_A, i_B,
    input bit i_Cin,
    output bit o_generate, o_propagate,
    output bit o_Cout
);

    assign o_generate = i_A & i_B;
    assign o_propagate = i_A | i_B;
    assign o_Cout = (i_A & i_B) | (i_A | i_B) & i_Cin;

endmodule