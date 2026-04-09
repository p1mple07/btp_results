module GP (
    input  i_A,
    input  i_B,
    input  i_Cin,
    output o_generate,
    output o_propagate,
    output o_Cout
);

    // Generate is true if both inputs are 1.
    assign o_generate = i_A & i_B;

    // Propagate is true if either input is 1.
    assign o_propagate = i_A | i_B;

    // Carry-out is generated if generate is true, or if propagate is true and carry-in is high.
    assign o_Cout = o_generate | (o_propagate & i_Cin);

endmodule