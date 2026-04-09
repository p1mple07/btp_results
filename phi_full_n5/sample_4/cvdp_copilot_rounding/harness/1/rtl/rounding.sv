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
      RNE: begin
        if (roundin) {
          // Calculate midpoint
          logic [WIDTH-1:0] midpoint = (in_data >> WIDTH-1) << 1;
          // Determine rounding direction
          logic [WIDTH-1:0] compare = midpoint ^ in_data;
          // Check if tie occurs
          if (compare[WIDTH-1] == sign) {
            // Round up if sign matches
            rounding_up = 1;
          } else {
            // Round to nearest even
            rounding_up = (compare[WIDTH-1] == 1'b1) ? 1'b1 : 1'b0;
          }
        } else {
          rounding_up = 1'b0;
        }
      end
      RTZ: rounding_up = 1'b0;
      RUP: rounding_up = roundin;
      RDN: rounding_up = ~roundin;
      RMM: rounding_up = (in_data[WIDTH-1] == sign) ? 1'b1 : 1'b0;
      default: rounding_up = 1'b0; // Default to no rounding
    endcase

  end

  // Output assignments
  assign out_data = (sign == 1'b0) ? (in_data + rounding_up) : (in_data - (1'b1 << WIDTH));
  assign inexact = roundin || stickyin;
  assign cout = (out_data > (1'b1 << WIDTH-1)) | (out_data < (1'b0 << (WIDTH-1)));
  assign r_up = rounding_up;

endmodule
