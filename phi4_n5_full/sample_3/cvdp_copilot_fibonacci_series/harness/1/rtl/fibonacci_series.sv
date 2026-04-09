module fibonacci_series (
    input  logic clk,
    input  logic rst,
    output logic [31:0] fib_out,
    output logic        overflow_flag
);

    // Internal registers for Fibonacci sequence
    logic [31:0] RegA;
    logic [31:0] RegB;
    // Signal to indicate that an overflow was detected in the previous cycle
    logic overflow_detected;

    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset behavior: initialize sequence and clear flags
            RegA         <= 32'd0;
            RegB         <= 32'd1;
            fib_out      <= 32'd0;
            overflow_flag<= 1'b0;
            overflow_detected <= 1'b0;
        end else if (overflow_detected) begin
            // Overflow recovery: on the cycle following detection, reset the sequence and assert overflow_flag
            RegA         <= 32'd0;
            RegB         <= 32'd1;
            fib_out      <= 32'd0;
            overflow_flag<= 1'b1;
            overflow_detected <= 1'b0;
        end else begin
            // Normal operation: compute next Fibonacci number in 33-bit arithmetic to detect overflow
            logic [32:0] sum;
            sum = {1'b0, RegA} + {1'b0, RegB};

            if (sum[32] == 1'b1) begin
                // Overflow detected: propagate the last Fibonacci number and set flag for next cycle
                fib_out      <= RegB;
                overflow_detected <= 1'b1;
                // Do not update RegA and RegB this cycle
            end else begin
                // Normal update: shift registers and compute new Fibonacci number
                RegA <= RegB;
                RegB <= sum[31:0]; // Only lower 32 bits are valid
                fib_out <= RegB;
            end
        end
    end

endmodule