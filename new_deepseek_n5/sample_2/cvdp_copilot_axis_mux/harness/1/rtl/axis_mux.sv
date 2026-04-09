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
  output wire [C_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser
);

// Determine which input is active
integer active_input = (sel >> ($clog2(NUM_INPUTS)-1)) & (NUM_INPUTS-1);
wire [0:NUM_INPUTS-1] sel_reg;

always @* begin
  // If sel is out of bounds, all outputs are inactive
  if (sel >= NUM_INPUTS || sel < 0) begin
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

  // Extract signals from the active input
  wire [C_AXIS_DATA_WIDTH-1:0] tdata;
  wire [C_AXIS_DATA_WIDTH/8-1:0] tkeep;
  wire tid;
  wire tdest;
  wire tuser;

  always @*+1 begin
    tdata = s_axis_tdata[active_input * C_AXIS_DATA_WIDTH: (active_input * C_AXIS_DATA_WIDTH) + C_AXIS_DATA_WIDTH-1];
    tkeep = s_axis_tkeep[active_input * C_AXIS_DATA_WIDTH/8: (active_input * C_AXIS_DATA_WIDTH/8) + C_AXIS_DATA_WIDTH/8-1];
    tid = s_axis_tid[active_input * C_AXIS_TID_WIDTH: (active_input * C_AXIS_TID_WIDTH) + C_AXIS_TID_WIDTH-1];
    tdest = s_axis_tdest[active_input * C_AXIS_TDEST_WIDTH: (active_input * C_AXIS_TDEST_WIDTH) + C_AXIS_TDEST_WIDTH-1];
    tuser = s_axis_tuser[active_input * C_AXIS_TUSER_WIDTH: (active_input * C_AXIS_TUSER_WIDTH) + C_AXIS_TUSER_WIDTH-1];
  end

  // Output signals
  m_axis_tvalid = any(s_axis_tvalid);
  m_axis_tready = s_axis_tready[active_input];
  wire local_tready;
  wire [NUM_INPUTS-1:0] temp_tready;

  // Propagate backpressure
  always @*+1 begin
    local_tready = s_axis_tready[active_input];
    temp_tready[active_input] = local_tready;
    // Bubble backpressure
    for (integer i = active_input - 1; i >= 0; i--) begin
      temp_tready[i] = temp_tready[i+1];
    end
    m_axis_tready = temp_tready[0];
  end

  // Output data
  m_axis_tdata = tdata;
  m_axis_tkeep = tkeep;
  m_axis_tlast = tlast[active_input];
  m_axis_tid = tid;
  m_axis_tdest = tdest;
  m_axis_tuser = tuser;

endmodule