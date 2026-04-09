module axis_rgb2ycbcr #(
    parameter PIXEL_WIDTH = 16,
    parameter FIFO_DEPTH = 16
)(
    input  wire            aclk,
    input  wire            aresetn,

    // AXI Stream Slave Interface (Input)
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    output wire            s_axis_tready,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,

    // AXI Stream Master Interface (Output)
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    input  wire            m_axis_tready,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser
);

    // -----------------------------
    // FIFO Buffer (16-depth buffer)
    // -----------------------------
    reg [15:0] fifo_data [0:FIFO_DEPTH-1];
    reg        fifo_tlast [0:FIFO_DEPTH-1];
    reg        fifo_tuser [0:FIFO_DEPTH-1];

    reg [3:0]  write_ptr, read_ptr; // 4-bit pointers for FIFO
    reg        full;
    wire       empty;

    // -----------------------------
    // AXI-Stream Input Signals
    // -----------------------------
    wire [7:0]   r, g, b;
    
    always @(posedge aclk) begin
        if (!aresetn) begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
    end

    // -----------------------------
    // AXI-Stream Output Signals
    // -----------------------------
    wire [7:0]   r;
    wire [7:0]   g;
    wire [7:0]   b;
    
    always @(posedge aclk) begin
        if (!aresetn) begin
            r <= 0;
            g <= 0;
            b <= 0;
        end
    end

endmodule