module perfect_squares_generator (
    input        clk,
    input        reset,
    output reg [31:0] sqr_o
);

reg [6:0] n;    // counter for n^2
reg [31:0] current_sqr;

initial begin
    reset = 1;
    n = 1;
    current_sqr = 1;
end

always @(posedge clk or posedge reset) begin
    if (~reset) begin
        n <= 1;
        current_sqr <= 1;
    end else if (clk.high()) begin
        if (n == 1) begin
            n <= 2;
            current_sqr = n * n;
        end else begin
            n <= n + 1;
            current_sqr = n * n;
        end
    end
end

assign sqr_o = current_sqr & ~(32'hFFFFFFFF);

endmodule
