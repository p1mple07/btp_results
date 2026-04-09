module rtl/GP (
    input bit i_A,
    input bit i_B,
    input bit i_Cin,
    output bit o_generate,
    output bit o_propagate,
    output bit o_Cout
);
    o_generate = i_A & i_B;
    o_propagate = i_A | i_B;
    o_Cout = o_generate | (o_propagate & i_Cin);
endmodule