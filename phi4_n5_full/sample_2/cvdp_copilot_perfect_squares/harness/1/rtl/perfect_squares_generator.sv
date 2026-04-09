module perfect_squares_generator(
    input  logic clk,
    input  logic reset,
    output logic [31:0] sqr_o
);

    // Internal register to hold the base number for square calculation
    logic [31:0] base;
    // Internal register to hold the computed square value
    logic [31:0] sqr;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // On reset, initialize the base to 1 so that the first square is 1
            base <= 1;
            sqr  <= 1;  // 1 * 1 = 1
        end else begin
            // Increment the base number for the next square calculation
            base <= base + 1;
            // Check for overflow: if base exceeds 65535 (0xFFFF), then the square would overflow,
            // so we saturate the output to the maximum 32-bit value.
            if (base > 32'hFFFF)
                sqr <= 32'hFFFFFFFF;
            else
                sqr <= base * base;
        end
    end

    // Drive the output with the computed square
    assign sqr_o = sqr;

endmodule