module axis_image_border_gen_with_resizer #(
    parameter IMG_WIDTH_IN  = 640,          // Input image width
    parameter IMG_HEIGHT_IN = 480,          // Input image height
    parameter IMG_WIDTH_OUT = 320,          // Resized image width
    parameter IMG_HEIGHT_OUT = 240,         // Resized image height
    parameter BORDER_COLOR  = 16'hFFFF,     // Border pixel color
    parameter DATA_WIDTH    = 16            // Pixel data width
)(
    input  wire                clk,          // Clock signal
    input  wire                resetn,       // Active-low reset
    input  wire [DATA_WIDTH-1:0] s_axis_tdata, // Input pixel data
    input  wire                s_axis_tvalid, // Input valid signal
    output wire                s_axis_tready, // Input ready signal
    input  wire                s_axis_tlast,  // Input end-of-row signal
    input  wire                s_axis_tuser,  // Input start-of-frame signal
    output wire [DATA_WIDTH-1:0] m_axis_tdata, // Output pixel data
    output wire                m_axis_tvalid, // Output valid signal
    input  wire                m_axis_tready, // Output ready signal
    output wire                m_axis_tlast,  // Output end-of-row signal
    output wire                m_axis_tuser   // Output start-of-frame signal
);

    // Internal connection between resizer and border generator
    wire [DATA_WIDTH-1:0] resizer_tdata;
    wire resizer_tvalid;
    wire resizer_tready;
    wire resizer_tlast;
    wire resizer_tuser;

    // Instantiate the image resizer
    axis_image_resizer #(
        .IMG_WIDTH_IN(IMG_WIDTH_IN),
        .IMG_HEIGHT_IN(IMG_HEIGHT_IN),
        .IMG_WIDTH_OUT(IMG_WIDTH_OUT),
        .IMG_HEIGHT_OUT(IMG_HEIGHT_OUT),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_resizer (
        .clk(clk),
        .resetn(resetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready), // Connect top-level ready to resizer
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tuser(s_axis_tuser),
        .m_axis_tdata(resizer_tdata),
        .m_axis_tvalid(resizer_tvalid),
        .m_axis_tready(resizer_tready), // Connected to border generator
        .m_axis_tlast(resizer_tlast),
        .m_axis_tuser(resizer_tuser)
    );

    // Instantiate the border generator
    axis_image_border_gen #(
        .IMG_WIDTH(IMG_WIDTH_OUT),        // Use resized image width
        .IMG_HEIGHT(IMG_HEIGHT_OUT),       // Use resized image height
        .BORDER_COLOR(BORDER_COLOR),
        .DATA_MASK(16'h0000)
    ) u_border (
        .clk(clk),
        .resetn(resetn),
        .s_axis_tdata(resizer_tdata),
        .s_axis_tvalid(resizer_tvalid),
        .s_axis_tready(resizer_tready), // Connect to resizer's ready
        .s_axis_tlast(resizer_tlast),
        .s_axis_tuser(resizer_tuser),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser)
    );

endmodule
