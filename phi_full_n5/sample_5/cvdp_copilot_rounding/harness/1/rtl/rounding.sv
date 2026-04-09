module rounding #(
  parameter WIDTH = 24
)(
  input logic  [WIDTH-1:0] in_data, // Input value for rounding
  input logic              sign, // Indicates sign of input (1: negative, 0: positive)
  input logic              roundin, // Round bit
  input logic              stickyin, // Sticky bit for precision
  input logic  [2:0]       rm, // Rounding mode
  output logic [WIDTH-1:0] out_data, // Rounded output
  output logic             inexact, // Indicates precision loss
  output logic             cout, // Carry-out_data signal
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
        // Determine the midpoint
        logic [WIDTH-1:0] midpoint = (in_data & ~(1 << (WIDTH - 1)));
        // Check if the next bit after midpoint is 1 (odd)
        logic [WIDTH-1:0] next_bit = in_data >> (WIDTH - 1);
        rounding_up = (next_bit & 1); // Set rounding_up if next bit is 1
        out_data = (in_data + (rounding_up ? 1 : 0)) << (WIDTH - 1);
        out_data = out_data | midpoint;
      end
      RTZ: begin
        out_data = in_data >> 1;
        inexact = roundin | stickyin;
        r_up = 0;
      end
      RUP: begin
        // Check if the sign bit is 0 (positive)
        out_data = (in_data > sign ? in_data : in_data >> 1) << (WIDTH - 1);
        inexact = roundin | stickyin;
        r_up = (in_data > sign);
      end
      RDN: begin
        // Check if the sign bit is 1 (negative)
        out_data = (in_data < sign ? in_data : in_data >> 1) << (WIDTH - 1);
        inexact = roundin | stickyin;
        r_up = (in_data < sign);
      end
      RMM: begin
        // Determine the maximum magnitude value
        logic [WIDTH-1:0] max_mag = (in_data & 1) ? (1 << (WIDTH - 1)) : in_data;
        // Round away from zero
        out_data = (in_data > sign ? (in_data + (rounding_up ? 1 : 0)) : (in_data - (rounding_up ? 1 : 0)));
        inexact = roundin | stickyin;
        r_up = rounding_up;
        // Check for overflow
        cout = out_data > max_mag;
      end
      default: begin
        // Default to no rounding
        out_data = in_data >> 1;
        inexact = roundin | stickyin;
        r_up = 0;
      end
    endcase

  end

  // Overflow check
  assign cout = (out_data > (1 << (WIDTH - 1))) | (out_data < 0);

endmodule
