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

// Internal registers
reg [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] in_data;
reg [NUM_INPUTS*C_AXIS_DATA_WIDTH-1:0] out_data;
reg [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] out_keep;
reg [NUM_INPUTS*C_AXIS_DATA_WIDTH/8-1:0] out_temp;
reg [NUM_INPUTS-1:0] in_valid;
reg [NUM_INPUTS-1:0] in_ready;
reg [NUM_INPUTS-1:0] in_last;
reg [NUM_INPUTS-1:0] in_tid;
reg [NUM_INPUTS-1:0] in_tdest;
reg [NUM_INPUTS-1:0] in_tuser;
wire sel_selected;
wire frame_active;
wire ready_mask;

always @(posedge aclk or posedge aresetn) begin
    if (aresetn) begin
        // Reset all internal registers
        sel_selected <= 0;
        frame_active <= 0;
        in_valid <= 0;
        in_ready <= 1;
        in_last <= 0;
        in_tid <= 0;
        in_tdest <= 0;
        in_tuser <= 0;
        out_data <= 0;
        out_keep <= 0;
        out_temp <= 0;
        out_last <= 0;
        out_tid <= 0;
        out_tdest <= 0;
        out_tuser <= 0;
    end else begin
        // Check if sel is valid
        if (sel != 0 && sel < NUM_INPUTS) begin
            sel_selected <= sel;
            // Copy data from selected input
            in_data <= s_axis_tdata[sel*C_AXIS_DATA_WIDTH : (sel+1)*C_AXIS_DATA_WIDTH];
            // Compute output data
            out_data = in_data;
            // Enable output ready
            m_axis_tready <= 1;
        end else
            // No valid input, set outputs to 0
            m_axis_tvalid <= 0;
            m_axis_tready <= 0;
            m_axis_tdata <= 0;
            m_axis_tkeep <= 0;
            m_axis_tlast <= 0;
            m_axis_tid <= 0;
            m_axis_tdest <= 0;
            m_axis_tuser <= 0;
    end
end

// Assign output signals
assign m_axis_tvalid = sel_selected && in_valid;
assign m_axis_tready = sel_selected && (in_ready && (out_data[C_AXIS_DATA_WIDTH-1:0] != 0));
// This is simplistic. We need to consider actual packet framing.

endmodule
