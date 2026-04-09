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
logic [NUM_INPUTS-1:0] sel_reg;
logic [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] tdata_in;
logic [C_AXIS_DATA_WIDTH/8-1:0] tkeep_in;
logic [NUM_INPUTS-1:0] tid_in;
logic [NUM_INPUTS*C_AXIS_TDEST_WIDTH-1:0] tdest_in;
logic [NUM_INPUTS*C_AXIS_TUSER_WIDTH-1:0] tuser_in;
logic frame_reg;
logic ready_mask_reg;

initial begin
    // Initialize internal registers
    sel_reg = 0;
    tdata_in = 0;
    tkeep_in = 0;
    tid_in = 0;
    tdest_in = 0;
    tuser_in = 0;
    frame_reg = 0;
    ready_mask_reg = 0;
end

always @(posedge aclock or negedge aresetn) begin
    if (aresetn) begin
        // Reset everything
        sel_reg = 0;
        tdata_in = 0;
        tkeep_in = 0;
        tid_in = 0;
        tdest_in = 0;
        tuser_in = 0;
        frame_reg = 0;
        ready_mask_reg = 0;
        m_axis_tvalid = 0;
        m_axis_tready = 0;
        m_axis_tdata = 0;
        m_axis_tkeep = 0;
        m_axis_tlast = 0;
        m_axis_tid = 0;
        m_axis_tdest = 0;
        m_axis_tuser = 0;
    end else begin
        // Process inputs
        if (sel != 0) begin
            if (s_axis_tvalid[sel]) begin
                tdata_in = s_axis_tdata[sel];
                tkeep_in = s_axis_tkeep[sel];
                tid_in = s_axis_tid[sel];
                tdest_in = s_axis_tdest[sel];
                tuser_in = s_axis_tuser[sel];
                s_axis_tready[sel] = 1;
            end else
                tdata_in = tdata_in[0];
        end else
            tdata_in = tdata_in[0];

        // Forward data to output
        m_axis_tvalid = 1;
        m_axis_tdata = tdata_in;
        m_axis_tkeep = tkeep_in;
        m_axis_tlast = tlast_in;
        m_axis_tid = tid_in;
        m_axis_tdest = tdest_in;
        m_axis_tuser = tuser_in;

        // Check if any input ready? Not necessary for forwarding.
        // Just set tready to 1 for the selected input.
        s_axis_tready[sel] = 1;
    end
end

endmodule
