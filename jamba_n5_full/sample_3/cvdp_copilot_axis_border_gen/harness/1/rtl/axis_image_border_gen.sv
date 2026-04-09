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
           state     <= ST_IDLE;
           x_count   <= 0;
           y_count   <= 0;
           border_valid <= 0;
           m_axis_tdata <= 16'd0;
           m_axis_tvalid <= 1'b0;
           m_axis_tlast <= 1'b0;
           m_axis_tuser <= 1'b0;
           return;
       end

       case (state)
           ST_IDLE: begin
               if (s_axis_tuser) begin
                   state <= ST_ROW_FIRST;
               end
           end

           ST_ROW_FIRST: begin
               is_top_row     = (y_count == 16'd0);
               is_left_border  = (x_count == 16'd0);
               is_right_border = (x_count == IMG_WIDTH - 1);

               if (is_top_row || is_left_border) begin
                   border_valid <= 1'b1;
               end else if (is_bottom_row || is_right_border) begin
                   border_valid <= 1'b1;
               end

               m_axis_tdata[0] = is_top_row ? BORDER_COLOR : s_axis_tdata[0];
               m_axis_tdata[15] = is_right_border ? BORDER_COLOR : s_axis_tdata[15];
               x_count <= 0;
               y_count   <= 0;
               border_valid <= 1'b0;
               next_state <= ST_PROCESS_ROW;
           end

           ST_PROCESS_ROW: begin
               if (y_count < IMG_HEIGHT) begin
                   is_top_row     = (y_count == 0);
                   is_bottom_row  = (y_count == IMG_HEIGHT - 1);
                   is_left_border  = (x_count == 16'd0);
                   is_right_border = (x_count == IMG_WIDTH - 1);

                   border_valid = is_top_row || is_bottom_row || is_left_border || is_right_border;
                   if (border_valid)
                       m_axis_tdata[x_count] = BORDER_COLOR;
                   else
                       m_axis_tdata[x_count] = s_axis_tdata[x_count];

                   x_count <= x_count + 1;
                   y_count   <= y_count + 1;
                   if (x_count == IMG_WIDTH)
                       next_state <= ST_BORDER_ROW;
                   else
                       next_state <= ST_PROCESS_ROW;
               end
           end

           ST_BORDER_ROW: begin
               border_valid <= 1'b1;
               if (border_valid)
                   m_axis_tdata[0] = BORDER_COLOR;
               else
                   m_axis_tdata[0] = s_axis_tdata[0];

               if (border_valid)
                   m_axis_tdata[15] = BORDER_COLOR;
               else
                   m_axis_tdata[15] = s_axis_tdata[15];

               y_count <= y_count + 1;
               if (y_count == IMG_HEIGHT)
                   next_state <= ST_ROW_LAST;
               else
                   next_state <= ST_PROCESS_ROW;
           end

           ST_ROW_LAST: begin
               if (border_valid)
                   m_axis_tdata[15] = BORDER_COLOR;
               else
                   m_axis_tdata[15] = s_axis_tdata[15];

               y_count <= y_count + 1;
               next_state <= ST_IDLE;
           end
       endcase
   end

   // Output handshake
   always @(posedge clk) begin
       if (m_axis_tvalid) begin
           s_axis_tready <= 1'b1;
       end else
           s_axis_tready <= 1'b0;

       if (m_axis_tlast)
           m_axis_tlast <= 1'b1;
       else
           m_axis_tlast <= 1'b0;

       m_axis_tuser <= 1'b0;
   end

endmodule
