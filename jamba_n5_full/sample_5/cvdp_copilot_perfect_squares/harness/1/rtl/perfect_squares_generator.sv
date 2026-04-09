module perfect_squares_generator (
    input logic clk,
    input logic reset,
    output logic [31:0] sqr_o
);

    localparam MAX_VAL = 32'hFFFFFFFF;
    reg [31:0] n;
    reg [31:0] sqr_val;
    reg remember_reset;

    always @(posedge clk) begin
        remember_reset = ~reset;
        if (remember_reset) begin
            n <= 0;
            sqr_val <= 0;
        end else begin
            if (n == 0) begin
                n <= 1;
                sqr_val = 1;
            end else begin
                n <= n + 1;
                sqr_val = sqr_val + (n * n);
                if (sqr_val > MAX_VAL) sqr_val <= MAX_VAL;
            end
        end
    end

    assign sqr_o = sqr_val;

endmodule
