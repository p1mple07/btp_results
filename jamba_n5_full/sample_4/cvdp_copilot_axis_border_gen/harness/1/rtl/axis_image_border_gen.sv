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

   // State machine registers
   reg [2:0] state;
   reg [15:0] x_count, y_count;
   reg border_valid;
   reg [2:0] next_state;

   // Initial assignment for state machine
   always @(posedge clk or negedge resetn) begin
      if (!resetn) begin
          state <= ST_IDLE;
          x_count <= 0;
          y_count <= 0;
          border_valid <= 0;
          next_state <= ST_IDLE;
      end else begin
          case (state)
              ST_IDLE: begin
                  if (s_axis_tuser) begin
                      state <= ST_ROW_FIRST;
                      next_state <= ST_PROCESS_ROW;
                  end
                  // else stay idle
              end
              ST_ROW_FIRST: begin
                  is_top_row = (y_count == 16'd0);
                  if (is_top_row) begin
                      border_valid <= 1'b1;
                  end else
                      border_valid <= 0;
                  // other conditions?
                  // Actually, we need to decide for each row.
                  // But the spec says: check if the pixel belongs to the border by evaluating current position.
                  // So we just set is_top_row condition.
                  next_state <= ST_PROCESS_ROW;
              end
              ST_PROCESS_ROW: begin
                  is_left_border = (x_count == 16'd0);
                  is_right_border = (x_count == IMG_WIDTH + 1);
                  is_border_pixel = is_top_row || is_bottom_row || is_left_border || is_right_border;
                  // For each pixel, if it's on the border, set border_valid.
                  // But the output logic will add border color to all pixels that are border.
                  // So we don't need to modify the data here, just set valid flags.
                  border_valid <= is_left_border || is_right_border || is_top_row || is_bottom_row;
                  next_state <= ST_BORDER_ROW;
              end
              ST_BORDER_ROW: begin
                  // Apply bottom border
                  border_valid <= is_bottom_row;
                  // Then next state is ST_ROW_LAST
                  next_state <= ST_ROW_LAST;
              end
              ST_ROW_LAST: begin
                  // No border, just reset for next frame
                  border_valid <= 0;
                  next_state <= ST_IDLE;
              end
          endcase
      end
   end

   // Generate output data
   always @(posedge clk or negedge resetn) begin
      if (!resetn) begin
          m_axis_tdata <= {16'b0};
          m_axis_tvalid <= 1'b0;
          m_axis_tready <= 1'b0;
          m_axis_tlast <= 1'b1;
          m_axis_tuser <= 1'b0;
      end else begin
          case (next_state)
              ST_IDLE: begin
                  m_axis_tdata <= {16'b0};
                  m_axis_tvalid <= 1'b0;
                  m_axis_tready <= 1'b1;
                  m_axis_tlast <= 1'b0;
                  m_axis_tuser <= 1'b0;
              end
              ST_ROW_FIRST: begin
                  // We don't need to output for this row.
                  m_axis_tdata <= {16'b0};
                  m_axis_tvalid <= 1'b0;
                  m_axis_tready <= 1'b1;
                  m_axis_tlast <= 1'b0;
                  m_axis_tuser <= 1'b0;
              end
              ST_PROCESS_ROW: begin
                  // We don't need to output for middle rows.
                  m_axis_tdata <= {16'b0};
                  m_axis_tvalid <= 1'b0;
                  m_axis_tready <= 1'b1;
                  m_axis_tlast <= 1'b0;
                  m_axis_tuser <= 1'b0;
              end
              ST_BORDER_ROW: begin
                  // Set output data: add border
                  m_axis_tdata[16'd15] = BORDER_COLOR;
                  m_axis_tdata[0] = BORDER_COLOR;
                  // Actually, we need to apply border around the image. The spec says "surrounds the image data".
                  // It might be simpler to set the first and last columns to border color for all rows.
                  // But the example code might just output border around the image.
                  // We'll do: set all pixels to border color? But that would be inefficient.
                  // But the requirement: "adds a customizable border to the image". So we need to add border pixels.
                  // The simplest: set the borders to BORDER_COLOR.
                  // But how to do that? We might need to know coordinates.

                  // For simplicity, we can set the first and last columns to border color for all rows.
                  // But we don't have coordinates. The spec might expect a simple approach.

                  // Instead, we can just set the data to the border color for the border pixels we already handled?
                  // But the previous logic already set border_valid for those pixels. But the output data remains 0.

                  // This is getting messy.

                  // Let's adopt a simpler approach: On ST_BORDER_ROW, we set all pixels to BORDER_COLOR.
                  // But that would require modifying all output data.

                  // However, the spec says: "the module processes an input AXI Stream data stream representing an image, adding a customizable border to the image."

                  // We can simply set the output data to border_color for all pixels during ST_BORDER_ROW.

                  // But the output data is 16-bit, so we need to set the whole field.

                  // Let's set m_axis_tdata to BORDER_COLOR repeated for the whole width and height.

                  // That seems too much, but it matches the requirement.

                  m_axis_tdata <= {BORDER_COLOR, BORDER_COLOR}[16*IMG_WIDTH];
                  m_axis_tvalid <= 1'b1;
                  m_axis_tready <= 1'b1;
                  m_axis_tlast <= 1'b0;
                  m_axis_tuser <= 1'b0;
              end
          endcase
      end
   end

   // Return signals
   always @(*) begin
      m_axis_tdata = {16'b0};
      m_axis_tvalid = 1'b1;
      m_axis_tready = 1'b1;
      m_axis_tlast = 1'b0;
      m_axis_tuser = 1'b0;
   end

endmodule
