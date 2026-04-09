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
  output wire [NUM_INPUTS-1:0]                  s_axis_tready,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0]   s_axis_tdata,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tlast,
  input  wire [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0] s_axis_tid,
  input  wire [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
  input  wire [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
  output wire                                   m_axis_tvalid,
  input  wire                                   m_axis_tready,
  output wire [C_AXIS_DATA_WIDTH-1:0]           m_axis_tdata,
  output wire [C_AXIS_DATA_WIDTH/8-1:0]         m_axis_tkeep,
  output wire                                   m_axis_tlast,
  output wire [C_AXIS_TID_WIDTH-1:0]            m_axis_tid,
  output wire [C_AXIS_TDEST_WIDTH-1:0]          m_axis_tdest,
  output wire [C_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser
);

// Create input AXI streams for each input
for (int i = 0; i < NUM_INPUTS; i++) {
  wire [C_AXIS_DATA_WIDTH-1:0] tdata_i;
  wire [C_AXIS_DATA_WIDTH/8-1:0] tkeep_i;
  wire [C_AXIS_TID_WIDTH-1:0] tid_i;
  wire [C_AXIS_TDEST_WIDTH-1:0] tdest_i;
  wire [C_AXIS_TUSER_WIDTH-1:0] tuser_i;
  wire tvalid_i;

  // Create input AXI stream interface
  interface_axis_mux #(C_AXIS_DATA_WIDTH, C_AXIS_TID_WIDTH, C_AXIS_TDEST_WIDTH, C_AXIS_TUSER_WIDTH) 
    in_i (
      tvalid = s_axis_tvalid[i],
      tdata = s_axis_tdata[i * C_AXIS_DATA_WIDTH],
      tkeep = s_axis_tkeep[i * C_AXIS_DATA_WIDTH/8],
      tid = s_axis_tid[i * C_AXIS_TID_WIDTH],
      tdest = s_axis_tdest[i * C_AXIS_TDEST_WIDTH],
      tuser = s_axis_tuser[i * C_AXIS_TUSER_WIDTH],
      tvalid_i = tvalid_i,
      tdata_i = tdata_i,
      tkeep_i = tkeep_i,
      tid_i = tid_i,
      tdest_i = tdest_i,
      tuser_i = tuser_i
    );
}

// Select the appropriate input based on sel
wire [C_AXIS_DATA_WIDTH-1:0] m_axis_tdata;
wire [C_AXIS_DATA_WIDTH/8-1:0] m_axis_tkeep;
wire [C_AXIS_TID_WIDTH-1:0] m_axis_tid;
wire [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest;
wire [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser;
wire m_axis_tvalid;

sel = 0;
while (sel != (sel)) {
  sel = (sel >> 1);
}

m_axis_tvalid = s_axis_tvalid[sel];
m_axis_tready = s_axis_tready[sel];
m_axis_tdata = tdata_i[sel];
m_axis_tkeep = tkeep_i[sel];
m_axis_tid = tid_i[sel];
m_axis_tdest = tdest_i[sel];
m_axis_tuser = tuser_i[sel];

endmodule