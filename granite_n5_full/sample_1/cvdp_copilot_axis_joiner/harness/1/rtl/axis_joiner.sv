module axis_joiner(
  // Clock and Reset
  input logic clk,
  input logic rst,

  // AXI Stream Interface 1
  input logic [7:0] s_axis_tdata_1,
  input logic s_axis_tvalid_1,
  output logic s_axis_tready_1,
  input logic s_axis_tlast_1,

  // AXI Stream Interface 2
  input logic [7:0] s_axis_tdata_2,
  input logic s_axis_tvalid_2,
  output logic s_axis_tready_2,
  input logic s_axis_tlast_2,

  // AXI Stream Interface 3
  input logic [7:0] s_axis_tdata_3,
  input logic s_axis_tvalid_3,
  output logic s_axis_tready_3,
  input logic s_axis_tlast_3,

  // AXI Stream Interface 4
  output logic [7:0] m_axis_tdata,
  output logic m_axis_tvalid,
  input logic m_axis_tready,
  output logic m_axis_tlast,
  output logic [1:0] m_axis_tuser
);

  // Your implementation here

endmodule