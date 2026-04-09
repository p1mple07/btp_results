`timescale 1ps / 1ps

module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,
    parameter IMG_HEIGHT = 256,
    parameter BORDER_COLOR = 16'hFFFF,
    parameter DATA_MASK    = 16'h0000
)(
    input  wire            clk,
    input  wire            resetn,

    // AXI Stream input interface
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    output wire            s_axis_tready,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,

    // AXI Stream output interface
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
            border_valid <= 0;
            is_top_row <= 1'b1;
            is_bottom_row <= 1'b1;
            is_left_border <= 1'b1;
            is_right_border <= 1'b1;
            is_border_pixel <= 1'b0;
        end else begin
            // Proceed with FSM
        end
    end

    // Define states
    always @(state or x_count or y_count) begin
        case (state)
            ST_IDLE: begin
                if (s_axis_tuser) begin
                    next_state = ST_ROW_FIRST;
                    x_count <= 0;
                    y_count <= 0;
                    border_valid <= 0;
                end
            end

            ST_ROW_FIRST: begin
                if (s_axis_tvalid && s_axis_tdata[0] == BORDER_COLOR) begin
                    border_valid <= 1'b1;
                end else begin
                    border_valid <= 0;
                end

                // Check if we are at top row
                if (is_top_row && is_left_border) begin
                    next_state = ST_PROCESS_ROW;
                end else if (is_top_row && is_right_border) begin
                    next_state = ST_BORDER_ROW;
                end else if (is_left_border && is_bottom_row) begin
                    next_state = ST_ROW_LAST;
                end else if (is_right_border && is_bottom_row) begin
                    next_state = ST_IDLE;
                end else begin
                    next_state = ST_ROW_FIRST;
                end
            end

            ST_PROCESS_ROW: begin
                // Process each pixel, apply border if needed
                if (is_border_pixel) begin
                    m_axis_tdata[x_count] = BORDER_COLOR;
                end else begin
                    m_axis_tdata[x_count] = s_axis_tdata[x_count];
                end

                if (s_axis_tvalid && s_axis_tdata[15:0] == {8'b0, 7'b0, 7'b0, 1'b0, 7'b0, 7'b0, 7'b0, 1'b0}) begin
                    border_valid <= 1'b1;
                end else begin
                    border_valid <= 0;
                end

                // Determine next state
                if (s_axis_tlast) begin
                    next_state = ST_BORDER_ROW;
                end else if (is_border_pixel) begin
                    next_state = ST_PROCESS_ROW;
                end else begin
                    next_state = ST_IDLE;
                end
            end

            ST_BORDER_ROW: begin
                // Apply bottom border
                for (int i = 0; i < IMG_WIDTH; i++) begin
                    m_axis_tdata[i] = BORDER_COLOR;
                end

                next_state = ST_IDLE;
            end

            ST_ROW_LAST: begin
                // No action, transition back to IDLE
                next_state = ST_IDLE;
            end
        endcase
    end

    // Handle AXI Stream ready
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            s_axis_tready <= 1'b1;
        end else begin
            if (m_axis_tready) begin
                s_axis_tready <= 1'b0;
            end
        end
    end

endmodule
