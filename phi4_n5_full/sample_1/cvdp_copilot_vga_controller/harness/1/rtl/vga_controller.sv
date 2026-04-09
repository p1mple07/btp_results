module vga_controller(
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

   //-------------------------------------------------------------------------
   // Timing Parameters for 640x480 @25MHz
   //-------------------------------------------------------------------------
   localparam integer H_ACTIVE  = 640;   // Active display pixels per row
   localparam integer H_FRONT   = 16;    // Front porch (in pixels)
   localparam integer H_PULSE   = 96;    // Horizontal sync pulse (in pixels)
   localparam integer H_BACK    = 48;    // Back porch (in pixels)
   localparam integer H_TOTAL   = H_ACTIVE + H_FRONT + H_PULSE + H_BACK; // 800 pixels per line

   localparam integer V_ACTIVE  = 480;   // Active display lines per frame
   localparam integer V_FRONT   = 10;    // Vertical front porch (in lines)
   localparam integer V_PULSE   = 2;     // Vertical sync pulse (in lines)
   localparam integer V_BACK    = 33;    // Vertical back porch (in lines)
   localparam integer V_TOTAL   = V_ACTIVE + V_FRONT + V_PULSE + V_BACK; // 525 lines per frame

   //-------------------------------------------------------------------------
   // Internal Registers
   //-------------------------------------------------------------------------
   reg [9:0] h_counter;
   reg [9:0] v_counter;
   reg hsync_reg;
   reg vsync_reg;
   reg blank_reg;
   reg [9:0] next_x_reg;
   reg [9:0] next_y_reg;
   reg [7:0] red_reg;
   reg [7:0] green_reg;
   reg [7:0] blue_reg;

   //-------------------------------------------------------------------------
   // Single always_ff Block: Sequential Logic & Signal Generation
   //-------------------------------------------------------------------------
   always_ff @(posedge clock or posedge reset) begin
      if (reset) begin
         h_counter    <= 10'd0;
         v_counter    <= 10'd0;
         hsync_reg    <= 1'b1;  // Start with active (HIGH) state
         vsync_reg    <= 1'b1;
         blank_reg    <= 1'b0;
         next_x_reg   <= 10'd0;
         next_y_reg   <= 10'd0;
         red_reg      <= 8'd0;
         green_reg    <= 8'd0;
         blue_reg     <= 8'd0;
      end
      else begin
         //-----------------------------------------------------------------
         // Horizontal Counter Update
         //-----------------------------------------------------------------
         if (h_counter == H_TOTAL - 1) begin
            h_counter <= 10'd0;
            // At end of horizontal line, update vertical counter
            if (v_counter == V_TOTAL - 1)
               v_counter <= 10'd0;
            else
               v_counter <= v_counter + 1;
         end
         else begin
            h_counter <= h_counter + 1;
         end

         //-----------------------------------------------------------------
         // Generate hsync Signal
         // hsync is HIGH during active and porch periods,
         // and LOW during the horizontal sync pulse.
         // Active + Front Porch: 0 to (H_ACTIVE + H_FRONT - 1) = 0 to 655
         // Sync Pulse: 656 to 751 (96 cycles)
         // Back Porch: 752 to 799 (48 cycles)
         //-----------------------------------------------------------------
         hsync_reg <= ((h_counter < (H_ACTIVE + H_FRONT)) ||
                       (h_counter >= (H_ACTIVE + H_FRONT + H_PULSE + H_BACK))) ? 1'b1 : 1'b0;

         //-----------------------------------------------------------------
         // Generate vsync Signal
         // vsync is HIGH during active and porch periods,
         // and LOW during the vertical sync pulse.
         // Active + Front Porch: 0 to 489
         // Sync Pulse: 490 to 491 (2 lines)
         // Back Porch: 492 to 524 (33 lines)
         //-----------------------------------------------------------------
         vsync_reg <= ((v_counter < (V_ACTIVE + V_FRONT)) ||
                       (v_counter >= (V_ACTIVE + V_FRONT + V_PULSE + V_BACK))) ? 1'b1 : 1'b0;

         //-----------------------------------------------------------------
         // Blank Signal: ACTIVE HIGH when outside the active display area.
         // Active display is when h_counter < H_ACTIVE and v_counter < V_ACTIVE.
         //-----------------------------------------------------------------
         blank_reg <= (h_counter >= H_ACTIVE) || (v_counter >= V_ACTIVE);

         //-----------------------------------------------------------------
         // Pixel Position Tracking: next_x and next_y are valid only during
         // the active region. Outside active region, they are set to 0.
         //-----------------------------------------------------------------
         next_x_reg <= (h_counter < H_ACTIVE) ? h_counter : 10'd0;
         next_y_reg <= (v_counter < V_ACTIVE) ? v_counter : 10'd0;

         //-----------------------------------------------------------------
         // Color Outputs: Use color_in during active display; blank otherwise.
         // red   = {color_in[7:5], 5'd0};
         // green = {color_in[4:2], 5'd0};
         // blue  = {color_in[1:0], 6'd0};
         //-----------------------------------------------------------------
         if ((h_counter < H_ACTIVE) && (v_counter < V_ACTIVE)) begin
            red_reg    <= {color_in[7:5], 5'd0};
            green_reg  <= {color_in[4:2], 5'd0};
            blue_reg   <= {color_in[1:0], 6'd0};
         end
         else begin
            red_reg    <= 8'd0;
            green_reg  <= 8'd0;
            blue_reg   <= 8'd0;
         end
      end
   end

   //-------------------------------------------------------------------------
   // Output Assignments
   //-------------------------------------------------------------------------
   assign hsync   = hsync_reg;
   assign vsync   = vsync_reg;
   assign red     = red_reg;
   assign green   = green_reg;
   assign blue    = blue_reg;
   assign next_x  = next_x_reg;
   assign next_y  = next_y_reg;
   assign sync    = 1'b0;   // Fixed to LOW as per design specification
   assign clk     = clock;  // Direct connection to input clock
   assign blank   = blank_reg;

endmodule