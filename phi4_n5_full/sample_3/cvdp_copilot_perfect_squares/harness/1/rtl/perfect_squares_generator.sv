module perfect_squares_generator (
    input  logic         clk,
    input  logic         reset,
    output logic [31:0]  sqr_o
);

  // Internal register to hold the base number for calculating squares
  logic [31:0] base;
  // Temporary register to hold the next perfect square value
  logic [31:0] next_square;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // On reset, initialize base to 1 and output the first perfect square (1)
      base   <= 1;
      sqr_o  <= 1;
    end else begin
      // Increment the base for the next square calculation
      base   <= base + 1;
      // Calculate the next perfect square as base * base
      next_square = base * base;
      
      // Overflow protection: if the calculated square exceeds 32'hFFFFFFFF, saturate the output
      if (next_square > 32'hFFFFFFFF)
        sqr_o <= 32'hFFFFFFFF;
      else
        sqr_o <= next_square;
    end
  end

endmodule