module axis_mux #(
  parameter integer C_AXIS_DATA_WIDTH  = 32,
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
  input  wire [NUM_INPUTS*(C_AXIS_DATA_WIDTH/8)-1:0] s_axis_tkeep,
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

  //-------------------------------------------------------------------------
  // Internal signal declarations
  //-------------------------------------------------------------------------

  // Registered version of the selection signal
  reg [$clog2(NUM_INPUTS)-1:0] sel_reg;

  // Wires for the selected input stream signals
  wire [C_AXIS_DATA_WIDTH-1:0] sel_tdata;
  wire [C_AXIS_DATA_WIDTH/8-1:0] sel_tkeep;
  wire sel_tvalid;
  wire sel_tlast;
  wire [C_AXIS_TID_WIDTH-1:0] sel_tid;
  wire [C_AXIS_TDEST_WIDTH-1:0] sel_tdest;
  wire [C_AXIS_TUSER_WIDTH-1:0] sel_tuser;

  // Registered output stage signals
  reg  m_axis_tvalid_reg;
  reg  [C_AXIS_DATA_WIDTH-1:0] m_axis_tdata_reg;
  reg  [C_AXIS_DATA_WIDTH/8-1:0] m_axis_tkeep_reg;
  reg  m_axis_tlast_reg;
  reg  [C_AXIS_TID_WIDTH-1:0] m_axis_tid_reg;
  reg  [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest_reg;
  reg  [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_reg;

  //-------------------------------------------------------------------------
  // Generate selected input signals from the concatenated buses
  //-------------------------------------------------------------------------
  assign sel_tdata  = s_axis_tdata [sel_reg*C_AXIS_DATA_WIDTH +: C_AXIS_DATA_WIDTH];
  assign sel_tkeep  = s_axis_tkeep [sel_reg*(C_AXIS_DATA_WIDTH/8) +: (C_AXIS_DATA_WIDTH/8)];
  assign sel_tvalid = s_axis_tvalid[sel_reg];
  assign sel_tlast  = s_axis_tlast [sel_reg];
  assign sel_tid    = s_axis_tid   [sel_reg*C_AXIS_TID_WIDTH +: C_AXIS_TID_WIDTH];
  assign sel_tdest  = s_axis_tdest [sel_reg*C_AXIS_TDEST_WIDTH +: C_AXIS_TDEST_WIDTH];
  assign sel_tuser  = s_axis_tuser [sel_reg*C_AXIS_TUSER_WIDTH +: C_AXIS_TUSER_WIDTH];

  //-------------------------------------------------------------------------
  // Register the selection signal
  //-------------------------------------------------------------------------
  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn)
      sel_reg <= 0;
    else
      sel_reg <= sel;
  end

  //-------------------------------------------------------------------------
  // Registered output stage: capture selected input and handle backpressure
  //-------------------------------------------------------------------------
  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      m_axis_tvalid_reg  <= 1'b0;
      m_axis_tdata_reg   <= {C_AXIS_DATA_WIDTH{1'b0}};
      m_axis_tkeep_reg   <= {C_AXIS_DATA_WIDTH/8{1'b0}};
      m_axis_tlast_reg   <= 1'b0;
      m_axis_tid_reg     <= {C_AXIS_TID_WIDTH{1'b0}};
      m_axis_tdest_reg   <= {C_AXIS_TDEST_WIDTH{1'b0}};
      m_axis_tuser_reg   <= {C_AXIS_TUSER_WIDTH{1'b0}};
    end
    else begin
      if (m_axis_tready) begin
        // When the output is ready, capture new data from the selected input.
        m_axis_tvalid_reg  <= sel_tvalid;
        m_axis_tdata_reg   <= sel_tdata;
        m_axis_tkeep_reg   <= sel_tkeep;
        m_axis_tlast_reg   <= sel_tlast;
        m_axis_tid_reg     <= sel_tid;
        m_axis_tdest_reg   <= sel_tdest;
        m_axis_tuser_reg   <= sel_tuser;
      end
      else begin
        // Hold the captured data; if the selected input de-asserts valid, clear our valid.
        if (!sel_tvalid)
          m_axis_tvalid_reg <= 1'b0;
        else
          m_axis_tvalid_reg <= m_axis_tvalid_reg;
          
        // Hold other signals
        m_axis_tdata_reg   <= m_axis_tdata_reg;
        m_axis_tkeep_reg   <= m_axis_tkeep_reg;
        m_axis_tlast_reg   <= m_axis_tlast_reg;
        m_axis_tid_reg     <= m_axis_tid_reg;
        m_axis_tdest_reg   <= m_axis_tdest_reg;
        m_axis_tuser_reg   <= m_axis_tuser_reg;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Drive the output interface signals
  //-------------------------------------------------------------------------
  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata  = m_axis_tdata_reg;
  assign m_axis_tkeep  = m_axis_tkeep_reg;
  assign m_axis_tlast  = m_axis_tlast_reg;
  assign m_axis_tid    = m_axis_tid_reg;
  assign m_axis_tdest  = m_axis_tdest_reg;
  assign m_axis_tuser  = m_axis_tuser_reg;

  //-------------------------------------------------------------------------
  // Generate ready signals for each input stream.
  // Only the selected input is driven by m_axis_tready; all others get a high ready.
  //-------------------------------------------------------------------------
  genvar i;
  generate
    for (i = 0; i < NUM_INPUTS; i = i + 1) begin : gen_s_axis_tready
      assign s_axis_tready[i] = (sel_reg == i) ? m_axis_tready : 1'b1;
    end
  endgenerate

endmodule