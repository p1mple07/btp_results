module fibonacci_series (
  input  logic         clk,
  input  logic         rst,
  output logic [31:0]  fib_out,
  output logic         overflow_flag
);

  // Registers to hold previous Fibonacci numbers
  logic [31:0] RegA, RegB;
  // One-cycle flag to indicate that overflow was detected in the previous cycle
  logic        overflow_detected;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset behavior: initialize sequence and clear flags
      RegA        <= 32'd0;  // F(0) = 0
      RegB        <= 32'd1;  // F(1) = 1
      fib_out     <= 32'd0;  // Output starts with F(0)
      overflow_flag <= 1'b0;
      overflow_detected <= 1'b0;
    end
    else begin
      // Compute next Fibonacci number using 33-bit addition to detect overflow.
      logic [32:0] next_fib;
      next_fib = {1'b0, RegA} + {1'b0, RegB};
      
      if (overflow_detected) begin
        // This cycle follows an overflow detection.
        // Propagate the last valid Fibonacci number from the previous cycle.
        // Then reset the sequence and set the overflow flag.
        RegA        <= 32'd0;  // Restart sequence: F(0) = 0
        RegB        <= 32'd1;  // Restart sequence: F(1) = 1
        fib_out     <= 32'd0;  // Reset output
        overflow_flag <= 1'b1; // Indicate overflow occurred
        overflow_detected <= 1'b0;
      end
      else if (next_fib[32]) begin
        // Overflow detected in this cycle: the computed sum exceeds 32 bits.
        // Propagate the last valid Fibonacci number.
        fib_out     <= RegB;
        // Set the one-cycle flag so that on the next cycle, the sequence resets.
        overflow_detected <= 1'b1;
        // Do not update registers normally.
      end
      else begin
        // Normal Fibonacci calculation without overflow.
        RegA        <= RegB;
        RegB        <= next_fib[31:0];
        fib_out     <= RegB;
        overflow_detected <= 1'b0;
        overflow_flag <= 1'b0;
      end
    end
  end

endmodule