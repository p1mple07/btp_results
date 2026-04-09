module low_pass_filter #(
  parameter int unsigned DATA_WIDTH  = 16,
  parameter int unsigned COEFF_WIDTH = 16,
  parameter int unsigned NUM_TAPS    = 8
) (
  // Clock and Reset
  input logic clk,
  input logic reset,

  // Input Ports
  input logic [DATA_WIDTH*NUM_TAPS-1:0] data_in,
  input logic valid_in,
  input logic [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,

  // Output Ports
  output logic [DATA_WIDTH*(NUM_TAPS+1)-1:0] data_out,
  output logic valid_out
);

  // Your implementation here

endmodule