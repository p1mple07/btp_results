module rounding #(
  parameter WIDTH = 24
)(
  input logic  [WIDTH-1:0] in_data     , // Input value for rounding
  input logic              sign   , // Indicates sign of input (1: negative, 0: positive)
  input logic              roundin, // Round bit
  input logic              stickyin, // Sticky bit for precision
  input logic  [2:0]       rm     , // Rounding mode
  output logic [WIDTH-1:0] out_data    , // Rounded output
  output logic             inexact, // Indicates precision loss
  output logic             cout   , // Carry-out_data signal
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
        rounding_up = 1'b0; // No rounding for RNE
        inexact = 1'b0; // Precision loss not needed for RNE
      end
      RTZ: begin
        rounding_up = 1'b0; // No rounding for RTZ
        inexact = 1'b0; // Precision loss not needed for RTZ
      end
      RUP: begin
        rounding_up = 1'b1; // Round up for RUP
        inexact = 1'b0; // Precision loss not needed for RUP
      end
      RDN: begin
        rounding_up = 1'b0; // No rounding for RDN
        inexact = 1'b0; // Precision loss not needed for RDN
      end
      RMM: begin
        rounding_up = 1'b1; // Round up for RMM
        inexact = 1'b0; // Precision loss not needed for RMM
      end
      default: begin
        rounding_up = 1'b0; // Default to no rounding
        inexact = 1'b0; // No need to check precision loss for default case
      end
    endcase

  end

  // Output assignments
  assign out_data = 
    sign? 
        (|in_data)? 
        in_data + 1. 
            (|in_data)? 
            2's complement of in_data : 
            in_data;
  assign inexact = 1'b0; // No need to check precision loss for default case
  assign cout = 
    sign? 
        1'b0 : 
        1'b1; // Always generate carry out
  assign r_up = 
    sign? 
        1'b0 : 
        1'b1; // Always generate rounding up

endmodule