// File: rtl/GP.v
// Generate/Propagate module for Carry Lookahead Adder

module GP (
    input  wire i_A,
    input  wire i_B,
    input  wire i_Cin,
    output wire o_generate,
    output wire o_propagate,
    output wire o_Cout
);

    // Generate and Propagate signals
    assign o_generate = i_A & i_B;
    assign o_propagate = i_A | i_B;

    // Carry-out computation
    assign o_Cout = o_generate | (o_propagate & i_Cin);

endmodule
