module Generate_Propagate (
    input i_A,
    input i_B,
    input i_Cin,
    output reg o_generate,
    output reg o_propagate,
    output o_Cout
);

    // Define the outputs based on the truth table
    always @(i_A, i_B, i_Cin) begin
        case ({i_A, i_B, i_Cin})
            000: o_generate = 0; o_propagate = 0; o_Cout = 0;
            001: o_generate = 0; o_propagate = 0; o_Cout = 0;
            010: o_generate = 0; o_propagate = 1; o_Cout = 0;
            011: o_generate = 0; o_propagate = 1; o_Cout = 1;
            100: o_generate = 0; o_propagate = 1; o_Cout = 0;
            101: o_generate = 0; o_propagate = 1; o_Cout = 1;
            110: o_generate = 1; o_propagate = 1; o_Cout = 1;
            111: o_generate = 1; o_propagate = 1; o_Cout = 1;
        endcase
    end

    // Calculate the carry-out based on generate, propagate, and carry-in
    always @(posedge i_A, posedge i_B, posedge i_Cin) begin
        if (i_Cin) begin
            o_Cout = o_generate | (o_propagate & i_Cin);
        end else begin
            o_Cout = o_generate | o_propagate;
        end
    end

endmodule
