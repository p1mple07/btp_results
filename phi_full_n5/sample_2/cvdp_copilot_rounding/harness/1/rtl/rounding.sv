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
        rounding_up = |(in_data[WIDTH-1:0] & sign) == 0;
        inexact = roundin | stickyin;
        out_data = in_data + (rounding_up ? 1 : 0);
        if (rounding_up) out_data[WIDTH-1] = 1;
        if (out_data[WIDTH-1] > in_data[WIDTH-1]) cout = 1;
        r_up = rounding_up;
      end
      RTZ: begin
        inexact = roundin | stickyin;
        out_data = in_data;
        if (out_data[WIDTH-1] > in_data[WIDTH-1]) cout = 1;
        r_up = 0;
      end
      RUP: begin
        rounding_up = |(in_data[WIDTH-1:0] & sign) == 1;
        inexact = roundin | stickyin;
        out_data = in_data + (rounding_up ? 1 : 0);
        r_up = rounding_up;
      end
      RDN: begin
        rounding_up = |(in_data[WIDTH-1:0] & sign) == -1;
        inexact = roundin | stickyin;
        out_data = in_data - (rounding_up ? 1 : 0);
        r_up = rounding_up;
      end
      RMM: begin
        rounding_up = |(in_data[WIDTH-1:0] & ~sign) == 0;
        inexact = roundin | stickyin;
        out_data = in_data + (rounding_up ? 1 : 0);
        r_up = rounding_up;
      end
      default: begin
        out_data = in_data;
        inexact = 0;
        cout = 0;
        r_up = 0;
      end
    endcase

  end

endmodule
