module signed_unsigned_comparator #(
    parameter WIDTH = 5
) (
    input wire i_enable,
    input wire i_A,
    input wire i_B,
    input wire i_mode
);

    assign o_greater = i_enable && (i_A > i_B);
    assign o_less = i_enable && (i_A < i_B);
    assign o_equal = i_enable && (i_A == i_B);

endmodule
