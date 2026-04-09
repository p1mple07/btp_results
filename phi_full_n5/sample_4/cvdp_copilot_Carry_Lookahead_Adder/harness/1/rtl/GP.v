module Generate_Propagate (
    input i_A,
    input i_B,
    input i_Cin,
    output o_generate,
    output o_propagate,
    output reg o_Cout
);

    assign o_generate = (i_A & i_B);
    assign o_propagate = (i_A | i_B);
    always @(*) begin
        case ({i_A, i_B, i_Cin})
            000: o_Cout = 0;
            001: o_Cout = 1;
            010: o_Cout = 0;
            011: o_Cout = 1;
            100: o_Cout = 0;
            101: o_Cout = 1;
            110: o_Cout = 1;
            111: o_Cout = 1;
            default: o_Cout = 0;
        endcase
    end

endmodule
