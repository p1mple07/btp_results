module ttc_counter_lite (
  input logic clk,
  input logic reset,
  input logic [3:0] axi_addr,
  input logic [31:0] axi_wdata,
  input logic axi_write_en,
  input logic axi_read_en,
  output logic [31:0] axi_rdata,
  output logic interrupt
);

  // Module implementation goes here

endmodule