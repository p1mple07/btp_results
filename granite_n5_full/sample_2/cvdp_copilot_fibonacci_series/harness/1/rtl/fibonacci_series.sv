module fibonacci_series (
  input wire clk, // Clock signal
  input wire rst, // Active-high reset signal
  output reg [31:0] fib_out, // Output Fibonacci number
  output reg overflow_flag // Flag for overflow detection
);

  reg [31:0] RegA; // Register for Fibonacci number A
  reg [31:0] RegB; // Register for Fibonacci number B
  reg [31:0] next_fib; // Next Fibonacci number to be calculated
  reg overflow_detected; // Flag for overflow detection

  always @(posedge clk) begin
    if (rst) begin
      RegA <= 0; // Initialize RegA to 0
      RegB <= 1; // Initialize RegB to 1
      fib_out <= 0; // Set fib_out to 0
      overflow_flag <= 0; // Clear overflow flag
    end else begin
      next_fib <= RegA + RegB; // Calculate next_fib

      if (next_fib > 32'hFFFFFFFF) begin
        overflow_detected <= 1; // Set overflow flag
        fib_out <= 0; // Reset fib_out and start over
      end else begin
        fib_out <= RegB; // Update fib_out with current RegB value
        overflow_flag <= 0; // Clear overflow flag
      end
    end
  end
endmodule