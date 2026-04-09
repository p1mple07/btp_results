module fibonacci_series (
    input wire clk,
    input wire rst_n,
    output reg fib_out,
    output reg overflow_flag
);

    localparam INITIAL_REG_A = 32'd0;
    localparam INITIAL_REG_B = 32'd1;
    localparam OVERFLOW_THRESHOLD = 1 << 31;

    reg [31:0] regA, regB;
    reg next_fib;
    reg overflow_detected;

    always @(posedge clk) begin
        if (!rst_n) begin
            regA <= INITIAL_REG_A;
            regB <= INITIAL_REG_B;
            fib_out <= 0;
            overflow_flag <= 0;
        end else begin
            next_fib = regA + regB;
            overflow_detected = next_fib > OVERFLOW_THRESHOLD;

            if (overflow_detected) begin
                overflow_flag <= 1;
                regA <= 0;
                regB <= 1;
                fib_out <= 0;
            end else begin
                regA <= regB;
                regB <= next_fib;
                fib_out <= regB;
            end
        end
    end

endmodule
