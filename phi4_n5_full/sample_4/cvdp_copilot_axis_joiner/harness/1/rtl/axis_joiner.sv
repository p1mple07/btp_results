// File: rtl/axis_joiner.sv
module axis_joiner (
  input  clk,
  input  rst,
  // AXI Stream input 1
  input  [7:0] s_axis_tdata_1,
  input         s_axis_tvalid_1,
  output        s_axis_tready_1,
  input         s_axis_tlast_1,
  // AXI Stream input 2