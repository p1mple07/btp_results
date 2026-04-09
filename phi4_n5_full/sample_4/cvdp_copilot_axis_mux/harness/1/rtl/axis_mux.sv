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
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] s_axis_tdata,
  input  wire [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] s_axis_tkeep,
  input  wire [NUM_INPUTS-1:0]                  s_axis_tlast,
  input  wire [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0]  s_axis_tid,
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
  // Generate s_axis_tready for each input
  // The selected input's ready is driven by m_axis_tready,
  // while all others are asserted as ready.
  //-------------------------------------------------------------------------
  genvar j;
  generate
    for(j = 0; j < NUM_INPUTS; j = j + 1) begin : gen_s_axis_tready
      assign s_axis_tready[j] = (j == sel) ? m_axis_tready : 1'b1;
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Internal registers for the output stream signals.
  // These registers capture the data from the selected input
  // when the downstream interface is ready.
  //-------------------------------------------------------------------------
  reg m_axis_tvalid_reg;
  reg [C_AXIS_DATA_WIDTH-1:0] m_axis_tdata_reg;
  reg [C_AXIS_DATA_WIDTH/8-1:0] m_axis_tkeep_reg;
  reg m_axis_tlast_reg;
  reg [C_AXIS_TID_WIDTH-1:0] m_axis_tid_reg;
  reg [C_AXIS_TDEST_WIDTH-1:0] m_axis_tdest_reg;
  reg [C_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_reg;

  integer k;
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      m_axis_tvalid_reg <= 1'b0;
      m_axis_tdata_reg  <= '0;
      m_axis_tkeep_reg  <= '0;
      m_axis_tlast_reg  <= 1'b0;
      m_axis_tid_reg    <= '0;
      m_axis_tdest_reg  <= '0;
      m_axis_tuser_reg  <= '0;
    end
    else begin
      if (m_axis_tready) begin
        // Default assignments for this cycle
        m_axis_tdata_reg  <= '0;
        m_axis_tkeep_reg  <= '0;
        m_axis_tid_reg    <= '0';
        m_axis_tdest_reg  <= '0';
        m_axis_tuser_reg  <= '0';
        m_axis_tlast_reg  <= 1'b0;
        m_axis_tvalid_reg <= 1'b0;

        // Loop through all inputs to select the active stream.
        // The selected input (where index == sel) is used to drive the outputs.
        for (k = 0; k < NUM_INPUTS; k = k + 1) begin
          if (k == sel) begin
            m_axis_tdata_reg  <= s_axis_tdata[(k+1)*C_AXIS_DATA_WIDTH-1 -: C_AXIS_DATA_WIDTH];
            m_axis_tkeep_reg  <= s_axis_tkeep[(k+1)*(C_AXIS_DATA_WIDTH/8)-1 -: C_AXIS_DATA_WIDTH/8];
            m_axis_tid_reg    <= s_axis_tid[(k+1)*C_AXIS_TID_WIDTH-1 -: C_AXIS_TID_WIDTH];
            m_axis_tdest_reg  <= s_axis_tdest[(k+1)*C_AXIS_TDEST_WIDTH-1 -: C_AXIS_TDEST_WIDTH];
            m_axis_tuser_reg  <= s_axis_tuser[(k+1)*C_AXIS_TUSER_WIDTH-1 -: C_AXIS_TUSER_WIDTH];
            m_axis_tlast_reg  <= s_axis_tlast[k];
            if (s_axis_tvalid[k])
              m_axis_tvalid_reg <= 1'b1;
            else
              m_axis_tvalid_reg <= 1'b0;
          end
        end
      end
      // If m_axis_tready is low, the registers hold the previous values.
    end
  end

  //-------------------------------------------------------------------------
  // Drive the registered output signals to the module outputs.
  //-------------------------------------------------------------------------
  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tdata  = m_axis_tdata_reg;
  assign m_axis_tkeep  = m_axis_tkeep_reg;
  assign m_axis_tlast  = m_axis_tlast_reg;
  assign m_axis_tid    = m_axis_tid_reg;
  assign m_axis_tdest  = m_axis_tdest_reg;
  assign m_axis_tuser  = m_axis_tuser_reg;

endmodule