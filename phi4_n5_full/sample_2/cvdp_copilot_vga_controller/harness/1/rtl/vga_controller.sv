module vga_controller (
    input  logic         clock,
    input  logic         reset,
    input  logic [7:0]   color_in,
    output logic         hsync,
    output logic         vsync,
    output logic [7:0]   red,
    output logic [7:0]   green,
    output logic [7:0]   blue,
    output logic [9:0]   next_x,
    output logic [9:0]   next_y,
    output logic         sync,
    output logic         clk,
    output logic         blank
);

   // Horizontal Timing Parameters
   parameter H_ACTIVE = 640;
   parameter H_FRONT  = 16;
   parameter H_PULSE  = 96;
   parameter H_BACK   = 48;
   localparam H_TOTAL = H_ACTIVE + H_FRONT + H_PULSE + H_BACK;  // 800

   // Vertical Timing Parameters
   parameter V_ACTIVE = 480;
   parameter V_FRONT  = 10;
   parameter V_PULSE  = 2;
   parameter V_BACK   = 33;
   localparam V_TOTAL = V_ACTIVE + V_FRONT + V_PULSE + V_BACK;  // 525

   // Counters for horizontal and vertical positions
   logic [9:0] h_counter;
   logic [9:0] v_counter;

   // All logic is implemented in a single always_ff block.
   always_ff @(posedge clock or posedge reset) begin
      if (reset) begin
         h_counter <= 10'd0;
         v_counter <= 10'd0;
         hsync     <= 1'b1;
         vsync     <= 1'b1;
         red       <= 8'd0;
         green     <= 8'd0;
         blue      <= 8'd0;
         next_x    <= 10'd0;
         next_y    <= 10'd0;
         sync      <= 1'b0;
         blank     <= 1'b0;
         clk       <= clock;  // Direct connection to input clock
      end
      else begin
         // Horizontal Counter: Increment each cycle; reset when end of line is reached.
         if (h_counter == H_TOTAL - 1) begin
            h_counter <= 10'd0;
            // At the end of a horizontal line, increment the vertical counter.
            if (v_counter == V_TOTAL - 1)
               v_counter <= 10'd0;
            else
               v_counter <= v_counter + 1;
         end
         else begin
            h_counter <= h_counter + 1;
         end

         // Generate hsync: ACTIVE (high) during active + front porch; LOW during horizontal sync pulse.
         if ((h_counter >= (H_ACTIVE + H_FRONT)) && (h_counter < (H_ACTIVE + H_FRONT + H_PULSE)))
            hsync <= 1'b0;
         else
            hsync <= 1'b1;

         // Generate vsync: ACTIVE (high) during active + front porch; LOW during vertical sync pulse.
         if ((v_counter >= (V_ACTIVE + V_FRONT)) && (v_counter < (V_ACTIVE + V_FRONT + V_PULSE)))
            vsync <= 1'b0;
         else
            vsync <= 1'b1;

         // Blank signal: ACTIVE HIGH when either hsync or vsync is low.
         blank <= (~hsync) | (~vsync);

         // RGB Color Outputs: During active region, output scaled color_in; otherwise, blank.
         if ((h_counter < H_ACTIVE) && (v_counter < V_ACTIVE)) begin
            red   <= {color_in[7:5], 5'd0};  // Scale red to 8 bits
            green <= {color_in[4:2], 5'd0};  // Scale green to 8 bits
            blue  <= {color_in[1:0], 6'd0};  // Scale blue to 8 bits
         end
         else begin
            red   <= 8'd0;
            green <= 8'd0;
            blue  <= 8'd0;
         end

         // Pixel Position Tracking: next_x and next_y reflect current counters when in active region.
         if ((h_counter < H_ACTIVE) && (v_counter < V_ACTIVE)) begin
            next_x <= h_counter;
            next_y <= v_counter;
         end
         else begin
            next_x <= 10'd0;
            next_y <= 10'd0;
         end

         // The sync signal is fixed at 0.
         sync <= 1'b0;

         // The clk output is directly connected to the input clock.
         clk <= clock;
      end
   end

endmodule