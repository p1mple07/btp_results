module axis_mux #(
  parameter integer C_AXIS_DATA_WIDTH = 32,
  parameter integer C_AXIS_TUSER_WIDTH = 4,
  parameter integer C_AXIS_TID_WIDTH   = 2,
  parameter integer C_AXIS_TDEST_WIDTH = 2,
  parameter integer NUM_INPUTS         = 4
)(
  input  wire aclk,
  input  wire aresetn,
  input  wire [$clog2(NUM_INPUTS)-1:0] sel,
  input  wire [NUM_INPUTS-1:0] s_axis_tvalid,
  output wire [NUM_INPUTS-1:0] s_axis_tready,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] s_axis_tdata,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  wire [NUM_INPUTS-1:0] s_axis_tlast,
  input  wire [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0] s_axis_tid,
  input  wire [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] s_axis_tdest,
  input  wire [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
  output wire m_axis_tvalid,
  input  wire m_axis_tready,
  output wire [C_AXIS_DATA_WIDTH-1:0] m_axis_tdata,
  output wire [C_AXIS_DATA_WIDTH/8-1:0] m_axis_tkeep,
  output wire m_axis_tlast,
  output wire [C_AXIS_TID_WIDTH-1:0] m_axis_tid,
  output wire [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest,
  output wire [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser
);

  wire [NUM_INPUTS-1:0] in_tvalid;
  wire [NUM_INPUTS-1:0] in_tdata;
  wire [NUM_INPUTS-1:0] in_tkeep;
  wire [NUM_INPUTS-1:0] in_tlast;
  wire [NUM_INPUTS-1:0] in_tid;
  wire [NUM_INPUTS-1:0] in_tdest;
  wire [NUM_INPUTS-1:0] in_tuser;

  wire [C_AXIS_DATA_WIDTH-1:0] axis_tdata_int;
  wire [C_AXIS_DATA_WIDTH/8-1:0] axis_tkeep_int;
  wire [C_AXIS_TID_WIDTH-1:0] axis_tid_int;
  wire [C_AXIS_TDEST_WIDTH-1:0] axis_tdest_int;
  wire [C_AXIS_TUSER_WIDTH-1:0] axis_tuser_int;

  wire [NUM_INPUTS-1:0] frame_reg;
  wire [NUM_INPUTS-1:0] ready_mask_reg;

  integer log2_num_inputs = $clog2(NUM_INPUTS);

  always @* begin
    aresetn = 0;
    sel = 0;
    frame_reg = 0;
    ready_mask_reg = 0;
  end

  if (sel >= 0 && sel < NUM_INPUTS) begin
    in_tvalid = s_axis_tvalid[sel];
    in_tdata = s_axis_tdata[sel * C_AXIS_DATA_WIDTH : (sel + 1) * C_AXIS_DATA_WIDTH - 1];
    in_tkeep = s_axis_tkeep[sel];
    in_tlast = s_axis_tlast[sel];
    in_tid = s_axis_tid[sel * C_AXIS_TID_WIDTH : (sel + 1) * C_AXIS_TID_WIDTH - 1];
    in_tdest = s_axis_tdest[sel * C_AXIS_TDEST_WIDTH : (sel + 1) * C_AXIS_TDEST_WIDTH - 1];
    in_tuser = s_axis_tuser[sel * C_AXIS_TUSER_WIDTH : (sel + 1) * C_AXIS_TUSER_WIDTH - 1];

    axis_tdata_int = in_tdata;
    axis_tkeep_int = in_tkeep;
    axis_tid_int = in_tid;
    axis_tdest_int = in_tdest;
    axis_tuser_int = in_tuser;

    if (in_tvalid) begin
      m_axis_tvalid = 1;
      m_axis_tdata = axis_tdata_int;
      m_axis_tkeep = axis_tkeep_int;
      m_axis_tlast = in_tlast;
      m_axis_tid = axis_tid_int;
      m_axis_tdest = axis_tdest_int;
      m_axis_tuser = axis_tuser_int;
      frame_reg = 1;
    end else begin
      m_axis_tvalid = 0;
      frame_reg = 0;
    end
  end else begin
    m_axis_tvalid = 0;
    m_axis_tready = 0;
    frame_reg = 0;
  end

  // Cleanup logic
  always @*+10000000 #1ps begin
    if (frame_reg) begin
      frame_reg = 0;
      ready_mask_reg = 0;
    end
  end

endmodule