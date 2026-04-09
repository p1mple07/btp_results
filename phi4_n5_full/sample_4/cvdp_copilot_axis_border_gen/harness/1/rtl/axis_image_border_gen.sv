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
    output wire            s_axis_tready,    // Ready to accept input data
    input  wire            s_axis_tlast,     // Input last signal
    input  wire            s_axis_tuser,     // Frame start signal

    // AXI Stream output interface
    output reg  [15:0]     m_axis_tdata,     // Output stream data
    output reg             m_axis_tvalid,    // Output data valid
    input  wire            m_axis_tready,    // Ready to accept output data
    output reg             m_axis_tlast,     // Output last signal
    output reg             m_axis_tuser      // Frame start signal
);

   // State definitions
   localparam ST_IDLE         = 3'd0,
              ST_ROW_FIRST    = 3'd1,
              ST_PROCESS_ROW  = 3'd2,
              ST_BORDER_ROW   = 3'd3,
              ST_ROW_LAST     = 3'd4;

   // State and Counter Registers
   reg [2:0] state, next_state;
   reg [15:0] x_count, y_count;

   // Internal Control Signals
   // These wires determine if the current pixel position is at a border.
   wire is_top_row     = (y_count == 16'd0);
   wire is_bottom_row  = (y_count == IMG_HEIGHT + 1);
   wire is_left_border = (x_count == 16'd0);
   wire is_right_border= (x_count == IMG_WIDTH + 1);
   wire is_border_pixel = is_top_row || is_bottom_row || is_left_border || is_right_border;

   // Output assignments
   // For border pixels, output BORDER_COLOR; for image pixels, pass through s_axis_tdata masked with DATA_MASK.
   assign m_axis_tdata = is_border_pixel ? BORDER_COLOR : (s_axis_tdata & DATA_MASK);
   // m_axis_tlast is asserted on the last pixel of a row (for states that output data)
   assign m_axis_tlast = ((state != ST_ROW_LAST) && (x_count == IMG_WIDTH + 1));
   // m_axis_tuser indicates the start of an output frame (only during the very first pixel of the top border row)
   assign m_axis_tuser = (state == ST_ROW_FIRST) && (x_count == 16'd0);
   // s_axis_tready is asserted only when we need to capture an input pixel (in ST_PROCESS_ROW for image data)
   assign s_axis_tready = (state == ST_PROCESS_ROW) && (x_count != 16'd0) && (x_count != IMG_WIDTH + 1);

   // FSM and Counter Logic
   always @(posedge clk or negedge resetn) begin
      if (!resetn) begin
         state      <= ST_IDLE;
         x_count    <= 16'd0;
         y_count    <= 16'd0;
         m_axis_tvalid <= 1'b0;
      end else begin
         case (state)
            ST_IDLE: begin
               // Wait for the frame start signal
               if (s_axis_tuser) begin
                  state      <= ST_ROW_FIRST;
                  x_count    <= 16'd0;
                  y_count    <= 16'd0;
               end
               m_axis_tvalid <= 1'b0;
            end

            ST_ROW_FIRST: begin
               // Top border row: output IMG_WIDTH+2 pixels (all border pixels)
               if (m_axis_tready) begin
                  if (x_count < IMG_WIDTH + 1) begin
                     x_count <= x_count + 1;
                  end else begin
                     x_count <= 16'd0;
                     // End of top border row; move to processing the image rows.
                     state <= ST_PROCESS_ROW;
                     y_count <= 16'd1; // Next row index for image data
                  end
               end
               m_axis_tvalid <= 1'b1;
            end

            ST_PROCESS_ROW: begin
               // For each image row, output left border, image data, then right border.
               if (m_axis_tready) begin
                  if (x_count < IMG_WIDTH + 1) begin
                     x_count <= x_count + 1;
                  end else begin
                     x_count <= 16'd0;
                     if (y_count < IMG_HEIGHT) begin
                        y_count <= y_count + 1;
                        state <= ST_PROCESS_ROW;
                     end else begin
                        // Last image row processed; transition to bottom border row.
                        state <= ST_BORDER_ROW;
                        y_count <= IMG_HEIGHT + 1; // Bottom border row index
                     end
                  end
               end
               m_axis_tvalid <= 1'b1;
            end

            ST_BORDER_ROW: begin
               // Bottom border row: output IMG_WIDTH+2 pixels (all border pixels)
               if (m_axis_tready) begin
                  if (x_count < IMG_WIDTH + 1) begin
                     x_count <= x_count + 1;
                  end else begin
                     x_count <= 16'd0;
                     // End of bottom border row; transition to final state.
                     state <= ST_ROW_LAST;
                  end
               end
               m_axis_tvalid <= 1'b1;
            end

            ST_ROW_LAST: begin
               // Final state: complete frame transmission and return to idle.
               if (m_axis_tready) begin
                  state <= ST_IDLE;
               end
               m_axis_tvalid <= 1'b0;
            end

            default: begin
               state <= ST_IDLE;
            end
         endcase
      end
   end

endmodule