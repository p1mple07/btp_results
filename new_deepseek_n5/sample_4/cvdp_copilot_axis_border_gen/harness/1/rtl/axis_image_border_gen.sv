`timescale 1ps / 1ps

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

    // FSM State Definitions
    enum states begin
        ST_IDLE,
        ST_ROW_FIRST,
        ST_PROCESS_ROW,
        ST_BORDER_ROW,
        ST_ROW_LAST
    end

    // Internal Control Signals
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border  = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

    // FSM and Counter Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state = ST_IDLE;
            next_state = ST_IDLE;
        else begin
            case (state)
                ST_IDLE:
                    if (s_axis_tuser) begin
                        state = ST_ROW_FIRST;
                        next_state = ST_ROW_FIRST;
                    end else begin
                        state = ST_IDLE;
                        next_state = ST_IDLE;
                    end
                ST_ROW_FIRST:
                    if (s_axis_tlast) begin
                        state = ST_ROW_FIRST;
                        next_state = ST_ROW_FIRST;
                    else begin
                        state = ST_PROCESS_ROW;
                        next_state = ST_PROCESS_ROW;
                    end
                ST_PROCESS_ROW:
                    if (s_axis_tlast) begin
                        state = ST(Border_ROW);
                        next_state = ST_BORDER_ROW;
                    else begin
                        state = ST_PROCESS_ROW;
                        next_state = ST_PROCESS_ROW;
                    end
                ST_BORDER_ROW:
                    if (s_axis_tlast) begin
                        state = ST_ROW_LAST;
                        next_state = ST_ROW_LAST;
                    else begin
                        state = ST(Border_ROW);
                        next_state = ST(Border_ROW);
                    end
                ST_ROW_LAST:
                    if (s_axis_tuser) begin
                        state = ST_IDLE;
                        next_state = ST_IDLE;
                    else begin
                        state = ST_ROW_LAST;
                        next_state = ST_ROW_LAST;
                    end
            endcase
        end
    end

    // Border generation logic
    always @(posedge clk or negedge resetn) begin
        if (border_valid) begin
            s_axis_tdata[15:0] =:border_color;
            m_axis_tvalid = 1;
        else begin
            s_axis_tdata[15:0] = s_axis_tdata[15:0] & ~data_mask;
            m_axis_tvalid = s_axis_tvalid;
        end
    end

    // AXI Stream protocol handling
    always begin
        if (s_axis_tvalid) begin
            m_axis_tready = 1;
            m_axis_tlast = 0;
        end else begin
            m_axis_tready = 0;
            m_axis_tlast = 0;
        end
    end

    // State transitions and initialization
    initial begin
        state = ST_IDLE;
        next_state = ST_IDLE;
        x_count = 0;
        y_count = 0;
        border_valid = 0;
    end

    // Finalization
    always begin
        if (resetn) begin
            $finish();
        end
    end