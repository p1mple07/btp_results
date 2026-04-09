module perfect_squares_generator (
    input clk,
    input reset,
    output reg [31:0] sqr_o
);

    localparam first_square = 1;
    reg n;
    reg sqr;

    always @(posedge clk) begin
        if (!reset) begin
            n <= 0;
            sqr <= 1;
        end else begin
            if (reset) begin
                n <= 0;
                sqr <= 1;
            end else {
                n <= n + 1;
                sqr <= (n * n) + 1;
            }
        end
    end

endmodule
