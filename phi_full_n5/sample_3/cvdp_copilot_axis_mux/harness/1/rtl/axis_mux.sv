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

  logic [NUM_INPUTS-1:0] in_tvalid, in_tdata, in_tkeep, in_tlast, in_tid, in_tdest, in_tuser;
  logic [C_AXIS_DATA_WIDTH/8-1:0] in_tkeep_int;
  logic [1:0] frame_reg, ready_mask_reg;
  logic [NUM_INPUTS-1:0] out_tvalid, out_tready;

  // Internal signals for selection and flow control
  logic [$clog2(NUM_INPUTS)-1:0] sel_reg;

  // Initialize selection register
  assign sel_reg = sel;

  // Internal transfer logic
  always @(posedge aclk or negedge aresetn) begin
    if (!aresetn) begin
      sel_reg <= 0;
      in_tvalid <= 0;
      out_tvalid <= 0;
      out_tready <= 0;
      in_tdata <= 0;
      in_tkeep_int <= 0;
      in_tlast <= 0;
      in_tid <= 0;
      in_tdest <= 0;
      in_tuser <= 0;
    end else if (frame_reg == 1) begin
      sel_reg <= sel;
      frame_reg <= 0;

      // Select input based on sel
      case (sel_reg)
        4'b0000: in_tvalid = s_axis_tvalid[0];
        4'b0001: in_tvalid = s_axis_tvalid[1];
        4'b0010: in_tvalid = s_axis_tvalid[2];
        4'b0011: in_tvalid = s_axis_tvalid[3];
        default: in_tvalid = 0;
      endcase

      in_tdata = s_axis_tdata;
      in_tkeep_int = s_axis_tkeep;
      in_tlast = s_axis_tlast;
      in_tid = s_axis_tid;
      in_tdest = s_axis_tdest;
      in_tuser = s_axis_tuser;
    end

    // Output logic
    if (in_tvalid) begin
      out_tvalid <= in_tvalid;
      out_tready <= s_axis_tready;
      m_axis_tvalid <= out_tvalid;
      m_axis_tdata <= in_tdata;
      m_axis_tkeep <= in_tkeep_int;
      m_axis_tlast <= in_tlast;
      m_axis_tid <= in_tid;
      m_axis_tdest <= in_tdest;
      m_axis_tuser <= in_tuser;
    end else begin
      out_tvalid <= 0;
      out_tready <= 0;
      m_axis_tvalid <= 0;
    end
  end

  // Flow control logic
  always @(posedge aclk or negedge aclk) begin
    if (!aresetn) begin
      ready_mask_reg = 0;
    end else if (in_tvalid) begin
      // Propagate ready signal to output
      case (sel_reg)
        4'b0000: ready_mask_reg = s_axis_tready[0];
        4'b0001: ready_mask_reg = s_axis_tready[1];
        4'b0010: ready_mask_reg = s_axis_tready[2];
        4'b0011: ready_mask_reg = s_axis_tready[3];
        default: ready_mask_reg = 0;
      endcase
    end

    // Update frame register
    if (in_tvalid) begin
      frame_reg <= 1;
    end else begin
      frame_reg <= 0;
    end
  end

endmodule
