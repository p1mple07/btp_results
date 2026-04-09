module axis_image_resizer #(
    parameter IMG_WIDTH_IN  = 640,
    parameter IMG_HEIGHT_IN = 480,
    parameter IMG_WIDTH_OUT = 320,
    parameter IMG_HEIGHT_OUT = 240,
    parameter DATA_WIDTH    = 16
)
(
    input  wire                  clk,
    input  wire                  resetn,
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire                  s_axis_tvalid,
    output wire                  s_axis_tready,
    input  wire                  s_axis_tlast,
    input  wire                  s_axis_tuser,
    
    output reg [DATA_WIDTH-1:0]  m_axis_tdata,
    output reg                   m_axis_tvalid,
    input  wire                  m_axis_tready,
    output reg                   m_axis_tlast,
    output reg                   m_axis_tuser
);

    // Internal counters for input and output
    reg [15:0] x_count_in, y_count_in;
    reg [15:0] x_count_out, y_count_out;

    // Downsampling factors (assumes integer scaling factors)
    localparam X_SCALE = IMG_WIDTH_IN / IMG_WIDTH_OUT;
    localparam Y_SCALE = IMG_HEIGHT_IN / IMG_HEIGHT_OUT;

    // Control logic for input and output data
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            x_count_in   <= 0;
            y_count_in   <= 0;
            x_count_out  <= 0;
            y_count_out  <= 0;
            m_axis_tvalid <= 0;
            m_axis_tlast  <= 0;
            m_axis_tuser  <= 0;
            m_axis_tdata  <= 0;
        end else if (s_axis_tvalid && s_axis_tready) begin
            // Check if current pixel is on the downsampling grid
            if ((x_count_in % X_SCALE == 0) && (y_count_in % Y_SCALE == 0)) begin
                m_axis_tdata  <= s_axis_tdata;
                m_axis_tvalid <= 1;
                // End-of-row for output when reaching the last column
                if (x_count_in == IMG_WIDTH_IN - 1) begin
                    m_axis_tlast <= 1;
                end else begin
                    m_axis_tlast <= 0;
                end
                m_axis_tuser <= s_axis_tuser;
            end else begin
                // Not a downsampling position: do not pass pixel
                m_axis_tvalid <= 0;
                m_axis_tlast  <= 0;
                m_axis_tuser  <= s_axis_tuser;
            end

            // Increment input counters
            if (x_count_in < IMG_WIDTH_IN - 1) begin
                x_count_in <= x_count_in + 1;
            end else begin
                x_count_in <= 0;
                if (y_count_in < IMG_HEIGHT_IN - 1) begin
                    y_count_in <= y_count_in + 1;
                end else begin
                    y_count_in <= 0;
                end
            end
        end
    end

    // Ready signal generation: simple handshake
    assign s_axis_tready = m_axis_tready;

endmodule
