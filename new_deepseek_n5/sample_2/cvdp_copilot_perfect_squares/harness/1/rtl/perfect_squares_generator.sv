module perfect_squares_generator (
    input clock,
    input reset,
    output sqr_o
);

    reg integer count = 1;
    reg integer sqr_o_val;

    integer max_int = 32'hFFFFFFFF;

    always clocked (
        positive_edge #1 (.others)
    ) begin
        if (reset) begin
            count = 1;
        end else begin
            count = count + 1;
            sqr_o_val = (count-1) * count;
            if (sqr_o_val > max_int) begin
                sqr_o_val = max_int;
            end
            sqr_o = sqr_o_val;
        end
    end

    endmodule