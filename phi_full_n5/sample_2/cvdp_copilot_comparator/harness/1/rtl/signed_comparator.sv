module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input [WIDTH-1:0] i_A,
    input [WIDTH-1:0] i_B,
    input i_enable,
    input i_mode,
    output reg o_greater,
    output reg o_less,
    output reg o_equal
);

    always_comb begin
        if (!i_enable) begin
            o_greater <= 1'b0;
            o_less <= 1'b0;
            o_equal <= 1'b0;
        end else begin
            wire signed_A = i_mode ? i_A : {WIDTH{1'b0}, i_A};
            wire signed_B = i_mode ? i_B : {WIDTH{1'b0}, i_B};

            if (signed_A > signed_B) begin
                o_greater <= 1'b1;
                o_less <= 1'b0;
                o_equal <= 1'b0;
            end else if (signed_A < signed_B) begin
                o_greater <= 1'b0;
                o_less <= 1'b1;
                o_equal <= 1'b0;
            end else begin
                o_greater <= 1'b0;
                o_less <= 1'b0;
                o_equal <= 1'b1;
            end
        end
    end
endmodule
