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
        rounding_up = 1'b0;
        if (stickyin == 1'b1 || (in_data[WIDTH-1] == 1'b1 && in_data[WIDTH-2]!= 1'b0)) begin
          rounding_up = 1'b1;
        end
      end
      RTZ: rounding_up = 1'b0;
      RUP: rounding_up = 1'b1;
      RDN: rounding_up = 1'b0;
      RMM: rounding_up = 1'b0;
      default: rounding_up = 1'b0; // Default to no rounding
    endcase

  end

  // Output assignments
  assign out_data = {sign, in_data[WIDTH-2:0]};
  assign inexact = 1'b0; // Placeholder, implement logic for precision loss detection
  assign cout = 1'b0; // Placeholder, implement logic for carry-out_data
  assign r_up = rounding_up;

endmodule