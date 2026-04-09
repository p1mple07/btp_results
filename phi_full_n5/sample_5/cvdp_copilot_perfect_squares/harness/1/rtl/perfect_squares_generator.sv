module perfect_squares_generator(
    input clk,
    input reset,
    output reg [31:0] sqr_o
);

    reg [31:0] base_number = 1;
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            base_number <= 1;
            sqr_o <= 1;
        end else begin
            base_number <= base_number + 1;
            sqr_o <= {base_number, base_number};
        end
    end

    // Overflow protection
    always @(sqr_o) begin
        if (sqr_o > 32'hFFFFFFFF) begin
            sqr_o <= 32'hFFFFFFFF;
        end
    end

endmodule
