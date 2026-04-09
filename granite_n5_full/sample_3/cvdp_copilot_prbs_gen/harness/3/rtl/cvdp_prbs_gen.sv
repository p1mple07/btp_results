module cvdp_prbs_gen #(
  // Parameter Details
  parameter int CHECK_MODE    = 0,  // CHECK_MODE = 0: Generator Mode; CHECK_MODE = 1: Checker Mode
  parameter int POLY_LENGTH   = 31, // Length of the polynomial
  parameter int POLY_TAP      = 3,  // Positions of the tap in the shift register that is XORed with bit at POLY_LENGTH to generate the feedback bit
  parameter int WIDTH          = 16  // Bit width of the data_in and data_out buses
) (
  // Module Inputs
  input  logic        clk,       // Clock input signal
  input  logic        rst,       // Synchronous reset signal
  input  logic [WIDTH-1:0] data_in,  // Input data bus

  // Module Outputs
  output logic [WIDTH-1:0] data_out  // Output data bus
);

  // Your implementation here

endmodule