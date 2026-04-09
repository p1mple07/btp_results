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

(* internal state registers *)
reg [NUM_INPUTS-1:0] sel_reg;
reg [NUM_INPUTS-1:0] frame_reg;
reg [NUM_INPUTS-1:0] ready_mask_reg;
reg [NUM_INPUTS-1:0] in_data;
reg [NUM_INPUTS-1:0] in_keep;
reg [NUM_INPUTS-1:0] in_last;
reg [NUM_INPUTS*C_AXIS_TID_WIDTH-1:0] tid;
reg [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] dest;
reg [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] user;

(* synchronisation gates *)
always @(posedge aclk or posedge aresetn) begin
    if (aresetn) begin
        sel_reg <= 0;
        frame_reg <= 0;
        ready_mask_reg <= 0;
        in_data <= 0;
        in_keep <= 0;
        in_last <= 0;
        tid <= 0;
        dest <= 0;
        user <= 0;
    end else begin
        if (sel != 0) begin
            sel_reg <= sel;
        end else begin
            sel_reg <= 0;
        end

        // output the selected stream
        m_axis_tvalid = sel_reg == 2'b01 ? 1 : 0;
        m_axis_tready = m_axis_tvalid;
        m_axis_tdata = in_data;
        m_axis_tkeep = in_keep;
        m_axis_tlast = in_last;
        m_axis_tid = tid;
        m_axis_tdest = dest;
        m_axis_tuser = user;
    end
end

endmodule
