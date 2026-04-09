module Generate_Propagate (
    input i_A,
    input i_B,
    input i_Cin,
    output o_generate,
    output o_propagate,
    output o_Cout
);

    // Define the outputs
    assign o_generate = (i_A && i_B);
    assign o_propagate = (i_A || i_B);

    // Compute the carry-out using the generate, propagate, and carry-in signals
    assign o_Cout = (i_Cin && o_generate) || (i_Cin && o_propagate);

endmodule
