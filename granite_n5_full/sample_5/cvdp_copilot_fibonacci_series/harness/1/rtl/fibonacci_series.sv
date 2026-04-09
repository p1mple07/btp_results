module fibonacci_series(
  input logic clk,
  input logic rst,
  output logic [31:0] fib_out,
  output logic overflow_flag
);

  typedef enum { IDLE, CALCULATE, OVERFLOW } state_t;

  logic [31:0] RegA, RegB;
  logic [31:0] next_fib;
  state_t state;

  always_ff @(posedge clk) begin
    if (rst) begin
      RegA <= 0;
      RegB <= 1;
      fib_out <= 0;
      overflow_flag <= 0;
      state <= IDLE;
    end else begin
      case (state)
        IDLE: begin
          state <= CALCULATE;
        end
        CALCULATE: begin
          next_fib <= RegA + RegB;
          if (next_fib > 32'hFFFFFFFF) begin
            overflow_flag <= 1;
            state <= OVERFLOW;
          end else begin
            overflow_flag <= 0;
            RegA <= RegB;
            RegB <= next_fib;
            state <= CALCULATE;
          end
        end
        OVERFLOW: begin
          state <= IDLE;
        end
      endcase
    end
  end
endmodule