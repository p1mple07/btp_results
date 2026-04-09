module fibonacci_series (
  input wire clk,
  input wire rst,
  output logic [31:0] fib_out,
  output logic overflow_flag
);

  // Define registers
  reg [31:0] RegA;
  reg [31:0] RegB;
  reg overflow_detected;

  // Register assignments
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      RegA <= 0;
      RegB <= 1;
      fib_out <= 0;
      overflow_flag <= 0;
    end else begin
      logic [63:0] next_fib;
      next_fib = {RegA, 1'b0} + {RegB, 1'b0};

      if (next_fib > 32'hFFFFFFFF) begin
        overflow_detected <= 1;
      end else begin
        overflow_detected <= 0;
      end

      if (overflow_detected) begin
        fib_out <= RegA;
        overflow_flag <= 1;
      end else begin
        fib_out <= RegB;
        overflow_flag <= 0;
      end
    end
  end

endmodule