module perfect_squares_generator (
  input  logic clk,
  input  logic reset,
  output logic [31:0] sqr_o
);

  // Internal register for storing the base number of the current perfect square
  reg [31:0] base;

  // Initialize base to 1 when reset is high
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      base <= 1;
    end else begin
      base <= base + 1;
    end
  end

  // Calculate the next perfect square by squaring the base number
  assign sqr_o = base * base;

  // Prevent overflow by clamping the output to 32-bit maximum
  assign sqr_o = sqr_o > 32'dFFFFFFFF? 32'hFFFFFFFF : sqr_o;

endmodule