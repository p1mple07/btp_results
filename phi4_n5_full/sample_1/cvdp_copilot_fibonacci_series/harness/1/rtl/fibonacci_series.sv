module fibonacci_series(
    input  logic         clk,
    input  logic         rst,
    output logic [31:0]  fib_out,
    output logic         overflow_flag
);

  // Internal registers to hold Fibonacci values
  logic [31:0] RegA, RegB;
  // Internal flag to indicate an overflow was detected in the previous cycle
  logic        overflow_detected;

  always_ff @(posedge clk) begin
    if (rst) begin
      // Reset behavior: initialize to F(0)=0 and F(1)=1, clear outputs and flags
      RegA            <= 32'd0;
      RegB            <= 32'd1;
      fib_out         <= 32'd0;
      overflow_flag   <= 1'b0;
      overflow_detected <= 1'b0;
    end
    else begin
      // Check if we are in the cycle following an overflow detection
      if (overflow_detected) begin
        // On overflow, automatically restart the sequence:
        // Reset registers to F(0)=0 and F(1)=1, clear output, and assert overflow_flag.
        RegA            <= 32'd0;
        RegB            <= 32'd1;
        fib_out         <= 32'd0;
        overflow_flag   <= 1'b1;  // Remain high until a reset occurs
        overflow_detected <= 1'b0;
      end
      else begin
        // Compute next Fibonacci value using 33-bit addition to capture overflow
        logic [32:0] next_fib;
        next_fib = {1'b0, RegA} + {1'b0, RegB};
        
        // Check for overflow (carry out from bit 32)
        if (next_fib[32] == 1'b1) begin
          // Overflow detected:
          // Propagate the last valid Fibonacci number (current RegB) to fib_out.
          fib_out         <= RegB;
          // Set the overflow_detected flag to trigger a reset in the next cycle.
          overflow_detected <= 1'b1;
          // Do not update RegA and RegB this cycle.
        end
        else begin
          // Normal update: shift registers and update fib_out with the new Fibonacci number.
          RegA            <= RegB;
          RegB            <= next_fib[31:0];
          fib_out         <= RegB;
        end
      end
    end
  end

endmodule