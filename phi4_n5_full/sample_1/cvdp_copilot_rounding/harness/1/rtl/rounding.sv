module rounding #(
  parameter WIDTH = 24
)(
  input  logic [WIDTH-1:0] in_data,  // Input value for rounding (magnitude)
  input  logic              sign,   // Sign of input (0: positive, 1: negative)
  input  logic              roundin,// Round bit (guard)
  input  logic              stickyin,// Sticky bit (precision loss in trailing bits)
  input  logic [2:0]        rm,     // Rounding mode select
  output logic [WIDTH-1:0] out_data,// Rounded output value
  output logic             inexact,// Indicates precision loss
  output logic             cout,   // Overflow flag
  output logic             r_up    // Indicates that rounding (up) occurred
);

  // Define supported rounding modes
  localparam RNE = 3'b000; 
  localparam RTZ = 3'b001; 
  localparam RUP = 3'b010; 
  localparam RDN = 3'b011; 
  localparam RMM = 3'b100; 

  // Internal flag to indicate if a rounding increment (or decrement) is needed.
  // For positive numbers, a true flag means add 1; for negative numbers, it means subtract 1.
  logic rounding_up;

  // The maximum representable value for WIDTH bits.
  wire [WIDTH-1:0] max_val = {WIDTH{1'b1}};

  // Assume that the bit being dropped (the rounding bit) is the least significant bit.
  wire round_bit = in_data[0];

  // Determine rounding decision based on mode.
  // For RNE: if guard is 1 then round if either sticky is 1 or (if no sticky then round if the bit to be dropped is 1)
  // For RTZ: no rounding (truncate).
  // For RUP: round if any fractional bits are present.
  // For RDN: for positive numbers, do not round; for negative numbers, round (away from zero) if fractional bits exist.
  // For RMM: round away from zero regardless of sign.
  always_comb begin
    case (rm)
      RNE: rounding_up = roundin && (stickyin || round_bit);
      RTZ: rounding_up = 1'b0;
      RUP: rounding_up = roundin || stickyin;
      RDN: rounding_up = (sign ? (roundin || stickyin) : 1'b0);
      RMM: rounding_up = roundin || stickyin;
      default: rounding_up = 1'b0; // Unsupported mode: default to no rounding (RTZ behavior)
    endcase
  end

  // The rounded output is computed by adding or subtracting 1 based on the sign.
  // For positive numbers, add 1 if rounding_up is true; for negative numbers, subtract 1.
  assign out_data = (sign ? (in_data - rounding_up) : (in_data + rounding_up));

  // Precision loss (inexact) is flagged only when a supported rounding mode is selected.
  // If an unsupported mode is used, we do not signal inexact.
  assign inexact = ((rm == RNE || rm == RTZ || rm == RUP || rm == RDN || rm == RMM) ? (roundin || stickyin) : 1'b0);

  // Detect overflow:
  // For positive numbers, if (in_data + rounding_up) exceeds the maximum representable value, set cout.
  // For negative numbers, if in_data is less than rounding_up (i.e. underflow would occur when subtracting),
  // then set cout.
  assign cout = (sign ? (in_data < rounding_up) : ((in_data + rounding_up) > max_val));

  // r_up indicates that a rounding operation occurred.
  assign r_up = rounding_up;

endmodule