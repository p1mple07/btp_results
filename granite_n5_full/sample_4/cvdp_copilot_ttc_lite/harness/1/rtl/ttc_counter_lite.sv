module ttc_counter_lite #(
  parameter int unsigned COUNT_WIDTH = 32,
  parameter int unsigned MATCH_WIDTH = 32,
  parameter int unsigned RELOAD_WIDTH = 32
) (
  input logic clk,
  input logic rst_n,

  input logic [3:0] axi_addr,
  input logic [31:0] axi_wdata,
  input logic axi_write_en,
  output logic [31:0] axi_rdata,
  output logic axi_rvalid,

  input logic enable,
  input logic interval_mode,
  input logic interrupt_enable,
  input logic [MATCH_WIDTH-1:0] match_value,
  input logic [RELOAD_WIDTH-1:0] reload_value,
  output logic interrupt,

  output logic [COUNT_WIDTH-1:0] count
);

  // Your implementation here

endmodule