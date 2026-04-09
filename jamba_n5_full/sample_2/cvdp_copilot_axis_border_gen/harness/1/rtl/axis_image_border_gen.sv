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
    input  wire            s_axis_tlast,     // Input last signal
    input  wire            s_axis_tuser,     // Frame start signal

    // AXI Stream output interface
    output wire [15:0]     m_axis_tdata,     // Output stream data
    output wire            m_axis_tvalid,    // Output data valid
    input  wire            m_axis_tready,    // Input ready
    output wire            m_axis_tlast,     // Output last signal
    output wire            m_axis_tuser      // Frame start signal
);

   // State definitions
   localparam ST_IDLE = 3'b000,
         ST_ROW_FIRST = 3'b001,
         ST_PROCESS_ROW = 3'b010,
         ST_BORDER_ROW = 3'b011,
         ST_ROW_LAST   = 3'b100;

   reg [2:0] state, next_state;
   reg [15:0] x_count, y_count;
   reg border_valid;

   // Internal control signals
   wire is_top_row     = (y_count == 16'd0);
   wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
   wire is_left_border  = (x_count == 16'd0);
   wire is_right_border = (x_count == IMG_WIDTH + 1);
   wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

   // Initial state
   always @(posedge clk or negedge resetn) begin
       if (!resetn) begin
           state <= ST_IDLE;
           x_count <= 0;
           y_count <= 0;
           border_valid <= 0;
       end else begin
           state = state.next_state();
           x_count <= x_count + 1;
           y_count <= y_count + 1;
           border_valid = is_border_pixel;
       end
   end

   // Next state logic
   always @(*) begin
       next_state = state;
       if (resetn) next_state = ST_IDLE;
       else if (s_axis_tuser) next_state = ST_ROW_FIRST;
       else if (s_axis_tlast) next_state = ST_ROW_LAST;
       else if (is_border_pixel) next_state = ST_PROCESS_ROW;
       else next_state = ST_BORDER_ROW;
   end

   // Output logic
   always @(state) begin
       case (state)
           ST_IDLE: begin
               m_axis_tdata[i][j] = s_axis_tdata[i][j];
               m_axis_tlast = 1'b1;
           end
           ST_ROW_FIRST: begin
               if (is_top_row) begin
                   m_axis_tdata[i][j] = BORDER_COLOR;
               end else begin
                   m_axis_tdata[i][j] = s_axis_tdata[i][j];
               end
               m_axis_tlast = 1'b0;
           end
           ST_PROCESS_ROW: begin
               if (is_left_border || is_right_border) begin
                   m_axis_tdata[i][j] = BORDER_COLOR;
               end else if (is_border_pixel) begin
                   m_axis_tdata[i][j] = BORDER_COLOR;
               end else begin
                   m_axis_tdata[i][j] = s_axis_tdata[i][j];
               end
               m_axis_tlast = 1'b0;
           end
           ST_BORDER_ROW: begin
               if (is_bottom_row) begin
                   m_axis_tdata[i][j] = BORDER_COLOR;
               end else if (is_left_border || is_right_border) begin
                   m_axis_tdata[i][j] = BORDER_COLOR;
               end else begin
                   m_axis_tdata[i][j] = s_axis_tdata[i][j];
               end
               state <= ST_IDLE;
           end
       endcase
   end

endmodule
