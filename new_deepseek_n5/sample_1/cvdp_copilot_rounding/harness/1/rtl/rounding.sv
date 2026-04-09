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

  logic [WIDTH-1:0] truncated, [WIDTH-1:0] rounded;

  if (roundin) begin
    if (rm == RNE) begin
      // Round to nearest even
      truncated = in_data;
      if (sign) truncated = ~truncated & -1;
      if (truncated[WIDTH-1] & truncated[WIDTH-2]) begin
        if (truncated[WIDTH-2] == 0) begin
          // Tie case: round to nearest even
          if (truncated[WIDTH-3] & truncated[WIDTH-4]) begin
            truncated = truncated + 1;
          end
        end
      end
      rounded = truncated;
      rounding_up = truncated[WIDTH-2];
    elsif (rm == RTZ) begin
      // Round toward zero
      rounded = in_data;
      if (sign) rounded = ~rounded & -1;
    elsif (rm == RUP) begin
      // Round toward positive infinity
      if (sign) begin
        if (in_data) begin
          rounded = in_data + 1;
        end
      end else begin
        rounded = in_data;
      end
      rounding_up = 1;
    elsif (rm == RDN) begin
      // Round toward negative infinity
      if (!sign) begin
        if (in_data) begin
          rounded = in_data;
        end else begin
          rounded = in_data - 1;
        end
      end else begin
        rounded = in_data;
      end
      rounding_up = 1;
    elsif (rm == RMM) begin
      // Round to maximum magnitude
      if (sign) begin
        if (in_data) begin
          rounded = in_data - 1;
        end else begin
          rounded = in_data;
        end
      end else begin
        if (in_data) begin
          rounded = in_data + 1;
        end else begin
          rounded = in_data;
        end
      end
      rounding_up = 1;
    else begin
      // Default to RTZ
      rounded = in_data;
      rounding_up = 0;
    end
  end else begin
    rounded = in_data;
    inexact = 0;
    cout = 0;
    r_up = 0;
  end

  assign out_data = rounded;
  assign inexact = (roundin || stickyin);
  assign cout = (rounded != in_data);
  assign r_up = rounding_up;

endmodule