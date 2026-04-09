`timescale 1ps / 1ps

module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,               // Image width (X resolution)
    parameter IMG_HEIGHT = 256,               // Image height (Y resolution)
    parameter BORDER_COLOR = 16'hFFFF,      // Border pixel value
    parameter DATA_MASK    = 16'h0000       // Mask for input pixels
)
(
    input  wire            clk,              // AXI clock
    input  wire            resetn,           // Active-low reset
    
    input  wire [15:0]     s_axis_tdata,     // Input stream data
    input  wire            s_axis_tvalid,    // Input data valid
    output wire            s_axis_tready,    // Output ready
    input  wire            s_axis_tlast,     // Input last signal
    input  wire            s_axis_tuser,     // Frame start signal
    
    output wire [15:0]     m_axis_tdata,     // Output stream data
    output wire            m_axis_tvalid,    // Output data valid
    input  wire            m_axis_tready,    // Input ready
    output wire            m_axis_tlast,     // Output last signal
    output wire            m_axis_tuser      // Frame start signal
);

    // State Definitions
    localparam ST_IDLE          = 3'd0;
    localparam ST_ROW_FIRST     = 3'd1;
    localparam ST_PROCESS_ROW   = 3'd2;
    localparam ST_BORDER_ROW    = 3'd3;
    localparam ST_ROW_LAST      = 3'd4;

    // State and Counter Registers
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;
    reg [15:0] pixel_reg; // Register to hold non-border pixel data

    // Internal Control Signals
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border  = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

    // Output Control Signals
    assign m_axis_tdata  = (is_border_pixel) ? BORDER_COLOR : pixel_reg;
    assign m_axis_tvalid = 1'b1; // Data is valid when processed
    assign m_axis_tlast  = (x_count == IMG_WIDTH + 1);
    assign m_axis_tuser  = s_axis_tuser;

    // Ready signal: always ready to accept input data
    assign s_axis_tready = m_axis_tready;

    // FSM and Counter Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state    <= ST_IDLE;
            x_count  <= 16'd0;
            y_count  <= 16'd0;
            pixel_reg<= 16'd0;
        end else begin
            state <= next_state;
            // Update counters on each valid transaction
            if (m_axis_tvalid && m_axis_tready) begin
                if (x_count == IMG_WIDTH + 1) begin
                    x_count <= 16'd0;
                    y_count <= y_count + 1'b1;
                end else begin
                    x_count <= x_count + 1'b1;
                end
            end
            
            // Latch the input pixel only if it is not a border pixel
            if (!is_border_pixel) begin
                pixel_reg <= s_axis_tdata;
            end
        end
    end

    // Next State Logic
    always @(*) begin
        case (state)
            ST_IDLE: begin
                if (s_axis_tuser) begin
                    next_state = ST_ROW_FIRST;
                end else begin
                    next_state = ST_IDLE;
                end
            end
            ST_ROW_FIRST: begin
                if (x_count == IMG_WIDTH + 1) begin
                    next_state = ST_PROCESS_ROW;
                end else begin
                    next_state = ST_ROW_FIRST;
                end
            end
            ST_PROCESS_ROW: begin
                if (x_count == IMG_WIDTH + 1 && y_count == IMG_HEIGHT) begin
                    next_state = ST_BORDER_ROW;
                end else begin
                    next_state = ST_PROCESS_ROW;
                end
            end
            ST_BORDER_ROW: begin
                if (x_count == IMG_WIDTH + 1) begin
                    next_state = ST_ROW_LAST;
                end else begin
                    next_state = ST_BORDER_ROW;
                end
            end
            ST_ROW_LAST: begin
                next_state = ST_IDLE;
            end
            default: next_state = ST_IDLE;
        endcase
    end

endmodule
