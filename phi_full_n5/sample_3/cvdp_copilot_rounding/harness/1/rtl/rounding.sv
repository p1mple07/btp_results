module rounding #(
  parameter WIDTH = 24
)(
  input logic  [WIDTH-1:0] in_data      , // Input value for rounding
  input logic              sign    , // Indicates sign of input (1: negative, 0: positive)
  input logic              roundin , // Round bit
  input logic              stickyin, // Sticky bit for precision
  input logic  [2:0]       rm      , // Rounding mode
  output logic [WIDTH-1:0] out_data     , // Rounded output
  output logic             inexact , // Indicates precision loss
  output logic             cout    , // Carry-out_data signal
  output logic             r_up      // Indicates rounding up
);

  
  localparam RNE = 3'b000; 
  localparam RTZ = 3'b001; 
  localparam RUP = 3'b010; 
  localparam RDN = 3'b011; 
  localparam RMM = 3'b100; 

  logic rounding_up;

  always_comb begin
    case (rm)
      RNE: {
        case {in_data[WIDTH-1], sign} // Check the MSB and sign
          'b0: rounding_up = 1'b0; // Even tie
          'b1: rounding_up = 1'b1; // Even tie
          'bx: rounding_up = 1'b0; // Odd tie
        endcase
      }
      RTZ: rounding_up = 1'b0; // Truncate without rounding up
      RUP: rounding_up = 1'b1; // Round towards positive infinity (ceiling behavior)
      RDN: rounding_up = 1'b0; // Round towards negative infinity (floor behavior)
      RMM: rounding_up = 1'b1; // Round away from zero
      default: rounding_up = 1'b0; // Default to no rounding
    endcase

  end

  // Output assignments
  assign out_data = {
    in_data,
    stickyin ? in_data[WIDTH-1] : 1'b0, // Shift MSB if sticky
    rounding_up ? 1'b1 : in_data[WIDTH-1] // Apply rounding up
  };
  assign inexact = (roundin | stickyin);
  assign cout = out_data[WIDTH] | out_data[WIDTH-1]; // Check for overflow
  assign r_up = rounding_up;

endmodule
