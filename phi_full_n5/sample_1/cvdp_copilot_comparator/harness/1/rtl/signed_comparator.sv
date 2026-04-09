module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input [WIDTH-1:0] i_A,
    input [WIDTH-1:0] i_B,
    input i_enable,
    input i_mode,
    output reg o_greater,
    output reg o_less,
    output reg o_equal
);

    // Combinational logic for comparison
    always_comb begin
        if (i_enable) begin
            // Signed mode comparison
            if (i_mode) begin
                o_greater = ((i_A[WIDTH-1] == 1'b0) && i_A > i_B) || ((i_A[WIDTH-1] == 1'b1) && i_A[WIDTH-2:0] > i_B[WIDTH-2:0]);
                o_less = ((i_A[WIDTH-1] == 1'b0) && i_A < i_B) || ((i_A[WIDTH-1] == 1'b1) && i_A[WIDTH-2:0] < i_B[WIDTH-2:0]);
                o_equal = ((i_A[WIDTH-1] == 1'b0) && i_A == i_B) || ((i_A[WIDTH-1] == 1'b1) && i_A[WIDTH-2:0] == i_B[WIDTH-2:0]);
            end
            // Magnitude mode comparison
            else begin
                o_greater = i_A > i_B;
                o_less = i_A < i_B;
                o_equal = i_A == i_B;
            end
        end
        // Disable outputs when i_enable is low
        else begin
            o_greater = 1'b0;
            o_less = 1'b0;
            o_equal = 1'b0;
        end
    end

endmodule
