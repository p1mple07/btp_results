module GP (
    input wire i_A,
    input wire i_B,
    input wire i_Cin,
    output wire o_generate,
    output wire o_propagate,
    output wire o_Cout
);

    // Generate: true if both i_A and i_B are 1.
    assign o_generate = i_A & i_B;

    // Propagate: true if either i_A or i_B is 1.
    assign o_propagate = i_A | i_B;

    // Carry-out: if generate is true, or if propagate is true and carry-in is true.
    assign o_Cout = o_generate | (o_propagate & i_Cin);

endmodule