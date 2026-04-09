module FILO_RTL #(
  parameter DATA_WIDTH = 8,
  parameter FILO_DEPTH = 16
) (
  input  logic clk,
  input  logic rst,
  input  logic push,
  input  logic pop,
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out,
  output logic full,
  output logic empty
);

  // Add your code here to implement the FILO buffer

endmodule