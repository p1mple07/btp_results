module perfect_squares_generator (
    input clock,
    input reset,
    output sqr_o
);

    wire sqr_o [31:0];

    // State variables
    reg current_num = 0;
    reg unsigned [63:0] square; // 64-bit to hold the square
    reg unsigned [31:0] sqr_reg;

    always positive edge clock begin
        if (reset) begin
            current_num = 1;
            square = 1 * 1;
            sqr_reg = square;
        end else
            current_num = current_num + 1;
            square = current_num * current_num;
            if (square > 0xFFFFFFFF) begin
                sqr_o = 0xFFFFFFFF;
            else
                sqr_o = sqr_reg;
            end
        end
    end

endmodule