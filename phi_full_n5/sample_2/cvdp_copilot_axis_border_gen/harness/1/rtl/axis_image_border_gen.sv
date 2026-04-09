`timescale 1ps / 1ps

module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,               // Image width (X resolution)
    parameter IMG_HEIGHT = 256,              // Image height (Y resolution)
    parameter BORDER_COLOR = 16'hFFFF,       // Border pixel value
    parameter DATA_MASK    = 16'h0000        // Mask for input pixels
)(
    input  wire            clk,              // AXI clock
    input  wire            resetn,           // Active-low reset

    // AXI Stream input interface
    input  wire [15:0]     s_axis_tdata,     // Input stream data
    input  wire            s_axis_tvalid,    // Input data valid
    output wire            s_axis_tready,    // Output ready
    output wire            s_axis_tlast,     // Input last signal
    input  wire            s_axis_tuser,     // Frame start signal

    // AXI Stream output interface
    output wire [15:0]     m_axis_tdata,     // Output stream data
    output wire            m_axis_tvalid,    // Output data valid
    input  wire            m_axis_tready,    // Input ready
    output wire            m_axis_tlast,     // Output last signal
    output wire            m_axis_tuser      // Frame start signal
);

   // Add state definitions

    // State and Counter Registers
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;
    reg border_valid;


    // Internal Control Signals
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border  = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

   // Add logic for AXIS output signals

    // FSM and Counter Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= ST_IDLE;
            x_count <= 0;
            y_count <= 0;
            border_valid <= 0;
            m_axis_tuser <= 0;
        end else begin
            state <= next_state;
        end
    end

    // Define states
    localparam ST_IDLE = 3'b000;
    localparam ST_ROW_FIRST = 3'b001;
    localparam ST_PROCESS_ROW = 3'b010;
    localparam ST_BORDER_ROW = 3'b011;
    localparam ST_ROW_LAST = 3'b100;

    // FSM logic
    always @(posedge clk, negedge resetn) begin
        case (state)
            ST_IDLE:
                if (s_axis_tuser) begin
                    state <= ST_ROW_FIRST;
                    x_count <= 16'd0;
                end
            ST_ROW_FIRST:
                if (s_axis_tvalid && !s_axis_tlast) begin
                    if (x_count == 0) begin
                        state <= ST_PROCESS_ROW;
                        y_count <= y_count + 1;
                    end
                    x_count <= x_count + 1;
                end else if (s_axis_tlast) begin
                    state <= ST_ROW_LAST;
                    border_valid <= 1;
                    x_count <= 0;
                end
            ST_PROCESS_ROW:
                if (s_axis_tvalid && !s_axis_tlast) begin
                    if (x_count == IMG_WIDTH - 1) begin
                        state <= ST_BORDER_ROW;
                    end
                    if (is_border_pixel) begin
                        m_axis_tdata <= BORDER_COLOR;
                    end else begin
                        m_axis_tdata <= s_axis_tdata;
                    end
                    x_count <= x_count + 1;
                end else if (s_axis_tlast) begin
                    state <= ST_ROW_LAST;
                    border_valid <= 0;
                    x_count <= 0;
                end
            ST_BORDER_ROW:
                if (s_axis_tvalid && !s_axis_tlast) begin
                    if (y_count == IMG_HEIGHT - 1) begin
                        state <= ST_ROW_LAST;
                        border_valid <= 1;
                        y_count <= y_count + 1;
                    end
                    if (is_border_pixel) begin
                        m_axis_tdata <= BORDER_COLOR;
                    end else begin
                        m_axis_tdata <= s_axis_tdata;
                    end
                end else if (s_axis_tlast) begin
                    state <= ST_ROW_LAST;
                    border_valid <= 0;
                    y_count <= 0;
                end
            ST_ROW_LAST:
                m_axis_tuser <= 1;
                next_state <= ST_IDLE;
                border_valid <= 0;
                y_count <= 0;
                x_count <= 0;
        end
    end

    // Handle AXI Stream protocol signals (`tvalid`, `tready`).

endmodule
