module perfect_squares_generator (
    input wire clk,
    input wire reset,
    output reg [31:0] sqr_o
);

reg [31:0] base;
reg [31:0] sqr;

initial begin
    base = 1;
    sqr = 1;
end

always_ff @(posedge clk) begin
    if (!reset) begin
        base <= 1;
        sqr <= 1;
    end else begin
        sqr = base * base;
        if (sqr > 32'hFFFFFFFF) sqr <= 32'hFFFFFFFF;
        base = base + 1;
    end
end

endmodule
