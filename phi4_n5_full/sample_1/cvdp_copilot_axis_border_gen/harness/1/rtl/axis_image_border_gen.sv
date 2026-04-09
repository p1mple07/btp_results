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
    output wire            s_axis_tready,    // Ready to accept input
    input  wire            s_axis_tlast,     // Input last signal
    input  wire            s_axis_tuser,     // Frame start signal

    // AXI Stream output interface
    output wire [15:0]     m_axis_tdata,     // Output stream data
    output wire            m_axis_tvalid,    // Output data valid
    input  wire            m_axis_tready,    // Ready to accept output
    output wire            m_axis_tlast,     // Output last signal
    output wire            m_axis_tuser      // Frame start signal
);

   // State Definitions
   localparam [2:0] ST_IDLE       = 3'd0,
                     ST_ROW_FIRST  = 3'd1,
                     ST_PROCESS_ROW = 3'd2,
                     ST_BORDER_ROW  = 3'd3,
                     ST_ROW_LAST    = 3'd4;

   // State and Counter Registers
   reg [2:0] state;
   reg [15:0] x_count, y_count;
   reg border_valid;  // Not explicitly used but available if needed

   // Internal control signals for border detection (for completeness)
   wire is_top_row     = (y_count == 16'd0);
   wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
   wire is_left_border = (x_count == 16'd0);
   wire is_right_border= (x_count == IMG_WIDTH + 1);
   wire is_border_pixel = (is_top_row || is_bottom_row || is_left_border || is_right_border);

   // FSM Sequential Process
   always @(posedge clk or negedge resetn) begin
      if (!resetn) begin
         state      <= ST_IDLE;
         x_count    <= 16'd0;
         y_count    <= 16'd0;
      end else begin
         case (state)
            ST_IDLE: begin
               // Wait for a new frame start. When detected, reset counters and move to first row.
               if (s_axis_tvalid && s_axis_tuser) begin
                  state      <= ST_ROW_FIRST;
                  x_count    <= 16'd0;
                  y_count    <= 16'd0;
               end else begin
                  state      <= ST_IDLE;
                  x_count    <= 16'd0;  // Remain at 0 while idle
                  y_count    <= 16'd0;
               end
            end

            ST_ROW_FIRST: begin
               // Process the first (top) row: all pixels are border.
               x_count <= x_count + 1;
               if (s_axis_tlast) begin
                  y_count <= y_count + 1;
                  state   <= ST_PROCESS_ROW;
               end
            end

            ST_PROCESS_ROW: begin
               // Process middle rows.
               // For each row, output BORDER_COLOR at left (x==0) and right (x==IMG_WIDTH+1) edges.
               // For inner pixels, output (s_axis_tdata & DATA_MASK).
               x_count <= x_count + 1;
               if (s_axis_tlast) begin
                  y_count <= y_count + 1;
                  if (y_count == IMG_HEIGHT)
                     state <= ST_BORDER_ROW;
                  else
                     state <= ST_PROCESS_ROW;
               end
            end

            ST_BORDER_ROW: begin
               // Process the bottom row: all pixels are border.
               x_count <= x_count + 1;
               if (s_axis_tlast) begin
                  y_count <= y_count + 1;
                  state   <= ST_ROW_LAST;
               end
            end

            ST_ROW_LAST: begin
               // Final state: complete the frame and return to idle.
               state <= ST_IDLE;
            end

            default: begin
               state <= ST_IDLE;
            end
         endcase
      end
   end

   // AXI Stream Output Signal Assignments

   // Always ready to accept input
   assign s_axis_tready = 1'b1;

   // m_axis_tuser: Asserted at the start of a new frame (first word in frame)
   assign m_axis_tuser = (state == ST_ROW_FIRST && x_count == 16'd0) ? 1'b1 : 1'b0;

   // m_axis_tvalid: Asserted when valid pixel data is available.
   // Only states that output pixel data (ST_ROW_FIRST, ST_PROCESS_ROW, ST_BORDER_ROW) drive valid.
   assign m_axis_tvalid = ((state == ST_ROW_FIRST) ||
                           (state == ST_PROCESS_ROW) ||
                           (state == ST_BORDER_ROW)) ? 1'b1 : 1'b0;

   // m_axis_tdata: Generate output pixel data with border applied.
   // - In ST_ROW_FIRST and ST_BORDER_ROW, all pixels are border.
   // - In ST_PROCESS_ROW, left and right borders are BORDER_COLOR; inner pixels use (s_axis_tdata & DATA_MASK).
   assign m_axis_tdata = 
         (state == ST_ROW_FIRST) ? BORDER_COLOR :
         (state == ST_BORDER_ROW) ? BORDER_COLOR :
         (state == ST_PROCESS_ROW) ? ((x_count == 16'd0 || x_count == IMG_WIDTH+1) ? BORDER_COLOR : (s_axis_tdata & DATA_MASK)) : 16'h0000;

   // m_axis_tlast: Asserted on the last pixel of the frame (bottom row).
   assign m_axis_tlast = (state == ST_BORDER_ROW && x_count == IMG_WIDTH+1 && s_axis_tlast) ? 1'b1 : 1'b0;

endmodule