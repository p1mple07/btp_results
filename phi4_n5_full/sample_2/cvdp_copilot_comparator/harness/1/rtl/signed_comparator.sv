module signed_unsigned_comparator #(parameter WIDTH = 5)(
    input  logic [WIDTH-1:0] i_A,
    input  logic [WIDTH-1:0] i_B,
    input  logic             i_enable,
    input  logic             i_mode,    // High = signed mode, Low = magnitude mode
    output logic             o_greater,
    output logic             o_less,
    output logic             o_equal
);

    // Intermediate signals for magnitude mode (absolute value computation)
    logic [WIDTH-1:0] abs_A;
    logic [WIDTH-1:0] abs_B;

    always_comb begin
        // Default: all outputs low
        o_greater = 1'b0;
        o_less    = 1'b0;
        o_equal   = 1'b0;

        if (!i_enable) begin
            // When disabled, all outputs remain inactive.
        end else begin
            if (i_mode) begin
                // Signed Mode: Compare as signed integers.
                if (i_A > i_B)
                    o_greater = 1'b1;
                else if (i_A < i_B)
                    o_less    = 1'b1;
                else
                    o_equal   = 1'b1;
            end else begin
                // Magnitude Mode: Compute the absolute values of i_A and i_B.
                // For a negative number, absolute value = ~number + 1.
                abs_A = (i_A[WIDTH-1]) ? (~i_A + 1) : i_A;
                abs_B = (i_B[WIDTH-1]) ? (~i_B + 1) : i_B;
                
                if (abs_A > abs_B)
                    o_greater = 1'b1;
                else if (abs_A < abs_B)
                    o_less    = 1'b1;
                else
                    o_equal   = 1'b1;
            end
        end
    end

endmodule