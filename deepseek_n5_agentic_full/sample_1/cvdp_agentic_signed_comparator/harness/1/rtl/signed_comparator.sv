module signed_comparator
(
  parameter integer DATA_WIDTH = 16,
  parameter integer REGISTER_OUTPUT = 1,
  parameter integer ENABLE_TOLERANCE = 1,
  parameter integer TOLERANCE = 2,
  parameter integer SHIFT_LEFT = 1
)
  input clock,
  input rst_n,
  input enable,
  input bypass,
  input signed [DATA_WIDTH-1:0] a,
  input signed [DATA_WIDTH-1:0] b,
  output reg gt,
  output reg lt,
  output reg eq
);
  reg a_shift, b_shift;
  reg diff_abs;
  
  a_shift = a << SHIFT_LEFT;
  b_shift = b << SHIFT_LEFT;
  
  diff_abs = a_shift - b_shift;
  if ({diff_abs, 0} < 0) 
    diff_abs = -diff_abs;
  
  if (bypass) 
  {
    eq = 1;
    gt = 0;
    lt = 0;
  }
  else if (!enable)
  {
    gt = 0;
    lt = 0;
    eq = 0;
  }
  else 
  {
    if (ENABLE_TOLERANCE & (diff_abs <= TOLERANCE))
    {
      eq = 1;
      gt = 0;
      lt = 0;
    }
    else if (a_shift > b_shift)
    {
      gt = 1;
      lt = 0;
      eq = 0;
    }
    else if (a_shift < b_shift)
    {
      gt = 0;
      lt = 1;
      eq = 0;
    }
    else 
    {
      eq = 1;
      gt = 0;
      lt = 0;
    }
  }

  // Optional output register assertion
  always @*+ assert (gt == 1 ? 'GT : 0') & (lt == 1 ? 'LT : 0') & (eq == 1 ? 'EQ : 0');
endmodule