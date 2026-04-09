module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,
    parameter IMG_HEIGHT = 256,
    parameter BORDER_COLOR = 16'hFFFF,
    parameter DATA_MASK    = 16'h0000
)(
    input  wire             clk,
    input  wire             resetn,
    input  wire [15:0]     s_axis_tdata,
    input  wire            s_axis_tvalid,
    input  wire            s_axis_tlast,
    input  wire            s_axis_tuser,
    input  wire            m_axis_tready,
    output wire [15:0]     m_axis_tdata,
    output wire            m_axis_tvalid,
    output wire            m_axis_tlast,
    output wire            m_axis_tuser,
    output wire            s_axis_tready
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
            x_count = 16'd0;
            y_count = 16'd0;
            border_valid = 1;
        else begin
            case (state)
                ST_IDLE:
                    if (s_axis_tuser) begin
                        state = ST_ROW_FIRST;
                        next_state = ST_ROW_FIRST;
                    end else begin
                        state = state;
                    end
                ST_ROW_FIRST:
                    if (s_axis_tlast && is_border_pixel) begin
                        state = ST(Border Valid);
                        next_state = ST(Border Valid);
                    end else begin
                        state = state;
                    end
                ST PROCESS_ROW:
                    if (s_axis_tlast && is_border_pixel) begin
                        state = ST(Border Valid);
                        next_state = ST(Border Valid);
                    end else begin
                        state = state;
                    end
                ST(Border Valid):
                    if (s_axis_tlast && is_border_pixel) begin
                        state = ST_ROW_LAST;
                        next_state = ST_ROW_LAST;
                    end else begin
                        state = state;
                    end
                ST_ROW_LAST:
                    if (s_axis_tuser) begin
                        state = ST_IDLE;
                        next_state = ST_IDLE;
                    end else begin
                        state = state;
                    end
            endcase
        end
    end

    // Implement valid border detection
    always @* (s_axis_tvalid) begin
        if (border_valid) begin
            m_axis_tdata = (is_top_row || is_bottom_row) ? (BORDER_COLOR | DATA_MASK) : (s_axis_tdata | DATA_MASK);
            m_axis_tvalid = 1;
        else begin
            m_axis_tdata = s_axis_tdata | DATA_MASK;
            m_axis_tvalid = 0;
        end
    end

    // Handle AXI Stream protocol signals
    always @* (s_axis_tvalid) begin
        if (s_axis_tvalid) begin
            if (s_axis_tready) begin
                m_axis_tready = 1;
            end
        end
    end

    // FSM logic for state transitions
    // State ST_IDLE
    // State ST_ROW_FIRST
    // State ST PROCESS_ROW
    // State ST(Border Valid)
    // State ST_ROW_LAST

    // Counters and Control Signals
    wire x_count, y_count;

    // State and Counter Registers
    reg [2:0] state, next_state;

    // Internal Control Signals
    wire is_top_row, is_bottom_row, is_left_border, is_right_border, is_border_pixel;

    // FSM and Counter Logic
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            // Reset the variables
        end else begin
            // Insert FSM transitions and counter update logic here
        end
    end

    // Implement valid border detection.

    // Handle AXI Stream protocol signals (`tvalid`, `tready`).

endmodule