module perfect_squares_generator(
    input clk,
    input reset,
    output reg [31:0] sqr_o
);

    reg [31:0] counter;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 1;
            sqr_o <= 1;
        end else begin
            counter <= counter + 1;
            sqr_o <= counter * counter;
            if (sqr_o > 32'hFFFFFFFF) begin
                sqr_o <= 32'hFFFFFFFF;
            end
        end
    end

endmodule
