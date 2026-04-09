module cipher(
  // Clock and Reset
  input logic clk,
  input logic rst_n,

  // Control Signals
  input logic start,

  // Data Input
  input logic [31:0] data_in,
  input logic [15:0] key,

  // Data Output
  output logic [31:0] data_out,
  output logic done
);

  // Your solution code here

endmodule