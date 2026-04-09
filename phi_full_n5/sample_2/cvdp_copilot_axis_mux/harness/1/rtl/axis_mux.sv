`timescale 1ns/1ps

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

  // Internal signals
  reg [$clog2(NUM_INPUTS)-1:0] sel_reg;
  reg                      frame_reg;
  reg [NUM_INPUTS-1:0] ready_mask_reg;

  // Internal data and keep signals
  reg [C_AXIS_DATA_WIDTH-1:0] axis_tdata_int;
  reg [C_AXIS_DATA_WIDTH/8-1:0] axis_tkeep_int;
  reg                            axis_tlast_int;
  reg                            axis_tvalid_int;

  // Temporary storage for flow control
  reg [NUM_INPUTS-1:0] temp_tdata [NUM_INPUTS-1:0];
  reg [NUM_INPUTS-1:0] temp_tkeep [NUM_INPUTS-1:0];

  // Selection logic
  always @(posedge aclk) begin
    if (aresetn) begin
      sel_reg <= 0;
      temp_tdata <= 0;
      temp_tkeep <= 0;
      ready_mask_reg <= 0;
    end else begin
      sel_reg <= sel;
      temp_tdata <= s_axis_tvalid[sel] & s_axis_tdata;
      temp_tkeep <= s_axis_tkeep[sel];
      ready_mask_reg <= s_axis_tready[sel];
    end
  end

  // Output logic
  always @(posedge aclk) begin
    if (aresetn) begin
      m_axis_tvalid <= 0;
      m_axis_tdata <= 0;
      m_axis_tkeep <= 0;
      m_axis_tlast <= 0;
      m_axis_tid <= 0;
      m_axis_tdest <= 0;
      m_axis_tuser <= 0;
    end else begin
      m_axis_tvalid <= axis_tvalid_int & ready_mask_reg;
      m_axis_tdata <= axis_tdata_int;
      m_axis_tkeep <= axis_tkeep_int;
      m_axis_tlast <= axis_tlast_int;
      m_axis_tid <= axis_tid[NUM_INPUTS*C_AXIS_TID_WIDTH-NUM_INPUTS+sel];
      m_axis_tdest <= axis_tdest[NUM_INPUTS*C_AXIS_TDEST_WIDTH-NUM_INPUTS+sel];
      m_axis_tuser <= s_axis_tuser[NUM_INPUTS*C_AXIS_TUSER_WIDTH-NUM_INPUTS+sel];
    end
  end

  // Handling of selection
  always @(posedge aclk) begin
    if (sel_reg == sel) begin
      axis_tvalid_int <= s_axis_tvalid[sel];
      axis_tdata_int <= s_axis_tdata[NUM_INPUTS*C_AXIS_DATA_WIDTH-NUM_INPUTS+sel:C_AXIS_DATA_WIDTH-1];
      axis_tkeep_int <= s_axis_tkeep[sel];
      temp_tdata <= s_axis_tdata[NUM_INPUTS*C_AXIS_DATA_WIDTH-NUM_INPUTS+sel*C_AXIS_DATA_WIDTH-1:NUM_INPUTS*C_AXIS_DATA_WIDTH];
      temp_tkeep <= s_axis_tkeep[sel];
      ready_mask_reg <= s_axis_tready[sel];
    end else begin
      m_axis_tvalid <= 0;
      m_axis_tdata <= 0;
      m_axis_tkeep <= 0;
    end
  end

  // Flow control logic
  always @(posedge aclk) begin
    if (sel_reg == sel) begin
      if (ready_mask_reg) begin
        axis_tlast_int <= s_axis_tlast[sel];
        axis_tvalid_int <= (axis_tlast_int | axis_tvalid_int);
      end else begin
        axis_tvalid_int <= 0;
      end
    end
  end

endmodule
