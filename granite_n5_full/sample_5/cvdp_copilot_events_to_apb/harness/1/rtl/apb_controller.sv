module apb_controller #(
  parameter int unsigned ADDR_WIDTH = 32
) (
  input logic clk,
  input logic reset_n,

  input logic select_a_i,
  input logic select_b_i,
  input logic select_c_i,
  input logic [ADDR_WIDTH-1:0] addr_a_i,
  input logic [ADDR_WIDTH-1:0] addr_b_i,
  input logic [ADDR_WIDTH-1:0] addr_c_i,
  input logic [31:0] data_a_i,
  input logic [31:0] data_b_i,
  input logic [31:0] data_c_i,

  output logic apb_psel_o,
  output logic apb_penable_o,
  output logic apb_pwrite_o,
  output logic [ADDR_WIDTH-1:0] apb_paddr_o,
  output logic [31:0] apb_pwdata_o,

  input logic apb_pready_i
);

  // Your implementation goes here

endmodule