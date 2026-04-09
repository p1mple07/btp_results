module fibonacci_series (
    input wire clk,
    input wire rst,
    output reg fib_out,
    output reg overflow_flag
);

    reg [31:0] regA, regB;
    reg overflow_detected;

    always @(posedge clk) begin
        if (rst) begin
            regA <= 0;
            regB <= 1;
            fib_out <= 0;
            overflow_flag <= 0;
        end else begin
            reg next_fib = regA + regB;
            overflow_detected = next_fib > 4294967295;
            regA <= regB;
            regB <= next_fib;
            fib_out <= regB;
            if (overflow_detected)
                overflow_flag <= 1;
        end
    end

endmodule
