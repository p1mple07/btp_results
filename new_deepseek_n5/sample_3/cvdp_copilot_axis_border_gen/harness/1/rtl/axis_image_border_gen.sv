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
    input  wire            m_axis_tready,
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser
)

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
            if (s_axis_tuser) begin
                state = ST_ROW_FIRST;
                next_state = ST_ROW_FIRST;
            end else begin
                state = state;
                next_state = state;
            end
        end
    end

    // State Transition Handling
    case (state)
        ST_IDLE: begin
            if (s_axis_tuser) begin
                state = ST_ROW_FIRST;
                next_state = ST_ROW_FIRST;
            end
        end
        ST_ROW_FIRST: begin
            if (s_axis_tlast) begin
                state = ST_ROW_LAST;
                next_state = ST_ROW_LAST;
            end else begin
                x_count = 16'd0;
                y_count = 16'd0;
                state = ST_PROCESS_ROW;
                next_state = ST_PROCESS_ROW;
            end
        end
        ST_PROCESS_ROW: begin
            if (s_axis_tlast) begin
                state = ST_ROW_LAST;
                next_state = ST_ROW_LAST;
            end else begin
                x_count = x_count + 1;
                y_count = y_count + 1;
                state = ST_PROCESS_ROW;
                next_state = ST_PROCESS_ROW;
            end
        end
        ST_ROW_LAST: begin
            if (s_axis_tuser) begin
                state = ST_ROW_FIRST;
                next_state = ST_ROW_FIRST;
            end
        end
        ST_BORDER_ROW: begin
            if (s_axis_tlast) begin
                state = ST_ROW_LAST;
                next_state = ST_ROW_LAST;
            end
        end
    endcase

    // Border Generation Logic
    always @(posedge clk) begin
        if (!resetn) begin
            x_count = 16'd0;
            y_count = 16'd0;
            border_valid = 0;
        end else begin
            if (is_border_pixel) begin
                border_valid = 1;
            else begin
                border_valid = 0;
            end
        end
    end

    // AXI Output Signals
    wire [15:0] m_axis_tdata_next;
    wire [15:0] m_axis_tdata_next_valid;

    // Processing Pixel Data
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            m_axis_tvalid = 0;
            m_axis_tready = 0;
            m_axis_tlast = 0;
        end else begin
            if (border_valid) begin
                m_axis_tdata_next = (BORDER_COLOR & DATA_MASK);
                m_axis_tvalid = 1;
            else begin
                m_axis_tdata_next = (s_axis_tdata & DATA_MASK);
                m_axis_tvalid = 1;
            end
        end
    end

    // Updating AXI Output
    always @(posedge clk) begin
        if (m_axis_tvalid) begin
            m_axis_tdata_next_valid = 1;
        end
    end

    // Finalizing Output
    always begin
        if (m_axis_tready) begin
            m_axis_tdata = m_axis_tdata_next;
            m_axis_tvalid = 0;
            m_axis_tlast = 0;
        end
    end

    // State Machine Outputs
    wire [2:0] m_axis_tuser_next;

    // Final State Handling
    always begin
        if (state == ST_ROW_LAST) begin
            m_axis_tuser_next = 1;
        else begin
            m_axis_tuser_next = 0;
        end
    end

    // Assign Outputs
    m_axis_tuser = m_axis_tuser_next;
    m_axis_tready = m_axis_tready;
    m_axis_tlast = m_axis_tlast;
    m_axis_tdata = m_axis_tdata_next;
    m_axis_tvalid = m_axis_tvalid;
    m_axis_tdata_next = m_axis_tdata;
    m_axis_tdata_next_valid = m_axis_tvalid;

endmodule