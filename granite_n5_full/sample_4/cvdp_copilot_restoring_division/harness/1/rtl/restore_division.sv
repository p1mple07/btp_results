module restoring_division #(parameter WIDTH=6) (
  input wire clk,
  input wire rst,
  input wire start,
  input wire [WIDTH-1:0] dividend,
  input wire [WIDTH-1:0] divisor,
  output reg [WIDTH-1:0] quotient,
  output reg [WIDTH-1:0] remainder,
  output reg valid
);

  // Module variables
  reg [WIDTH-1:0] dividend_reg;
  reg [WIDTH-1:0] remainder_reg;
  reg [WIDTH-1:0] quotient_reg;
  reg [WIDTH-1:0] divisor_reg;
  reg done;
  reg shift_left_done;

  always @(posedge clk) begin
    if (rst) begin
      dividend_reg <= 'h0;
      remainder_reg <= 'h0;
      quotient_reg <= 'h0;
      divisor_reg <= 'h0;
      valid <= 0;
      done <= 0;
      shift_left_done <= 0;
    end else if (!done && start) begin
      valid <= 1;
      dividend_reg <= dividend;
      divisor_reg <= divisor;
      shift_left_done <= 0;
      done <= 0;
      quotient_reg <= 'h0;
      remainder_reg <= dividend_reg;
    end else if (shift_left_done &&!done) begin
      if (remainder_reg[WIDTH-1])
        quotient_reg <= {quotient_reg, 1'b0};
      else
        quotient_reg <= {quotient_reg, 1'b1};
      remainder_reg <= {remainder_reg[WIDTH-2:0], divisor_reg[WIDTH-1]};
      done <= 1;
    end
  end

  assign quotient = quotient_reg;
  assign remainder = remainder_reg;
  assign valid = done;

endmodule