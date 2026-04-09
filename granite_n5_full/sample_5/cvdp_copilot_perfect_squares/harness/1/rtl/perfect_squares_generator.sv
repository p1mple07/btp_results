module perfect_squares_generator(
    input wire clk,
    input wire reset,
    output reg [31:0] sqr_o
);

    reg [31:0] base; // Base number for calculating squares
    reg [31:0] sqr; // Current square being calculated

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            base <= 1;
            sqr <= 1;
        end else begin
            sqr <= sqr + base;
            if (sqr > 32'hFFFFFFFF) begin
                sqr <= 32'hFFFFFFFF;
            end
        end
    end

    assign sqr_o = sqr;

endmodule