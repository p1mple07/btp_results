module perfect_squares_generator(
  input  logic clk,
  input  logic reset,
  output logic [31:0] sqr_o
);

  // Internal counter for the base number used to calculate the perfect square.
  logic [31:0] base;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // On reset, initialize base to 1 and sqr_o to 1 (first perfect square).
      base   <= 1;
      sqr_o  <= 1;
    end else begin
      // Increment the base number.
      base <= base + 1;
      
      // Calculate the perfect square using a 64-bit multiplication.
      logic [63:0] prod;
      prod = base * base;
      
      // Check for overflow: if product exceeds 32-bit maximum, saturate the output.
      if (prod > 32'hFFFFFFFF) begin
        sqr_o <= 32'hFFFFFFFF;
      end else begin
        sqr_o <= prod[31:0];
      end
    end
  end

endmodule