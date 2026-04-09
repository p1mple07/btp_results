module perfect_squares_generator (
  input logic clk,
  input logic reset,
  output logic [31:0] sqr_o
);

  // Internal variables
  logic [31:0] base;
  logic [31:0] sqr;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Initialize to first square on reset
      base <= 1;
      sqr <= 1;
    end else begin
      // Calculate next square based on internal counter
      sqr <= sqr + base;
      // Increment internal counter for next square calculation
      base <= base + 1;
      // Saturate output if necessary
      if (sqr > 32'hFFFFFFFF) sqr <= 32'hFFFFFFFF;
    end
  end

  assign sqr_o = sqr;

endmodule