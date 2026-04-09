module fibonacci_series (
    input wire clk,
    input wire rst,
    output reg fib_out,
    output reg overflow_flag
);

    reg [31:0] regA, regB;
    reg overflow_detected;
    reg next_fib;

    initial begin
        if (rst) begin
            regA <= 0;
            regB <= 1;
            fib_out <= 0;
            overflow_flag <= 0;
        end else begin
            // On first clock, we generate the first Fibonacci number.
            next_fib = regA + regB;
            overflow_detected = (next_fib[31] == 1);
            if (overflow_detected) begin
                overflow_flag <= 1;
            end else begin
                overflow_flag <= 0;
            end
            // Update registers
            regA <= regB;
            regB <= next_fib;
            fib_out <= regB;
        end
    end

always @(posedge clk) begin
    if (!rst) begin
        // Reset on negative edge (or positive? The spec says "positive edge of the clock" for operation, but reset is active-high and likely also positive).
        // However, we need to follow the reset behavior. Typically, reset is applied on rising edge.
        // But the spec says "rst=1 resets the sequence to F(0)=0 and F(1)=1". It doesn't specify positive or negative. Usually, we use positive edge for both.
        // We'll treat rst as active-low? But the spec says "active-high reset signal". So rst=1 resets. So we need to check rst.

        // In the module, we can check rst as an active-high reset. So we use always block sensitive to rst.
        // But the initial block also handles rst. Maybe we can combine.

        // But to keep it simple, we can use the same logic in the always block.

        // We'll handle reset in the always block as well? But we already handled rst in the initial block.

        // Let's just use the always block for all.

        // But we need to replicate the initial logic inside the always block? Not necessary.

        // Instead, we can use the same code inside the always block, but we need to consider the reset condition.

        // Actually, we can just rely on the initial block for rst, and for other cases, we use the always block.

        // But to avoid duplication, we can use the initial block only once.

        // Let's restructure: The initial block sets up the registers and initial state. Then in the always block, we handle the next steps.

        // But the code above is already covering the initial state and the subsequent logic.

    end else begin
        // For rst=0, we don't do anything in the else part? Actually, the else block is for rst=0, but we need to handle rst=0 in the always block.

        // We can restructure: We'll use an always block that runs on positive edges, and inside we handle reset and normal operation.

        // Let's rewrite more cleanly:

    always @(posedge clk) begin
        if (!rst) begin
            // Reset: set registers to initial values
            regA <= 0;
            regB <= 1;
            fib_out <= 0;
            overflow_flag <= 0;
        end

        else begin
            // Compute next Fibonacci
            next_fib = regA + regB;
            overflow_detected = (next_fib[31] == 1);
            if (overflow_detected) begin
                overflow_flag <= 1;
            end else begin
                overflow_flag <= 0;
            end

            // Update registers
            regA <= regB;
            regB <= next_fib;
            fib_out <= regB;
        end
    end

endfunction
