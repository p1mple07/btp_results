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
    output wire            s_axis_tlast,     // Input last signal
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

   // AXI Stream Output Logic
   assign s_axis_tready = m_axis_tready;
   assign m_axis_tready = s_axis_tready;

   // FSM and Counter Logic
   always @(posedge clk or negedge resetn) begin
       if (!resetn) begin
           state <= ST_IDLE;
           x_count <= 0;
           y_count <= 0;
           border_valid <= 0;
       end else begin
           case (state)
               ST_IDLE: begin
                   if (s_axis_tuser) begin
                       state <= ST_ROW_FIRST;
                       x_count <= 0;
                   end else begin
                       next_state <= ST_IDLE;
                   end
               end
               ST_ROW_FIRST: begin
                   if (s_axis_tlast) begin
                       state <= ST_PROCESS_ROW;
                   end else begin
                       next_state <= ST_ROW_FIRST;
                   end
               end
               ST_PROCESS_ROW: begin
                   if (s_axis_tlast) begin
                       state <= ST_BORDER_ROW;
                       x_count <= IMG_WIDTH + 1;
                   end else begin
                       next_state <= ST_PROCESS_ROW;
                   end
               end
               ST_BORDER_ROW: begin
                   if (s_axis_tlast) begin
                       state <= ST_ROW_LAST;
                       y_count <= y_count + 1;
                   end else begin
                       next_state <= ST_BORDER_ROW;
                   end
               end
               ST_ROW_LAST: begin
                   state <= ST_IDLE;
               end
               default: begin
                   next_state <= ST_IDLE;
               end
           endcase
       end
   end

   // Valid Border Detection and Output Generation
   assign m_axis_tdata = (is_border_pixel) ? BORDER_COLOR : s_axis_tdata & DATA_MASK;
   assign m_axis_tvalid = (state == ST_PROCESS_ROW) | (state == ST_BORDER_ROW);
   assign m_axis_tlast = s_axis_tlast;
   assign m_axis_tuser = s_axis_tuser;

endmodule
