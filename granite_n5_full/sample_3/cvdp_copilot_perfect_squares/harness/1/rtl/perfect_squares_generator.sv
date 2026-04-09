module perfect_squares_generator(
  input logic clk,
  input logic reset,
  output logic [31:0] sqr_o
);

  // Internal counter to keep track of the base number for calculating squares
  reg [31:0] base;

  // Initialize the base number to 1
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      base <= 1;
    end else begin
      base <= base + 1;
    end
  end

  // Calculate the current perfect square based on the base number
  assign sqr_o = base * base;

endmodule