module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input  logic [WIDTH-1:0] i_A,
    input  logic [WIDTH-1:0] i_B,
    input  logic             i_enable,
    input  logic             i_mode,
    output logic             o_greater,
    output logic             o_less,
    output logic             o_equal
);

    // Local wires for signed interpretation in signed mode
    logic signed [WIDTH-1:0] a_signed;
    logic signed [WIDTH-1:0] b_signed;

    assign a_signed = $signed(i_A);
    assign b_signed = $signed(i_B);

    // Purely combinational logic
    always_comb begin
        // Default: outputs inactive
        o_greater = 1'b0;
        o_less    = 1'b0;
        o_equal   = 1'b0;

        if (i_enable) begin
            if (i_mode) begin
                // Signed mode: compare as signed numbers
                if (a_signed > b_signed)
                    o_greater = 1'b1;
                else if (a_signed < b_signed)
                    o_less    = 1'b1;
                else
                    o_equal   = 1'b1;
            end else begin
                // Magnitude mode: compare as unsigned numbers
                if (i_A > i_B)
                    o_greater = 1'b1;
                else if (i_A < i_B)
                    o_less    = 1'b1;
                else
                    o_equal   = 1'b1;
            end
        end
    end

endmodule