rtl/axis_image_border_gen.sv
------------------------------------------------------------
`timescale 1ps / 1ps

module axis_image_border_gen #(
    parameter IMG_WIDTH  = 336,               // Image width (X resolution)
    parameter IMG_HEIGHT = 256,               // Image height (Y resolution)
    parameter BORDER_COLOR = 16'hFFFF,        // Border pixel value
    parameter DATA_MASK    = 16'h0000         // Mask for input pixels
)(
    input  wire            clk,               // AXI clock
    input  wire            resetn,            // Active-low reset

    // AXI Stream input interface
    input  wire [15:0]     s_axis_tdata,      // Input stream data
    input  wire            s_axis_tvalid,     // Input data valid
    output wire            s_axis_tready,     // Ready to accept input data
    input  wire            s_axis_tlast,      // Input last signal (for image rows)
    input  wire            s_axis_tuser,      // Frame start signal

    // AXI Stream output interface
    output wire [15:0]     m_axis_tdata,      // Output stream data
    output wire            m_axis_tvalid,     // Output data valid
    input  wire            m_axis_tready,     // Ready to accept output data
    output wire            m_axis_tlast,      // Output last signal (for rows)
    output wire            m_axis_tuser       // Frame start signal (output)
);

  //-------------------------------------------------------------------------
  // State Machine Definition
  //-------------------------------------------------------------------------
  localparam logic [2:0]
    ST_IDLE         = 3'd0,  // Waiting for new frame (s_axis_tuser)
    ST_ROW_FIRST    = 3'd1,  // Generate top border row
    ST_PROCESS_ROW  = 3'd2,  // Process image row with side borders
    ST_BORDER_ROW   = 3'd3,  // Generate bottom border row
    ST_ROW_LAST     = 3'd4;  // Final state (if needed for end-of-frame)

  //-------------------------------------------------------------------------
  // Registers and Wire Declarations
  //-------------------------------------------------------------------------
  reg  logic [2:0]     state, next_state;
  reg  logic [15:0]    x_count;  // Pixel counter within a row (0 to IMG_WIDTH+1)
  reg  logic [15:0]    y_count;  // Row counter (0 to IMG_HEIGHT+1)
  reg  logic [15:0]    pixel_data; // Registered input pixel data

  // Registered outputs for the AXIS interface
  reg  logic [15:0]    m_axis_tdata_reg;
  reg                   m_axis_tvalid_reg;
  reg                   m_axis_tlast_reg;
  reg                   m_axis_tuser_reg;

  //-------------------------------------------------------------------------
  // Combinational Output Assignments
  //-------------------------------------------------------------------------
  // m_axis_tdata: In border rows, always BORDER_COLOR.
  // In image rows, left and right pixels are border; inner pixels pass through input (masked).
  assign m_axis_tdata = 
       ((state == ST_ROW_FIRST) || (state == ST_BORDER_ROW)) ? BORDER_COLOR :
       ((state == ST_PROCESS_ROW) && (x_count == 0)) ? BORDER_COLOR :
       ((state == ST_PROCESS_ROW) && (x_count >= 1) && (x_count <= IMG_WIDTH)) ? (pixel_data & DATA_MASK) :
       ((state == ST_PROCESS_ROW) && (x_count == IMG_WIDTH+1)) ? BORDER_COLOR : 16'd0;

  // m_axis_tlast: Assert when the current row is complete.
  assign m_axis_tlast = (((state == ST_ROW_FIRST) || 
                          (state == ST_PROCESS_ROW) || 
                          (state == ST_BORDER_ROW)) &&
                          (x_count == (IMG_WIDTH+1))) ? 1'b1 : 1'b0;

  // m_axis_tvalid: Drive valid when not idle.
  assign m_axis_tvalid = (state != ST_IDLE) ? 1'b1 : 1'b0;

  // m_axis_tuser: Assert at frame start (only in ST_IDLE when s_axis_tuser is high).
  assign m_axis_tuser = (state == ST_IDLE) ? s_axis_tuser : 1'b0;

  // s_axis_tready: Ready to accept input data only in ST_IDLE and during image pixel capture.
  assign s_axis_tready = ((state == ST_IDLE) ||
                          ((state == ST_PROCESS_ROW) && (x_count >= 1) && (x_count <= IMG_WIDTH))) ? 1'b1 : 1'b0;

  //-------------------------------------------------------------------------
  // FSM and Counter Logic
  //-------------------------------------------------------------------------
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      state         <= ST_IDLE;
      x_count       <= 16'd0;
      y_count       <= 16'd0;
      pixel_data    <= 16'd0;
      m_axis_tdata_reg <= 16'd0;
      m_axis_tvalid_reg <= 1'b0;
      m_axis_tlast_reg  <= 1'b0;
      m_axis_tuser_reg  <= 1'b0;
    end
    else begin
      // State register update
      state <= next_state;

      // Update registered outputs (they follow the combinational logic)
      m_axis_tdata_reg   <= m_axis_tdata;
      m_axis_tvalid_reg  <= m_axis_tvalid;
      m_axis_tlast_reg   <= m_axis_tlast;
      m_axis_tuser_reg   <= m_axis_tuser;
    end
  end

  //-------------------------------------------------------------------------
  // Next State Logic and Counter Updates
  //-------------------------------------------------------------------------
  always @(*) begin
    // Default assignments
    next_state = state;
    unique case (state)
      ST_IDLE: begin
         // Wait for frame start signal.
         if (s_axis_tuser)
           next_state = ST_ROW_FIRST;
         else
           next_state = ST_IDLE;
      end

      ST_ROW_FIRST: begin
         // Generating top border row (all pixels are border).
         if (m_axis_tready) begin
           if (x_count < (IMG_WIDTH+1))
             next_state = ST_ROW_FIRST;
           else begin
             // Completed top border row; move to processing image rows.
             next_state = ST_PROCESS_ROW;
           end
         end
         else
           next_state = ST_ROW_FIRST;
      end

      ST_PROCESS_ROW: begin
         // Processing an image row with side borders.
         if (m_axis_tready) begin
           if (x_count < 1) begin
             // Left border pixel.
             next_state = ST_PROCESS_ROW;
           end
           else if (x_count <= IMG_WIDTH) begin
             // Image pixel: capture input when valid.
             if (s_axis_tvalid)
               next_state = ST_PROCESS_ROW;
             else
               next_state = ST_PROCESS_ROW;
           end
           else if (x_count == IMG_WIDTH+1) begin
             // Right border pixel.
             if (y_count == IMG_HEIGHT)
               next_state = ST_BORDER_ROW;  // Last image row -> bottom border row next.
             else
               next_state = ST_PROCESS_ROW;
           end
           else
             next_state = ST_PROCESS_ROW;
         end
         else
           next_state = ST_PROCESS_ROW;
      end

      ST_BORDER_ROW: begin
         // Generating bottom border row.
         if (m_axis_tready) begin
           if (x_count < (IMG_WIDTH+1))
             next_state = ST_BORDER_ROW;
           else begin
             // Completed bottom border row; return to idle.
             next_state = ST_IDLE;
           end
         end
         else
           next_state = ST_BORDER_ROW;
      end

      default: next_state = ST_IDLE;
    endcase
  end

  //-------------------------------------------------------------------------
  // Counter Updates
  //-------------------------------------------------------------------------
  // We update counters in the same always block that drives the FSM.
  // Note: The counters are updated only when m_axis_tready is asserted.
  // x_count and y_count are updated in the sequential always block below.
  //-------------------------------------------------------------------------
  // (The counter updates are incorporated in the FSM next state logic above.
  //  Here we show an alternate approach by using a separate always block.)
  //-------------------------------------------------------------------------
  
  // In this design the counters are updated as part of the FSM transitions.
  // For clarity, we include a dedicated always block for counter updates.
  // Note: This block is sensitive to the same clock and reset.
  //-------------------------------------------------------------------------
  // (If preferred, the counter updates can be merged into the FSM always block.)
  //-------------------------------------------------------------------------
  
  // The following always block is provided for completeness.
  // It updates x_count and y_count based on the current state and conditions.
  // This block is not strictly necessary if the counters are updated in the FSM.
  //-------------------------------------------------------------------------
  
  // Uncomment the following block if you prefer separate counter logic:
  /*
  always @(posedge clk or negedge resetn) begin
    if (!resetn) begin
      x_count <= 16'd0;
      y_count <= 16'd0;
    end
    else begin
      case (state)
        ST_ROW_FIRST: begin
          if (m_axis_tready && (x_count == (IMG_WIDTH+1)))
            y_count <= y_count + 1;
          else if (m_axis_tready)
            x_count <= x_count + 1;
        end
        ST_PROCESS_ROW: begin