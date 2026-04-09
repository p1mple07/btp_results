module vga_controller (
  input  logic clock,
  input  logic reset,
  input  logic [7:0] color_in,
  output logic hsync,
  output logic vsync,
  output logic [7:0] red,
  output logic [7:0] green,
  output logic [7:0] blue,
  output logic [9:0] next_x,
  output logic [9:0] next_y,
  output logic sync,
  output logic clk,
  output logic blank
);

  // Timing parameters for 640x480 VGA
  localparam integer H_ACTIVE   = 640;
  localparam integer H_FRONT    = 16;
  localparam integer H_PULSE    = 96;
  localparam integer H_BACK     = 48;
  localparam integer H_TOTAL    = H_ACTIVE + H_FRONT + H_PULSE + H_BACK; // 800 cycles

  localparam integer V_ACTIVE   = 480;
  localparam integer V_FRONT    = 10;
  localparam integer V_PULSE    = 2;
  localparam integer V_BACK     = 33;
  localparam integer V_TOTAL    = V_ACTIVE + V_FRONT + V_PULSE + V_BACK; // 525 lines

  // Counters for horizontal and vertical timing
  reg [9:0] h_counter;
  reg [9:0] v_counter;
  reg       line_done;  // Indicates end of horizontal line

  // Registered outputs (all logic updated on the positive clock edge)
  reg [7:0] red_reg;
  reg [7:0] green_reg;
  reg [7:0] blue_reg;
  reg [9:0] next_x_reg;
  reg [9:0] next_y_reg;
  reg       hsync_reg;
  reg       vsync_reg;
  reg       blank_reg;
  reg       sync_reg;
  reg       clk_reg;

  // Single always_ff block implementing state machines and output logic
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      h_counter  <= 10'd0;
      v_counter  <= 10'd0;
      line_done  <= 1'b0;
      hsync_reg  <= 1'b1;
      vsync_reg  <= 1'b1;
      red_reg    <= 8'd0;
      green_reg  <= 8'd0;
      blue_reg   <= 8'd0;
      next_x_reg <= 10'd0;
      next_y_reg <= 10'd0;
      blank_reg  <= 1'b0;
      sync_reg   <= 1'b0;
      clk_reg    <= 1'b0;
    end else begin
      // Determine if the current horizontal line is complete.
      // (Using the previous value of h_counter to set line_done.)
      if (h_counter == H_TOTAL - 1)
        line_done <= 1'b1;
      else
        line_done <= 1'b0;
        
      // Update horizontal counter.
      if (h_counter == H_TOTAL - 1)
        h_counter <= 10'd0;
      else
        h_counter <= h_counter + 1;
        
      // Update vertical counter only at the end of a horizontal line.
      if (line_done) begin
        if (v_counter == V_TOTAL - 1)
          v_counter <= 10'd0;
        else
          v_counter <= v_counter + 1;
      end
      
      // Generate hsync signal.
      // hsync is HIGH during H_ACTIVE, H_FRONT, and H_BACK periods;
      // it is LOW during the H_PULSE (sync pulse) period.
      if ((h_counter < H_ACTIVE) ||
          (h_counter >= H_ACTIVE && h_counter < H_ACTIVE + H_FRONT) ||
          (h_counter >= H_ACTIVE + H_FRONT + H_PULSE &&
           h_counter < H_ACTIVE + H_FRONT + H_PULSE + H_BACK))
        hsync_reg <= 1'b1;
      else
        hsync_reg <= 1'b0;
        
      // Generate vsync signal.
      // vsync is HIGH during V_ACTIVE+V_FRONT and V_BACK periods;
      // it is LOW during the V_PULSE (sync pulse) period.
      if ((v_counter < V_ACTIVE + V_FRONT) ||
          (v_counter >= V_ACTIVE + V_FRONT + V_PULSE &&
           v_counter < V_ACTIVE + V_FRONT + V_PULSE + V_BACK))
        vsync_reg <= 1'b1;
      else
        vsync_reg <= 1'b0;
        
      // Pixel position tracking: next_x and next_y are valid only during the active display area.
      if (h_counter < H_ACTIVE)
        next_x_reg <= h_counter;
      else
        next_x_reg <= 10'd0;
        
      if (v_counter < V_ACTIVE)
        next_y_reg <= v_counter;
      else
        next_y_reg <= 10'd0;
        
      // RGB output control.
      // When within the active region, scale color_in to 8-bit values:
      //   red   = {color_in[7:5], 5'd0};
      //   green = {color_in[4:2], 5'd0};
      //   blue  = {color_in[1:0], 6'd0};
      // Otherwise, output 0.
      if (h_counter < H_ACTIVE && v_counter < V_ACTIVE) begin
        red_reg    <= {color_in[7:5], 5'd0};
        green_reg  <= {color_in[4:2], 5'd0};
        blue_reg   <= {color_in[1:0], 6'd0};
      end else begin
        red_reg    <= 8'd0;
        green_reg  <= 8'd0;
        blue_reg   <= 8'd0;
      end
      
      // Blank signal: ACTIVE HIGH when not in the active display region.
      if ((h_counter >= H_ACTIVE) || (v_counter >= V_ACTIVE))
        blank_reg <= 1'b1;
      else
        blank_reg <= 1'b0;
        
      // Sync signal is fixed to LOW.
      sync_reg <= 1'b0;
      
      // VGA clock is directly connected to the input clock.
      clk_reg <= clock;
    end
  end

  // Drive module outputs from registered signals.
  assign hsync   = hsync_reg;
  assign vsync   = vsync_reg;
  assign red     = red_reg;
  assign green   = green_reg;
  assign blue    = blue_reg;
  assign next_x  = next_x_reg;
  assign next_y  = next_y_reg;
  assign sync    = sync_reg;
  assign clk     = clk_reg;
  assign blank   = blank_reg;

endmodule