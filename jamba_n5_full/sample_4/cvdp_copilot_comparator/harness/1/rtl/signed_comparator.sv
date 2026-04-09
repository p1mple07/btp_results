module signed_unsigned_comparator #(
    parameter WIDTH = 5
)(
    input wire i_enable,
    input wire i_mode,
    input wire i_A,
    input wire i_B
);

    assign o_greater = 1'b0;
    assign o_less = 1'b0;
    assign o_equal = 1'b0;

    always @(*) sensitive to (i_enable, i_mode, i_A, i_B) begin
        if (!i_enable) begin
            o_greater <= 1'b0;
            o_less <= 1'b0;
            o_equal <= 1'b0;
            return;
        end

        logic [WIDTH-1:0] a, b;
        a = i_A;
        b = i_B;

        if (i_mode == 1) // Signed mode
        begin
            if (a[WIDTH-1] > b[WIDTH-1]) o_greater = 1'b1;
            else if (a[WIDTH-1] < b[WIDTH-1]) o_less = 1'b1;
            else if (a[WIDTH-1] == b[WIDTH-1]) o_equal = 1'b1;
        end
        else // Magnitude mode
        begin
            if (a < b) o_less = 1'b1;
            else if (a > b) o_greater = 1'b1;
            else if (a == b) o_equal = 1'b1;
        end
    end

endmodule
