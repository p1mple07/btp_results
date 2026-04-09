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
    input  wire            s_axis_tlast,     // Input last signal
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
            // Reset the variables
        end else begin
            // Insert FSM transitions and counter update logic here
        end
    end

    // Add the FSM logic for transitioning between states.

    // Implement valid border detection.

    // Handle AXI Stream protocol signals (`tvalid`, `tready`).

endmodule