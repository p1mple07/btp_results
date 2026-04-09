module perfect_squares_generator(
    input clock,
    input reset,
    output reg sqr_o[31:0]
);

    reg counter = 1;

    always positive edge #1 (clock) begin
        counter = counter + 1;
        sqr_o = counter * counter;
        if (sqr_o > 32'hFFFFFFFF)
            sqr_o = 32'hFFFFFFFF;
    end

    initial
        if (reset)
            counter = 1;
    end
endmodule