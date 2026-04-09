module signed_comparator #(
  parameter integer DATA_WIDTH = 16,
  parameter integer REGISTER_OUTPUT = 0,
  parameter integer ENABLE_TOLERANCE = 0,
  parameter integer TOLERANCE = 0,
  parameter integer SHIFT_LEFT = 0
)(
  input clock,
  input rst_n,
  input enable,
  input bypass,
  input wire signed [DATA_WIDTH-1:0] a,
  input wire signed [DATA_WIDTH-1:0] b,
  output reg gt,
  output reg lt,
  output reg eq
);

  // Perform left shift on both inputs
  wire signed [DATA_WIDTH-1:0] a_shifted, b_shifted;
  a_shifted = a << SHIFT_LEFT;
  b_shifted = b << SHIFT_LEFT;

  // Calculate absolute difference for tolerance check
  wire signed [DATA_WIDTH+1:0] diff_abs;
  diff_abs = a_shifted - b_shifted;
  if (diff_abs < 0) {
    diff_abs = -diff_abs;
  }

  // Determine comparison results
  always @* begin
    if (enable == 0) begin
      gt = 0;
      lt = 0;
      eq = 0;
    elsif (bypass == 1) begin
      gt = 0;
      lt = 0;
      eq = 1;
    else begin
      if (ENABLE_TOLERANCE && (diff_abs <= TOLERANCE)) begin
        gt = 0;
        lt = 0;
        eq = 1;
      else if (a_shifted > b_shifted) begin
        gt = 1;
        lt = 0;
        eq = 0;
      else if (a_shifted < b_shifted) begin
        gt = 0;
        lt = 1;
        eq = 0;
      else begin
        gt = 0;
        lt = 0;
        eq = 1;
      end
    end
  end

  // Assign results to outputs
  gt <= gt;
  lt <= lt;
  eq <= eq;

endmodule