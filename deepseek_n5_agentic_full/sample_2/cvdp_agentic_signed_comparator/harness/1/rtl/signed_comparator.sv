module signed_comparator
(
  parameter integer DATA_WIDTH,
  parameter integer REGISTER_OUTPUT,
  parameter integer ENABLE_TOLERANCE,
  parameter integer TOLERANCE,
  parameter integer SHIFT_LEFT
)
#(
  parameter integer SHIFT_LEFT = 0
)

  input wire clock,
  input wire rst_n,
  input wire enable,
  input wire bypass,
  input wire [DATA_WIDTH-1:0] a,
  input wire [DATA_WIDTH-1:0] b,
  output reg gt,
  output reg lt,
  output reg eq
);

  // Perform left shift on inputs
  wire [DATA_WIDTH+SHIFT_LEFT:0] a_shifted = a << SHIFT_LEFT;
  wire [DATA_WIDTH+SHIFT_LEFT:0] b_shifted = b << SHIFT_LEFT;

  // Compute difference for tolerance check
  wire [DATA_WIDTH+SHIFT_LEFT:0] diff_abs;

  always @* begin
    if (bypass) begin
      eq = 1;
      gt = 0;
      lt = 0;
    elsif !enable begin
      gt = 0;
      lt = 0;
      eq = 0;
    else begin
      if (ENABLE_TOLERANCE && (diff_abs <= TOLERANCE)) begin
        eq = 1;
        gt = 0;
        lt = 0;
      else if (a_shifted > b_shifted) begin
        gt = 1;
        lt = 0;
        eq = 0;
      else if (a_shifted < b_shifted) begin
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

  // Register output if needed
  if (REGISTER_OUTPUT) begin
    always @posedge clock begin
      gt <= gt;
      lt <= lt;
      eq <= eq;
    end
  end
endmodule