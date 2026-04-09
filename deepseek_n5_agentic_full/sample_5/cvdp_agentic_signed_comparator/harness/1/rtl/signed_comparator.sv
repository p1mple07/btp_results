module signed_comparator(
  parameter integer DATA_WIDTH = 16,
  parameter integer REGISTER_OUTPUT = 0,
  parameter integer ENABLE_TOLERANCE = 0,
  parameter integer TOLERANCE = 0,
  parameter integer SHIFT_LEFT = 0
) 
port 
  input wire signed [DATA_WIDTH-1:0] a,
  input wire signed [DATA_WIDTH-1:0] b,
  output reg gt,
  output reg lt,
  output reg eq
);
  
  localparam SHIFT = SHIFT_LEFT;
  
  // Left shift inputs
  wire signed [DATA_WIDTH+SHIFT-1:0] a_shift = a << SHIFT;
  wire signed [DATA_WIDTH+SHIFT-1:0] b_shift = b << SHIFT;
  
  // Compute difference
  wire signed [DATA_WIDTH+SHIFT-1:0] diff = a_shift - b_shift;
  wire signed [DATA_WIDTH+SHIFT-1:0] abs_diff;
  
  // Absolute difference
  wire abs_diff = ($abs(diff)); // Using absolute value
  
  // Register output control
  reg output wire [DATA_WIDTH+SHIFT-1:0] result;
  
  // Logic control
  if (bypass == 1)
    result = (a_shift == b_shift ? (gt=1; lt=0; eq=1) : (gt=0; lt=0; eq=0));
  else if (enable == 0)
    result = (gt=0; lt=0; eq=0);
  else
    case (abs_diff <= TOLERANCE)
      eq = 1;
      gt = 0;
      lt = 0;
      break;
    endcase
    case (diff > 0)
      gt = 1;
      lt = 0;
      eq = 0;
      break;
    endcase
    case (diff < 0)
      gt = 0;
      lt = 1;
      eq = 0;
      break;
    default:
      eq = 1;
      gt = 0;
      lt = 0;
      break;
    endcase
  
  // Assign outputs based on register output setting
  if (REGISTER_OUTPUT == 1)
    result;
  else
    gt = result[DATA_WIDTH+SHIFT-1];
    lt = result[DATA_WIDTH+SHIFT];
    eq = result[DATA_WIDTH+SHIFT+1];