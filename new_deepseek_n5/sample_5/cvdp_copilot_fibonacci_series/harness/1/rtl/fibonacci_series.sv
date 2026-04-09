module fibonacci_series(
    input clock,
    input rst,
    output fib_out,
    output overflow_flag
);

    // Registers for Fibonacci sequence generation
    register RegA, RegB;
    register next_fib;
    register overflow_detected;

    // Initialize registers
    initial begin
        RegA = 0;
        RegB = 1;
        fib_out = 0;
        overflow_flag = 0;
    end

    // Compute next Fibonacci number
    next_fib = RegA + RegB;

    // Check for overflow
    overflow_detected = (next_fib >= 2**32);

    // Update registers and outputs
    fib_out = RegB;
    if (overflow_detected) begin
        RegA = 0;
        RegB = 1;
    else begin
        RegA = RegB;
        RegB = next_fib;
    end

    // Reset if necessary
    if (rst) begin
        RegA = 0;
        RegB = 1;
        fib_out = 0;
        overflow_flag = 0;
    end

    // Output the current Fibonacci number
    fib_out = RegB;

endmodule