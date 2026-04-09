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

   // State definitions
    enum state_type {ST_IDLE, ST_ROW_FIRST, ST_PROCESS_ROW, ST_BORDER_ROW, ST_ROW_LAST}
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;
    reg border_valid;

    // Internal Control Signals
    reg [15:0] x_offset = 0;
    reg [15:0] y_offset = 0;

    // FSM Control Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= ST_IDLE;
            x_count <= 0;
            y_count <= 0;
            border_valid <= 0;
            x_offset <= 0;
            y_offset <= 0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (s_axis_tuser) begin
                        state <= ST_ROW_FIRST;
                    end else begin
                        state <= ST_IDLE;
                    end
                end
                ST_ROW_FIRST: begin
                    if (s_axis_tvalid) begin
                        x_count <= x_offset;
                        if (x_count == 0) begin
                            border_valid <= 1;
                            x_offset <= IMG_WIDTH;
                        end else begin
                            state <= ST_PROCESS_ROW;
                        end
                    end else begin
                        state <= ST_IDLE;
                    end
                end
                ST_PROCESS_ROW: begin
                    if (s_axis_tvalid) begin
                        y_count <= y_offset;
                        if (y_count == 0) begin
                            border_valid <= 1;
                            y_offset <= IMG_HEIGHT;
                        end else begin
                            if (is_border_pixel) begin
                                m_axis_tdata <= BORDER_COLOR;
                                m_axis_tvalid <= 1;
                                m_axis_tlast <= 1;
                                state <= ST_BORDER_ROW;
                            end else begin
                                m_axis_tdata <= s_axis_tdata;
                                m_axis_tvalid <= s_axis_tvalid;
                                m_axis_tlast <= s_axis_tlast;
                                state <= ST_PROCESS_ROW;
                            end
                        end
                    end else begin
                        state <= ST_IDLE;
                    end
                end
                ST_BORDER_ROW: begin
                    if (s_axis_tvalid) begin
                        if (y_count == IMG_HEIGHT) begin
                            state <= ST_ROW_LAST;
                        end else begin
                            if (is_border_pixel) begin
                                m_axis_tdata <= BORDER_COLOR;
                                m_axis_tvalid <= 1;
                                m_axis_tlast <= 1;
                                state <= ST_PROCESS_ROW;
                            end else begin
                                m_axis_tdata <= s_axis_tdata;
                                m_axis_tvalid <= s_axis_tvalid;
                                m_axis_tlast <= s_axis_tlast;
                                state <= ST_PROCESS_ROW;
                            end
                        end
                    end else begin
                        state <= ST_IDLE;
                    end
                end
                ST_ROW_LAST: begin
                    if (s_axis_tvalid) begin
                        if (x_count == IMG_WIDTH) begin
                            state <= ST_IDLE;
                        end else begin
                            if (is_border_pixel) begin
                                m_axis_tdata <= BORDER_COLOR;
                                m_axis_tvalid <= 1;
                                m_axis_tlast <= 1;
                                state <= ST_ROW_FIRST;
                            end else begin
                                m_axis_tdata <= s_axis_tdata;
                                m_axis_tvalid <= s_axis_tvalid;
                                m_axis_tlast <= s_axis_tlast;
                                state <= ST_ROW_FIRST;
                            end
                        end
                    end else begin
                        state <= ST_IDLE;
                    end
                end
                default: state <= ST_IDLE;
            endcase
        end
    end

    // Handle AXI Stream protocol signals (`tvalid`, `tready`).

endmodule
