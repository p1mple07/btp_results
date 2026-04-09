module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input logic [WIDTH-1:0] i_A,
    input logic [WIDTH-1:0] i_B,
    input logic i_enable,
    input logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    always_comb begin
        if (i_enable == 1'b1) begin
            if (i_mode == 1'b1) begin
                // Signed mode
                if (i_A[WIDTH-1] == 1'b1 && i_B[WIDTH-1] == 1'b0) begin
                    o_greater = 1'b1;
                    o_less = 1'b0;
                    o_equal = 1'b0;
                end else if (i_A[WIDTH-1] == 1'b0 && i_B[WIDTH-1] == 1'b1) begin
                    o_greater = 1'b0;
                    o_less = 1'b1;
                    o_equal = 1'b0;
                } else begin
                    o_greater = ((i_A > i_B)? 1'b1 : 1'b0);
                    o_less = ((i_A < i_B)? 1'b1 : 1'b0);
                    o_equal = ((i_A == i_B)? 1'b1 : 1'b0);
                end
            } else begin
                // Magnitude mode
                o_greater = ((i_A > i_B)? 1'b1 : 1'b0);
                o_less = ((i_A < i_B)? 1'b1 : 1'b0);
                o_equal = ((i_A == i_B)? 1'b1 : 1'b0);
            end
        end else begin
            o_greater = 1'b0;
            o_less = 1'b0;
            o_equal = 1'b0;
        end
    end

endmodule