module rounding (#(WIDTH=24)) (
  input logic [WIDTH-1:0] in_data,
  input logic sign,
  input logic roundin,
  input logic stickyin,
  input logic [2:0] rm,
  output logic [WIDTH-1:0] out_data,
  output logic inexact,
  output logic cout,
  output logic r_up
);

  localparam RNE = 3'b000;
  localparam RTZ = 3'b001;
  localparam RUP = 3'b010;
  localparam RDN = 3'b011;
  localparam RMM = 3'b100;

  logic rounding_up;

  always_comb begin
    case (rm)
      RNE: rounding_up = (roundin);
      RTZ: rounding_up = (roundin);
      RUP: rounding_up = (roundin);
      RDN: rounding_up = (roundin);
      RMM: rounding_up = roundin;
      default: rounding_up = 1'b0;
    endcase

    assign out_data = in_data + rounding_up * WIDTH / 2;
    assign inexact = (roundin || stickyin) ? 1 : 0;
    assign cout = (in_data[WIDTH-1] == 1'b1 && rounding_up) ? 1 : 0;
    assign r_up = rounding_up;
  end

endmodule
