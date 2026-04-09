module GP (
    input  wire i_A,
    input  wire i_B,
    input  wire i_Cin,
    output wire o_generate,
    output wire o_propagate,
    output wire o_Cout
);

    // Generate signal: true if both inputs are 1
    assign o_generate = i_A & i_B;

    // Propagate signal: true if either input is 1
    assign o_propagate = i_A | i_B;

    // Carry-out signal: computed using generate, propagate, and carry-in
    assign o_Cout = o_generate | (o_propagate & i_Cin);

endmodule