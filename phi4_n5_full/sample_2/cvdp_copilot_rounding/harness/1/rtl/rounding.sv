module rounding #(
  parameter WIDTH = 24
)(
  input  logic [WIDTH-1:0] in_data,  // Input value for rounding
  input  logic             sign,    // Indicates sign of input (1: negative, 0: positive)
  input  logic             roundin, // Round bit (guard)
  input  logic             stickyin,// Sticky bit (accumulated fraction)
  input  logic [2:0]       rm,      // Rounding mode selection
  output logic [WIDTH-1:0] out_data,// Rounded output value
  output logic             inexact, // Indicates precision loss
  output logic             cout,    // Overflow flag
  output logic             r_up     // Indicates rounding up occurred
);

  // Define supported rounding modes
  localparam RNE = 3'b000; 
  localparam RTZ = 3'b001; 
  localparam RUP = 3'b010; 
  localparam RDN = 3'b011; 
  localparam RMM = 3'b100; 

  // Signal to determine if the provided rm is supported.
  // If not, the design defaults to no rounding (RTZ behavior) and clears flags.
  logic supported;
  assign supported = (rm == RNE) || (rm == RTZ) ||
                     (rm == RUP) || (rm == RDN) ||
                     (rm == RMM);

  // Compute the rounding decision based on the selected mode.
  // For RNE: round to nearest, with ties resolved to even.
  // For RTZ: no rounding (truncate).
  // For RUP: for positive numbers round up if any fraction; for negative numbers, do not round.
  // For RDN: for negative numbers round up (i.e. increase magnitude) if any fraction; for positive, do not round.
  // For RMM: round away from zero (i.e. always round up if any fraction exists).
  logic rounding_up;
  always_comb begin
    if (supported) begin
      case (rm)
        RNE: rounding_up = roundin ? (stickyin | in_data[0]) : 1'b0;
        RTZ: rounding_up = 1'b0;
        RUP: rounding_up = (sign ? 1'b0 : (roundin || stickyin));
        RDN: rounding_up = (sign ? (roundin || stickyin) : 1'b0);
        RMM: rounding_up = (roundin || stickyin);
        default: rounding_up = 1'b0;
      endcase
    end
    else begin
      rounding_up = 1'b0;
    end
  end

  // When rounding is supported, add the rounding decision to the input.
  // Otherwise, output the original value and clear the flags.
  assign out_data = supported ? (in_data + rounding_up) : in_data;
  assign inexact  = supported ? (roundin || stickyin) : 1'b0;
  // Detect overflow if adding 1 to the maximum representable value.
  assign cout     = supported ? ((in_data == {WIDTH{1'b1}}) && rounding_up) : 1'b0;
  assign r_up     = supported ? rounding_up : 1'b0;

endmodule