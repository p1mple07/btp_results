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
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;
    reg border_valid;

    // Internal Control Signals
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border  = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

    // Reset logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= ST_IDLE;
            x_count <= 0;
            y_count <= 0;
            m_axis_tlast <= 0;
            m_axis_tuser <= 0;
            s_axis_tlast <= 0;
            s_axis_tuser <= 0;
        end else begin
            state <= next_state;
        end
    end

    // FSM and Counter Logic
    always @(posedge clk) begin
        next_state <= state;
        if (next_state == ST_IDLE) begin
            s_axis_tready <= 1;
        end else begin
            s_axis_tready <= m_axis_tready;
        end
    end

    // State Logic
    always @(state) begin
        case (state)
            ST_IDLE: begin
                if (s_axis_tuser) begin
                    state <= ST_ROW_FIRST;
                end else begin
                    state <= ST_IDLE;
                end
            end
            ST_ROW_FIRST: begin
                if (s_axis_tvalid && s_axis_tlast) begin
                    x_count <= x_count + 1;
                    if (x_count == 16'd1) begin
                        state <= ST_PROCESS_ROW;
                    end
                end else begin
                    state <= ST_IDLE;
                end
            end
            ST_PROCESS_ROW: begin
                if (s_axis_tvalid && s_axis_tlast) begin
                    x_count <= x_count + 1;
                    if (x_count == IMG_WIDTH) begin
                        state <= ST_BORDER_ROW;
                    end
                end else begin
                    state <= ST_IDLE;
                end
            end
            ST_BORDER_ROW: begin
                if (s_axis_tvalid && s_axis_tlast) begin
                    x_count <= x_count + 1;
                    if (x_count == IMG_WIDTH + 1) begin
                        state <= ST_ROW_LAST;
                    end
                end else begin
                    state <= ST_IDLE;
                end
            end
            ST_ROW_LAST: begin
                if (s_axis_tvalid && s_axis_tlast) begin
                    y_count <= y_count + 1;
                    if (y_count == IMG_HEIGHT) begin
                        state <= ST_IDLE;
                        m_axis_tlast <= 1;
                        m_axis_tuser <= 1;
                    end
                end else begin
                    state <= ST_IDLE;
                end
            end
        endcase
    end

    // AXI Stream output logic
    always @(state) begin
        case (state)
            ST_ROW_FIRST: begin
                m_axis_tdata <= BORDER_COLOR;
                m_axis_tvalid <= 1;
            end
            ST_PROCESS_ROW: begin
                m_axis_tdata <= s_axis_tdata;
                m_axis_tvalid <= s_axis_tvalid;
            end
            ST_BORDER_ROW: begin
                m_axis_tdata <= BORDER_COLOR;
                m_axis_tvalid <= 1;
            end
            ST_ROW_LAST: begin
                m_axis_tdata <= BORDER_COLOR;
                m_axis_tvalid <= 1;
                m_axis_tuser <= 1;
            end
        endcase
    end

    // Handle AXI Stream protocol signals (`tvalid`, `tready`).
    // Additional logic for M_AXIS_TREADY and S_AXIS_TREADY can be implemented as needed.

endmodule
