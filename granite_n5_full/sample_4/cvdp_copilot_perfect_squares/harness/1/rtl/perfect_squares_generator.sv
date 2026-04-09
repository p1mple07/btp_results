module perfect_squares_generator(
  input logic clk, // Positive-edge triggered
  input logic reset, // Active-high reset

  output logic [31:0] sqr_o // Current perfect square
);

  logic [31:0] sqr;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sqr <= 1;
    end else begin
      sqr <= sqr + 1;
    end
  end

  assign sqr_o = (sqr > 32'hFFFFFFFF)? 32'hFFFFFFFF : sqr * sqr;
endmodule