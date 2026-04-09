module generate_propagate(
    input wire i_A,
    input wire i_B,
    input wire i_Cin,
    output reg o_generate,
    output reg o_propagate,
    output reg o_Cout
);

    always @(*) begin
        o_generate = i_A & i_B;
        o_propagate = i_A | i_B;
        o_Cout = i_Cin + o_propagate & o_generate;
    end

endmodule
