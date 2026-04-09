module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,
    parameter IMG_HEIGHT = 256,
    parameter BORDER_COLOR = 16'hFFFF,
    parameter DATA_MASK    = 16'h0000
)(
    input  wire            clk,
    input  wire            resetn,
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    input  wire            m_axis_tready,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser
);

    // State and Counter Registers
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;
    reg border_valid;

    // FSM and Control Signals
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state = ST_IDLE;
            next_state = ST_IDLE;
        else begin
            case (state)
                ST_IDLE: begin
                    if (s_axis_tuser) begin
                        state = ST_ROW_FIRST;
                        y_count = 0;
                    end
                end
                ST_ROW_FIRST: begin
                    if (x_count == IMG_WIDTH) begin
                        state = ST_PROCESS_ROW;
                        y_count = y_count + 1;
                    end
                    x_count = x_count + 1;
                end
                ST_PROCESS_ROW: begin
                    if (x_count == IMG_WIDTH) begin
                        state = ST_BORDER_ROW;
                        y_count = y_count + 1;
                    end
                    border_valid = (is_top_row || is_bottom_row || is_left_border || is_right_border);
                    if (border_valid) begin
                        m_axis_tdata = BORDER_COLOR;
                    else begin
                        m_axis_tdata = s_axis_tdata & DATA_MASK;
                    end
                    x_count = x_count + 1;
                end
                ST_BORDER_ROW: begin
                    if (y_count == IMG_HEIGHT) begin
                        state = ST_ROW_LAST;
                        y_count = y_count + 1;
                    end
                    border_valid = (is_top_row || is_bottom_row || is_left_border || is_right_border);
                    if (border_valid) begin
                        m_axis_tdata = BORDER_COLOR;
                    else begin
                        m_axis_tdata = s_axis_tdata & DATA_MASK;
                    end
                    x_count = x_count + 1;
                end
                ST_ROW_LAST: begin
                    if (s_axis_tlast) begin
                        state = ST_IDLE;
                        y_count = 0;
                    end
                    m_axis_tdata = s_axis_tdata & DATA_MASK;
                end
            end
            state = next_state;
        end
    end

    // State Definitions
    // ST_IDLE: Wait for frame start
    // ST_ROW_FIRST: Process first row with top border
    // ST_PROCESS_ROW: Process middle rows with left and right borders
    // ST_BORDER_ROW: Process bottom row with bottom border
    // ST_ROW_LAST: Complete processing and transition back to idle

    // Edge conditions
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border  = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

    // Output data valid handling
    wire m_axis_tvalid;

    // Additional logic for AXI Stream protocol
    // (Assumes standard AXI Stream protocol constraints and proper tvalid/tready handling)

endmodule