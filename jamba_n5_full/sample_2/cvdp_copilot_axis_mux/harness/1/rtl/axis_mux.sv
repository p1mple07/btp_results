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

// Internal signals for selection and data forwarding
always @(posedge aclk) begin
    if (aresetn) begin
        m_axis_tvalid  <= 0;
        m_axis_tready  <= 0;
        m_axis_tdata    <= 0;
        m_axis_tkeep    <= 0;
        m_axis_tlast    <= 0;
        m_axis_tid      <= 0;
        m_axis_tdest    <= 0;
        m_axis_tuser    <= 0;
        return;
    end

    // Check if sel is valid
    if (sel < 0 || sel >= NUM_INPUTS) begin
        m_axis_tvalid  <= 0;
        m_axis_tready  <= 0;
        m_axis_tdata    <= 0;
        m_axis_tkeep    <= 0;
        m_axis_tlast    <= 0;
        m_axis_tid      <= 0;
        m_axis_tdest    <= 0;
        m_axis_tuser    <= 0;
        return;
    end

    // Select the active input
    s_axis_tvalid  <= s_axis_tvalid[sel];
    s_axis_tdata    <= s_axis_tdata[C_AXIS_DATA_WIDTH-1:0];
    s_axis_tkeep    <= s_axis_tkeep[C_AXIS_DATA_WIDTH/8-1:0];
    s_axis_tlast    <= s_axis_tlast[1];
    s_axis_tid      <= s_axis_tid[C_AXIS_TID_WIDTH-1:0];
    s_axis_tdest    <= s_axis_tdest[C_AXIS_TDEST_WIDTH-1:0];
    s_axis_tuser    <= s_axis_tuser[C_AXIS_TUSER_WIDTH-1:0];

    // Set output signals
    m_axis_tvalid  <= 1;
    m_axis_tready  <= 0;
    m_axis_tdata    <= s_axis_tdata;
    m_axis_tkeep    <= s_axis_tkeep;
    m_axis_tlast    <= 0;
    m_axis_tid      <= s_axis_tid;
    m_axis_tdest    <= s_axis_tdest;
    m_axis_tuser    <= s_axis_tuser;
end

// Handle reset condition
always @(posedge aclk) begin
    if (aresetn) begin
        // reset all outputs
        m_axis_tvalid  <= 0;
        m_axis_tready  <= 0;
        m_axis_tdata    <= 0;
        m_axis_tkeep    <= 0;
        m_axis_tlast    <= 0;
        m_axis_tid      <= 0;
        m_axis_tdest    <= 0;
        m_axis_tuser    <= 0;
        return;
    end
end

endmodule
