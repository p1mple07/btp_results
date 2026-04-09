module fibonacci_series(
    input         clk,
    input         rst,
    output reg     fib_out,
    output reg    overflow_flag
);

    reg           regA, regB;
    reg           overflow_flag_reg;

    always @(posedge clk) begin
        if (rst) begin
            regA <= 0;
            regB <= 1;
            fib_out <= 0;
            overflow_flag <= 0;
        end else begin
            regA <= regB;
            regB <= fib_out;
            assign next_fib = regA + regB;
            if (next_fib > 32'd1073741823) begin
                overflow_flag <= 1;
                fib_out <= regB;
                // Reset registers to initial state
                regA <= 0;
                regB <= 1;
            } else begin
                // Regular update
                regA <= regB;
                regB <= next_fib;
            end
        end
    end

endmodule
