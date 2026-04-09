module implements a configurable PRBS generator and checker.

module cvdp_prbs_gen #(
  // Mode selection:
  //   0 - Generator mode
  //   1 - Checker mode
  parameter CHECK_MODE = 0,

  // Polynomial details
  parameter int unsigned POLY_LENGTH = 31,
  parameter int unsigned POLY_TAP     = 3,

  // Seed details
  parameter int unsigned WIDTH       = 16
)(
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic [WIDTH-1:0]    data_in_i,
  output logic [WIDTH-1:0]    data_out_o
);

  // Your implementation here

endmodule