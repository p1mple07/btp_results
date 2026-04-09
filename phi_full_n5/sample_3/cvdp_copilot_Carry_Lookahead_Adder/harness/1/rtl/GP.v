module GP (
    input i_A,
    input i_B,
    input i_Cin,
    output reg o_generate,
    output reg o_propagate,
    output reg o_Cout
);

    // Generate and Propagate outputs
    assign o_generate = i_A & i_B;
    assign o_propagate = i_A | i_B;

    // Carry-out computation
    always @ (i_A, i_B, i_Cin) begin
        if (i_A && i_B) begin
            o_Cout = i_Cin | o_generate;
        end else if (i_A || i_B) begin
            o_Cout = i_Cin | o_propagate;
        end else begin
            o_Cout = i_Cin;
        end
    end

endmodule
