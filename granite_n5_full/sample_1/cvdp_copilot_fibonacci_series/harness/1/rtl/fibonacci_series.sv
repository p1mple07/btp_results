module fibonacci_series (
  input wire clk,
  input wire rst,
  output reg [31:0] fib_out,
  output reg overflow_flag
);

  reg [31:0] RegA;
  reg [31:0] RegB;
  reg [31:0] next_fib;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      RegA <= 0;
      RegB <= 1;
      fib_out <= 0;
      overflow_flag <= 0;
    end else begin
      next_fib <= RegA + RegB;
      if (next_fib > 32'hFFFFFFFF) begin
        overflow_flag <= 1;
      end
      fib_out <= RegB;
      RegA <= RegB;
      RegB <= next_fib;
    end
  end
endmodule