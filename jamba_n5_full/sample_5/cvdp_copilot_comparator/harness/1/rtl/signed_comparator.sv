module signed_unsigned_comparator #(
    parameter WIDTH = 5
)(
    input wire i_enable,
    input wire i_mode,
    input wire i_A,
    input wire i_B
);

    // internal variables
    logic [WIDTH-1:0] a, b;
    logic [WIDTH-1:0] mask;

    always @(*) begin
        if (i_enable) begin
            // convert to signed if needed
            if (i_mode == 1) begin
                // signed mode
                // compare as signed
                a = i_A;
                b = i_B;
                if (a > b) o_greater = 1;
                else if (a < b) o_less = 1;
                else o_equal = 1;
            end else begin
                // magnitude mode: treat as unsigned
                a = i_A;
                b = i_B;
                if (a > b) o_greater = 1;
                else if (a < b) o_less = 1;
                else o_equal = 1;
            end
        end else
            o_greater = o_less = o_equal = 0;
    end

endmodule
