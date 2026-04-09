module axis_mux #(
  parameter integer C_AXIS_DATA_WIDTH = 32,
  parameter integer C_AXIS_TUSER_WIDTH = 4,
  parameter integer C_AXIS_TID_WIDTH   = 2,
  parameter integer C_AXIS_TDEST_WIDTH = 2,
  parameter integer NUM_INPUTS         = 4
)(
  input  wire                                   aclk,
  input  wire                                   aresetn,
  input  wire [$clog2(NUM_INPUTS)-1:0]          sel,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tvalid,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tready,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0]   s_axis_tdata,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tlast,
  input  wire [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0] s_axis_tid,
  input  wire [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
  input  wire [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
  output wire                                   m_axis_tvalid,
  output wire [C_AXIS_DATA_WIDTH-1:0]           m_axis_tdata,
  output wire [C_AXIS_DATA_WIDTH/8-1:0]         m_axis_tkeep,
  output wire                                   m_axis_tlast,
  output wire [C_AXIS_TID_WIDTH-1:0]            m_axis_tid,
  output wire [C_AXIS_TDEST_WIDTH-1:0]          m_axis_tdest,
  output wire [C_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser,
  output wire                                   m_axis_tready
);

// Register to hold the selected input index
integer sel_reg = 0;

// Select input based on sel
if (sel < 0 || sel >= NUM_INPUTS) begin
  // No valid input selected
  m_axis_tvalid = 0;
  m_axis_tready = 0;
  m_axis_tdata = 0;
  m_axis_tkeep = 0;
  m_axis_tlast = 0;
  m_axis_tid = 0;
  m_axis_tdest = 0;
  m_axis_tuser = 0;
  return;
end

if (s_axis_tvalid[sel] == 1) begin
  // Selected input is valid
  m_axis_tvalid = 1;
  m_axis_tready = 1;
  m_axis_tdata = s_axis_tdata[sel * C_AXIS_DATA_WIDTH: (sel * C_AXIS_DATA_WIDTH) + C_AXIS_DATA_WIDTH - 1];
  m_axis_tkeep = s_axis_tkeep[sel * C_AXIS_DATA_WIDTH/8: (sel * C_AXIS_DATA_WIDTH/8) + C_AXIS_DATA_WIDTH/8 - 1];
  m_axis_tlast = s_axis_tlast[sel];
  m_axis_tid = s_axis_tid[sel * C_AXIS_TID_WIDTH: (sel * C_AXIS_TID_WIDTH) + C_AXIS_TID_WIDTH - 1];
  m_axis_tdest = s_axis_tdest[sel * C_AXIS_TDEST_WIDTH: (sel * C_AXIS_TDEST_WIDTH) + C_AXIS_TDEST_WIDTH - 1];
  m_axis_tuser = s_axis_tuser[sel * C_AXIS_TUSER_WIDTH: (sel * C_AXIS_TUSER_WIDTH) + C_AXIS_TUSER_WIDTH - 1];
end

// If no input is valid, set all outputs to 0
if (m_axis_tvalid == 0) begin
  m_axis_tready = 0;
  m_axis_tdata = 0;
  m_axis_tkeep = 0;
  m_axis_tlast = 0;
  m_axis_tid = 0;
  m_axis_tdest = 0;
  m_axis_tuser = 0;
end

endmodule