module rtl.GP (
    input i_A, i_B, i_Cin,
    output o_generate, o_propagate, o_Cout
);
    o_generate = i_A & i_B;
    o_propagate = i_A | i_B;
    o_Cout = o_generate | (o_propagate & i_Cin);
endmodule