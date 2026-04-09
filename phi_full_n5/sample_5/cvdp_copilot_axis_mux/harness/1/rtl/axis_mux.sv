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
  reg      sel_reg [$clog2(NUM_INPUTS)-1:0];
  reg      frame_reg;
  reg      ready_mask_reg [NUM_INPUTS-1:0];
  wire     in_tdata [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0];
  wire     in_tkeep [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0];
  wire     in_tlast [NUM_INPUTS-1:0];
  wire     in_tvalid [NUM_INPUTS-1:0];
  wire     in_tuser [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0];

  // Internal data and keep signals
  reg      axis_tdata_int [C_AXIS_DATA_WIDTH-1:0];
  reg      axis_tkeep_int [C_AXIS_DATA_WIDTH/8-1:0];
  reg      axis_tlast_int;
  reg      axis_tvalid_int [NUM_INPUTS-1:0];

  // Temporary storage for flow control
  wire     temp_tdata [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0];
  wire     temp_tkeep [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0];
  wire     temp_tlast [NUM_INPUTS-1:0];
  wire     temp_tready [NUM_INPUTS-1:0];

  // Combinational logic for selection
  always @(posedge aclk) begin
    if (aresetn) begin
      sel_reg <= 0;
      frame_reg <= 0;
      ready_mask_reg <= {1'b0, NUM_INPUTS-1{1'b0};
      axis_tvalid_int <= {1'b0, NUM_INPUTS-1{1'b0}};
      axis_tdata_int <= {1'b0, NUM_INPUTS*C_AXIS_DATA_WIDTH-1{1'b0}};
      axis_tkeep_int <= {1'b0, NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1{1'b0}};
      axis_tlast_int <= 0;
    end else begin
      sel_reg <= sel;
      frame_reg <= 1;
      ready_mask_reg <= {1'b0, sel, NUM_INPUTS-2{1'b0}};
      axis_tvalid_int <= s_axis_tvalid[ready_mask_reg];
      axis_tdata_int <= {in_tdata, axis_tdata_int};
      axis_tkeep_int <= {in_tkeep, axis_tkeep_int};
      axis_tlast_int <= s_axis_tlast[ready_mask_reg];
    end
  end

  // Output logic
  assign m_axis_tvalid = axis_tvalid_int;
  assign m_axis_tready = (sel_reg == ready_mask_reg) | (frame_reg && m_axis_tready);
  assign m_axis_tdata = axis_tdata_int;
  assign m_axis_tkeep = axis_tkeep_int;
  assign m_axis_tlast = axis_tlast_int;
  assign m_axis_tid = s_axis_tid & {NUM_INPUTS-1{1'b0}};
  assign m_axis_tdest = s_axis_tdest & {NUM_INPUTS-1{1'b0}};
  assign m_axis_tuser = s_axis_tuser & {NUM_INPUTS*C_AXIS_TUSER_WIDTH-1{1'b0}};

  // Flow control logic
  always @(posedge aclk) begin
    if (aresetn) begin
      temp_tready <= 1'b0;
    end else begin
      temp_tready <= (sel_reg == ready_mask_reg) | (frame_reg && s_axis_tready);
    end
  end

  // Data transfer logic
  always @(posedge aclk) begin
    if (temp_tready) begin
      axis_tdata_int <= s_axis_tdata & {NUM_INPUTS-1{1'b0}};
      axis_tkeep_int <= s_axis_tkeep;
      axis_tlast_int <= s_axis_tlast[ready_mask_reg];
      in_tdata <= axis_tdata_int;
      in_tkeep <= axis_tkeep_int;
      in_tlast <= axis_tlast_int;
      in_tvalid <= s_axis_tvalid[ready_mask_reg];
      in_tuser <= s_axis_tuser;
    end
  end

endmodule
