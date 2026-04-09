module wishbone_to_ahb_bridge (
  input clk_i,
  input rst_i,

  input cyc_i,
  input stb_i,
  input [3:0] sel_i,
  input we_i,
  input [31:0] addr_i,
  input [31:0] data_i,

  output logic [31:0] data_o,
  output logic ack_o,

  input hclk,
  input hreset_n,
  output logic [31:0] hrdata,
  output logic [1:0] hresp,
  output logic hready
);

  // Add your implementation here

endmodule