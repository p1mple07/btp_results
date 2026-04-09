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
      RNE: rounding_up = (in_data[WIDTH-1] == 1'b1);
      RTZ: rounding_up = 1'b0;
      RUP: rounding_up = 1'b1;
      RDN: rounding_up = 1'b1;
      RMM: rounding_up = 1'b1;
      default: rounding_up = 1'b0;
    endcase

  end

  assign out_data = (rounding_up ? (in_data + (roundin ? 1'b1 : 0)) / 2 : in_data) / 2;

  assign inexact = (rounding_up || stickyin);
  assign cout = (rounding_up) ? 1'b1 : 1'b0;
  assign r_up = rounding_up;

endmodule
