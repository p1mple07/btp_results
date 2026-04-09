module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input logic [WIDTH-1:0] i_A,
    input logic [WIDTH-1:0] i_B,
    input logic i_enable,
    input logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    // Outputs are low by default
    assign o_greater = 1'b0;
    assign o_less = 1'b0;
    assign o_equal = 1'b0;

    // When enabled, perform the comparison
    always_comb begin
        if (i_enable) begin
            // Determine if comparison is signed or magnitude
            if (i_mode) begin
                // Signed mode: compare with sign consideration
                case (i_A[WIDTH-1])
                    1'b1: begin
                        if (i_A > i_B) o_greater = 1'b1;
                        else if (i_A < i_B) o_less = 1'b1;
                        else o_equal = 1'b1;
                    end
                    1'b0: begin
                        // Negative numbers are treated as greater than positive numbers
                        if (i_A[WIDTH-1] == 1'b0 && i_A > i_B) o_greater = 1'b1;
                        else if (i_A[WIDTH-1] == 1'b0 && i_A < i_B) o_less = 1'b1;
                        else if (i_A[WIDTH-1] == 1'b1 && i_A < i_B) o_greater = 1'b1;
                        else o_equal = 1'b1;
                    end
                end
            end else begin
                // Magnitude mode: unsigned comparison
                if (i_A > i_B) o_greater = 1'b1;
                else if (i_A < i_B) o_less = 1'b1;
                else o_equal = 1'b1;
            end
        end
    end

endmodule
