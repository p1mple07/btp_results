module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,               // Interior image width (X resolution)
    parameter IMG_HEIGHT = 256,              // Interior image height (Y resolution)
    parameter BORDER_COLOR = 16'hFFFF,       // Pixel value for the border
    parameter DATA_MASK    = 16'h0000        // Mask applied to input pixel data
)(
    input  wire            clk,              // AXI clock (100 MHz)
    input  wire            resetn,           // Active-low asynchronous reset

    // AXI Stream input interface
    input  wire [15:0]     s_axis_tdata,     // Input pixel data
    input  wire            s_axis_tvalid,    // Input valid signal
    output wire            s_axis_tready,    // Ready to accept input data
    input  wire            s_axis_tlast,     // Input last signal (not used in this design)
    input  wire            s_axis_tuser,     // Frame start signal

    // AXI Stream output interface
    output wire [15:0]     m_axis_tdata,     // Output pixel data with border applied
    output wire            m_axis_tvalid,    // Output valid signal
    input  wire            m_axis_tready,    // Ready to accept output data
    output wire            m_axis_tlast,     // Output last signal for each row
    output wire            m_axis_tuser      // Output frame start signal
);

    // State encoding for the FSM
    localparam [2:0] ST_IDLE       = 3'b000,
                      ST_ROW_FIRST  = 3'b001,
                      ST_PROCESS_ROW = 3'b010,
                      ST_BORDER_ROW  = 3'b011,
                      ST_ROW_LAST    = 3'b100;

    // Registers for state and pixel/row counters
    reg [2:0] state, next_state;
    reg [15:0] x_count, y_count;

    // Border detection based on current pixel position
    // Note: The total row width is IMG_WIDTH + 2 and total rows is IMG_HEIGHT + 2.
    wire is_top_row     = (y_count == 16'd0);
    wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
    wire is_left_border = (x_count == 16'd0);
    wire is_right_border = (x_count == IMG_WIDTH + 1);
    wire is_border_pixel = is_top_row || is_bottom_row || is_left_border || is_right_border;

    //-------------------------------------------------------------------------
    // Combinational logic to determine the next state
    //-------------------------------------------------------------------------
    always @(*) begin
        case (state)
            ST_IDLE: begin
                if (s_axis_tuser && s_axis_tvalid)
                    next_state = ST_ROW_FIRST;
                else
                    next_state = ST_IDLE;
            end
            ST_ROW_FIRST: begin
                if (x_count == (IMG_WIDTH + 1))
                    next_state = ST_PROCESS_ROW;
                else
                    next_state = ST_ROW_FIRST;
            end
            ST_PROCESS_ROW: begin
                if (x_count == (IMG_WIDTH + 1))
                    next_state = (y_count == IMG_HEIGHT) ? ST_BORDER_ROW : ST_PROCESS_ROW;
                else
                    next_state = ST_PROCESS_ROW;
            end
            ST_BORDER_ROW: begin
                if (x_count == (IMG_WIDTH + 1))
                    next_state = ST_ROW_LAST;
                else
                    next_state = ST_BORDER_ROW;
            end
            ST_ROW_LAST: begin
                next_state = ST_IDLE;
            end
            default: next_state = ST_IDLE;
        endcase
    end

    //-------------------------------------------------------------------------
    // Sequential logic: update state and counters on clock edge
    //-------------------------------------------------------------------------
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state      <= ST_IDLE;
            x_count    <= 16'd0;
            y_count    <= 16'd0;
        end else begin
            // Update counters based on the current state
            case (state)
                ST_IDLE: begin
                    if (s_axis_tuser && s_axis_tvalid) begin
                        x_count <= 16'd0;
                        y_count <= 16'd0;
                    end
                end
                ST_ROW_FIRST: begin
                    if (x_count == (IMG_WIDTH + 1)) begin
                        x_count <= 16'd0;
                        y_count <= y_count + 1;  // Transition to interior row (row 1)
                    end else begin
                        x_count <= x_count + 1;
                    end
                end
                ST_PROCESS_ROW: begin
                    if (x_count == (IMG_WIDTH + 1)) begin
                        x_count <= 16'd0;
                        y_count <= y_count + 1;
                    end else begin
                        x_count <= x_count + 1;
                    end
                end
                ST_BORDER_ROW: begin
                    if (x_count == (IMG_WIDTH + 1)) begin
                        x_count <= 16'd0;
                        y_count <= y_count + 1;
                    end else begin
                        x_count <= x_count + 1;
                    end
                end
                ST_ROW_LAST: begin
                    x_count <= 16'd0;
                    y_count <= 16'd0;
                end
                default: begin
                    x_count <= 16'd0;
                    y_count <= 16'd0;
                end
            endcase

            // Transition to the next state
            state <= next_state;
        end
    end

    //-------------------------------------------------------------------------
    // AXI Stream Output Assignments
    //-------------------------------------------------------------------------
    // Output pixel data: if the pixel is on the border, output BORDER_COLOR;
    // otherwise, output the masked input pixel data.
    assign m_axis_tdata = is_border_pixel ? BORDER_COLOR : (s_axis_tdata & DATA_MASK);

    // Mark the last pixel of each row (except the final state)
    assign m_axis_tlast = (x_count == (IMG_WIDTH + 1)) && (state != ST_ROW_LAST);

    // Assert tuser at the start of the output frame (i.e. at the first row)
    assign m_axis_tuser = (state == ST_ROW_FIRST);

    // AXI Stream handshake signals
    // The module is ready to accept input when not idle and not in the final state.
    assign s_axis_tready = (state != ST_IDLE) && (state != ST_ROW_LAST);
    // The output valid signal is asserted when the module is actively processing a row.
    assign m_axis_tvalid = (state != ST_IDLE) && (state != ST_ROW_LAST);

endmodule