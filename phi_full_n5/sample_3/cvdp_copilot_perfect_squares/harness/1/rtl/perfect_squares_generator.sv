module perfect_squares_generator(
    input clk,
    input reset,
    output reg [31:0] sqr_o
);
    reg [31:0] base_num;

    initial begin
        base_num = 1;
        sqr_o = 1;
    end

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            base_num <= 1;
            sqr_o <= 1;
        end else begin
            base_num <= base_num + 1;
            sqr_o <= base_num * base_num;
        end
    end

    // Overflow protection
    always @(sqr_o) begin
        if (sqr_o > 32'hFFFFFFFF) begin
            sqr_o <= 32'hFFFFFFFF;
        end
    end

endmodule
