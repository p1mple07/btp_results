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
    output wire            m_axis_tlast,
    input  wire            m_axis_tready,
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

    // FSM and Counter Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state = ST_IDLE;
            next_state = ST_IDLE;
        else begin
            case (state)
                ST_IDLE: begin
                    if (s_axis_tuser) begin
                        state = ST_ROW_FIRST;
                        next_state = ST_ROW_FIRST;
                    end else begin
                        state = ST_IDLE;
                        next_state = ST_IDLE;
                    end
                end

                ST_ROW_FIRST: begin
                    if (s_axis_tuser) begin
                        state = ST_PROCESS_ROW;
                        next_state = ST_PROCESS_ROW;
                    end else begin
                        state = ST_ROW_FIRST;
                        next_state = ST_ROW_FIRST;
                    end
                end

                ST_PROCESS_ROW: begin
                    if (is_border_pixel) begin
                        border_valid = 1;
                    end else begin
                        border_valid = 0;
                    end

                    if (s_axis_tvalid) begin
                        if (border_valid) begin
                            m_axis_tdata = (s_axis_tdata & DATA_MASK) | BORDER_COLOR;
                            m_axis_tvalid = 1;
                        else begin
                            m_axis_tdata = s_axis_tdata & DATA_MASK;
                            m_axis_tvalid = 1;
                        end
                        if (s_axis_tlast) begin
                            m_axis_tlast = 1;
                            m_axis_tuser = 1;
                            m_axis_tready = 1;
                        else begin
                            m_axis_tready = 0;
                        end
                    end else begin
                        m_axis_tvalid = 0;
                        m_axis_tready = 0;
                    end

                    if (y_count == IMG_HEIGHT) begin
                        state = ST_BORDER_ROW;
                        next_state = ST_BORDER_ROW;
                    end else begin
                        x_count = x_count + 1;
                        y_count = y_count + 1;
                        state = ST_PROCESS_ROW;
                        next_state = ST_PROCESS_ROW;
                    end
                end

                ST_BORDER_ROW: begin
                    border_valid = 1;
                    if (s_axis_tvalid) begin
                        m_axis_tdata = (s_axis_tdata & DATA_MASK) | BORDER_COLOR;
                        m_axis_tvalid = 1;
                    else begin
                        m_axis_tvalid = 0;
                    end
                    if (s_axis_tlast) begin
                        m_axis_tlast = 1;
                        m_axis_tuser = 1;
                        m_axis_tready = 1;
                    else begin
                        m_axis_tready = 0;
                    end
                    state = ST_ROW_LAST;
                    next_state = ST_ROW_LAST;
                end

                ST_ROW_LAST: begin
                    state = ST_IDLE;
                    next_state = ST_IDLE;
                end
            end
        end
    end

    // Initialize counters and state
    state = ST_IDLE;
    next_state = ST_IDLE;
    x_count = 16'd0;
    y_count = 16'd0;
    border_valid = 0;

    // Output data valid handling
    wire begin
        if (m_axis_tvalid) begin
            // Handle data transfer
        end
    end
endmodule