module fibonacci_series(
    input  logic         clk,
    input  logic         rst,
    output logic [31:0]  fib_out,
    output logic         overflow_flag
);

  // Internal registers for Fibonacci numbers
  logic [31:0] RegA, RegB;
  // Flag to indicate that an overflow was detected in the previous cycle.
  logic overflow_pending;

  // Synchronous process for Fibonacci sequence generation and overflow handling
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset: Initialize to F(0) = 0, F(1) = 1, output F(0) and clear flags
      RegA          <= 32'd0;
      RegB          <= 32'd1;
      fib_out       <= 32'd0;
      overflow_flag <= 1'b0;
      overflow_pending <= 1'b0;
    end
    // If an overflow was detected in the previous cycle, reset the sequence and assert overflow_flag.
    else if (overflow_pending) begin
      RegA          <= 32'd0;
      RegB          <= 32'd1;
      fib_out       <= 32'd0;
      overflow_flag <= 1'b1;
      overflow_pending <= 1'b0;
    end
    else begin
      // Calculate next Fibonacci number using 33-bit addition to detect overflow.
      logic [32:0] next_fib;
      next_fib = {1'b0, RegA} + {1'b0, RegB};

      if (next_fib[32]) begin
        // Overflow detected: Propagate the last valid Fibonacci number (RegB)
        fib_out       <= RegB;
        overflow_pending <= 1'b1;
        // Do not update registers in this cycle.
      end
      else begin
        // Normal update: shift registers and update output.
        RegA          <= RegB;
        RegB          <= next_fib[31:0];
        fib_out       <= RegB;
        overflow_flag <= 1'b0;
        overflow_pending <= 1'b0;
      end
    end
  end

endmodule