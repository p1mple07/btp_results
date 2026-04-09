module signed_comparator(
  parameter integer DATA_WIDTH,
  parameter integer REGISTER_OUTPUT,
  parameter integer ENABLE_TOLERANCE,
  parameter integer TOLERANCE,
  parameter integer SHIFT_LEFT
)

  input wire clock;
  input wire rst_n;
  input wire enable;
  input wire bypass;
  input wire signed [DATA_WIDTH-1:0] a;
  input wire signed [DATA_WIDTH-1:0] b;
  output reg gt, lt, eq;

  // Shift logic
  localparam a_shift = a << SHIFT_LEFT;
  localparam b_shift = b << SHIFT_LEFT;

  // Compute difference and absolute difference
  localparam diff = a_shift - b_shift;
  localparam abs_diff = (diff >= 0) ? diff : -(diff);

  // Bypass case
  if (bypass) begin
    eq = 1;
    gt = 0;
    lt = 0;
  elsif !enable begin
    eq = 0;
    gt = 0;
    lt = 0;
  else begin
    // Enable case
    if (ENABLE_TOLERANCE && (abs_diff <= TOLERANCE)) begin
      eq = 1;
      gt = 0;
      lt = 0;
    else begin
      if (a_shift > b_shift) begin
        gt = 1;
        lt = 0;
        eq = 0;
      elseif (a_shift < b_shift) begin
        gt = 0;
        lt = 1;
        eq = 0;
      else begin
        eq = 1;
        gt = 0;
        lt = 0;
      end
    end
  end

endmodule