module perfect_squares_generator (
    input wire clk,
    input wire reset,
    output reg [31:0] sqr_o
);

    reg base;
    reg sqr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            base = 1;
            sqr = 1;
        end else begin
            sqr = base * base;
            if (sqr > 32'hFFFFFFFF) sqr <= 32'hFFFFFFFF;
        end
    end

endmodule
