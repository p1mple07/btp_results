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
  reg                           frame_reg;
  reg [NUM_INPUTS-1:0]           ready_mask_reg;
  wire                           [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] in_tdata;
  wire                           [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] in_tkeep;
  wire                           [NUM_INPUTS-1:0]                   in_tvalid;
  wire                           [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] axis_tdata_int;
  wire                           [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] axis_tkeep_int;
  wire                           [NUM_INPUTS-1:0]                   axis_tlast_int;
  wire                           [1]                                axis_tvalid_int;

  // Internal buffer for flow control
  reg [NUM_INPUTS-1:0] temp_tvalid;
  reg [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] temp_tdata;
  reg [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] temp_tkeep;
  reg [NUM_INPUTS-1:0] temp_tlast;

  // Selection logic
  always @(posedge aclk) begin
    if (aresetn) begin
      sel_reg <= 0;
      temp_tvalid <= 0;
      temp_tdata <= {{1'b0}};
      temp_tkeep <= {1'b0};
      temp_tlast <= 0;
    end else begin
      sel_reg <= sel;
      temp_tvalid <= s_axis_tvalid;
      temp_tdata <= s_axis_tdata;
      temp_tkeep <= s_axis_tkeep;
      temp_tlast <= s_axis_tlast;
    end
  end

  // Output logic
  assign m_axis_tvalid = axis_tvalid_int;
  assign m_axis_tready = s_axis_tready | (m_axis_tvalid && !ready_mask_reg);
  assign m_axis_tdata = axis_tdata_int;
  assign m_axis_tkeep = axis_tkeep_int;
  assign m_axis_tlast = axis_tlast_int;
  assign m_axis_tid = s_axis_tid;
  assign m_axis_tdest = s_axis_tdest;
  assign m_axis_tuser = s_axis_tuser;

  // Flow control logic
  always @(posedge aclk) begin
    if (aresetn) begin
      ready_mask_reg <= {NUM_INPUTS{1'b0}};
    end else begin
      ready_mask_reg <= temp_tvalid;
      temp_tvalid <= temp_tvalid | (temp_tvalid && (sel_reg < NUM_INPUTS));
      axis_tdata_int <= {NUM_INPUTS{C_AXIS_DATA_WIDTH{1'b0}};
      axis_tkeep_int <= temp_tkeep;
      axis_tlast_int <= temp_tlast;
    end
  end

  // Buffering logic
  always @(posedge aclk) begin
    if (aresetn) begin
      temp_tdata <= {NUM_INPUTS{C_AXIS_DATA_WIDTH{1'b0}}};
      temp_tkeep <= {NUM_INPUTS{C_AXIS_DATA_WIDTH/8{1'b0}}};
      temp_tlast <= {NUM_INPUTS{1'b0}};
    end else begin
      if (sel_reg < NUM_INPUTS) begin
        temp_tdata <= s_axis_tdata[NUM_INPUTS*C_AXIS_DATA_WIDTH-NUM_INPUTS*C_AXIS_DATA_WIDTH:NUM_INPUTS*C_AXIS_DATA_WIDTH];
        temp_tkeep <= s_axis_tkeep[NUM_INPUTS*C_AXIS_DATA_WIDTH/8-NUM_INPUTS*C_AXIS_DATA_WIDTH/8:NUM_INPUTS*C_AXIS_DATA_WIDTH/8];
        temp_tlast <= s_axis_tlast[NUM_INPUTS-1];
      end
    end
  end

endmodule
