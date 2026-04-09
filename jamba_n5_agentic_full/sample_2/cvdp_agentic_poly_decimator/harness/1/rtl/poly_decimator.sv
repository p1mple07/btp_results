module poly_decimator #(
  parameter M = 4,
  parameter TAPS = 8,
  parameter COEFF_WIDTH = 16,
  parameter DATA_WIDTH = 16,
  parameter ACC_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS)
)
(
  input  logic         clk,
  input  logic         arst_n,
  input  logic [DATA_WIDTH-1:0] in_sample [0:TAPS*M-1],
  input  logic         valid_in,
  // Outputs
  output logic [DATA_WIDTH-1:0] out_sample [0:(M-1)*TAPS],
  output logic         out_valid
);
