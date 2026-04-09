module axis_mux #(
  parameter integer C_AXIS_DATA_WIDTH   = 32,
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

  //-------------------------------------------------------------------------
  // Internal registers to hold the selected input stream data
  //-------------------------------------------------------------------------
  reg [C_AXIS_DATA_WIDTH-1:0] data_reg;
  reg [C_AXIS_DATA_WIDTH/8-1:0] keep_reg;
  reg last_reg;
  reg [C_AXIS_TID_WIDTH-1:0] tid_reg;
  reg [C_AXIS_TDEST_WIDTH-1:0] tdest_reg;
  reg [C_AXIS_TUSER_WIDTH-1:0] tuser_reg;
  reg valid_reg;

  //-------------------------------------------------------------------------
  // s_axis_tready: Only the selected input gets the master ready signal.
  // All other inputs receive 0.
  //-------------------------------------------------------------------------
  assign s_axis_tready = (m_axis_tready) ? (1 << $unsigned(sel)) : '0;

  //-------------------------------------------------------------------------
  // Main data capture and flow control logic.
  //
  // On reset, all outputs are cleared.
  //
  // On each clock:
  //   - Convert the selection signal 'sel' to an integer index.
  //   - If the selected input is valid, then if the master (m_axis_tready)
  //     is ready, capture the data from the selected input.
  //   - If the master is not ready, hold the current data.
  //   - If the selected input is not valid, clear the valid flag.
  //-------------------------------------------------------------------------
  always_ff @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      valid_reg   <= 1'b0;
      data_reg    <= {C_AXIS_DATA_WIDTH{1'b0}};
      keep_reg    <= {C_AXIS_DATA_WIDTH/8{1'b0}};
      last_reg    <= 1'b0;
      tid_reg     <= {C_AXIS_TID_WIDTH{1'b0}};
      tdest_reg   <= {C_AXIS_TDEST_WIDTH{1'b0}};
      tuser_reg   <= {C_AXIS_TUSER_WIDTH{1'b0}};
    end else begin
      integer sel_int;
      sel_int = $unsigned(sel);
      
      // Check if the selected input stream is valid.
      if (s_axis_tvalid[sel_int]) begin
         // If the master is ready, capture the data from the selected input.
         if (m_axis_tready) begin
            valid_reg   <= 1'b1;
            data_reg    <= s_axis_tdata[sel_int*C_AXIS_DATA_WIDTH +: C_AXIS_DATA_WIDTH];
            keep_reg    <= s_axis_tkeep[sel_int*(C_AXIS_DATA_WIDTH/8) +: (C_AXIS_DATA_WIDTH/8)];
            last_reg    <= s_axis_tlast[sel_int];
            tid_reg     <= s_axis_tid[sel_int*C_AXIS_TID_WIDTH +: C_AXIS_TID_WIDTH];
            tdest_reg   <= s_axis_tdest[sel_int*C_AXIS_TDEST_WIDTH +: C_AXIS_TDEST_WIDTH];
            tuser_reg   <= s_axis_tuser[sel_int*C_AXIS_TUSER_WIDTH +: C_AXIS_TUSER_WIDTH];
         end
         // If master is not ready, hold the current data.
      end else begin
         // If the selected input is not valid, clear the valid flag.
         valid_reg <= 1'b0;
      end
    end
  end

  //-------------------------------------------------------------------------
  // Output assignments: Drive the master AXI Stream interface with the 
  // captured (or held) data from the selected input.
  //-------------------------------------------------------------------------
  assign m_axis_tvalid = valid_reg;
  assign m_axis_tdata  = data_reg;
  assign m_axis_tkeep  = keep_reg;
  assign m_axis_tlast  = last_reg;
  assign m_axis_tid    = tid_reg;
  assign m_axis_tdest  = tdest_reg;
  assign m_axis_tuser  = tuser_reg;

endmodule