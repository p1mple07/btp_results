module vga_controller (
    input  logic         clock,       // 25 MHz pixel clock
    input  logic         reset,       // Active-high asynchronous reset
    input  logic [7:0]   color_in,    // Pixel color in RRRGGGBB format

    output logic         hsync,       // Horizontal sync signal
    output logic         vsync,       // Vertical sync signal
    output logic [7:0]   red,         // Red channel output
    output logic [7:0]   green,       // Green channel output
    output logic [7:0]   blue,        // Blue channel output
    output logic [9:0]   next_x,      // Next pixel x-coordinate (active area)
    output logic [9:0]   next_y,      // Next pixel y-coordinate (active area)
    output logic         sync,        // Fixed sync signal (always 0)
    output logic         clk,         // VGA clock (directly connected to clock)
    output logic         blank        // Blank signal (active high during blanking)
);

    // Parameter definitions for horizontal timing
    parameter H_ACTIVE = 640;
    parameter H_FRONT  = 16;
    parameter H_PULSE  = 96;
    parameter H_BACK   = 48;
    parameter TOTAL_H  = H_ACTIVE + H_FRONT + H_PULSE + H_BACK; // 800

    // Parameter definitions for vertical timing
    parameter V_ACTIVE = 480;
    parameter V_FRONT  = 10;
    parameter V_PULSE  = 2;
    parameter V_BACK   = 33;
    parameter TOTAL_V  = V_ACTIVE + V_FRONT + V_PULSE + V_BACK; // 525

    // Internal registers for counters and outputs
    reg [9:0] h_counter;
    reg [9:0] v_counter;
    reg       line_done;   // Indicates end of horizontal frame
    reg [7:0] red_reg, green_reg, blue_reg;
    reg [9:0] next_x_reg, next_y_reg;
    reg       sync_reg;
    reg       blank_reg;

    // Single always_ff block implementing the entire logic
    always_ff @(posedge clock) begin
        if (reset) begin
            h_counter   <= 10'd0;
            v_counter   <= 10'd0;
            line_done   <= 1'b0;
            red_reg     <= 8'd0;
            green_reg   <= 8'd0;
            blue_reg    <= 8'd0;
            next_x_reg  <= 10'd0;
            next_y_reg  <= 10'd0;
            blank_reg   <= 1'b0;
            sync_reg    <= 1'b0;
        end else begin
            // Horizontal counter update and vertical counter increment at end of line
            if (h_counter == TOTAL_H - 1) begin
                line_done <= 1'b1;
                h_counter <= 10'd0;
                if (v_counter == TOTAL_V - 1)
                    v_counter <= 10'd0;
                else
                    v_counter <= v_counter + 1;
            end else begin
                h_counter <= h_counter + 1;
                line_done <= 1'b0;
            end

            // hsync generation: active high except during horizontal sync pulse period
            if ((h_counter >= (H_ACTIVE + H_FRONT)) && (h_counter < (H_ACTIVE + H_FRONT + H_PULSE)))
                hsync <= 1'b0;
            else
                hsync <= 1'b1;

            // vsync generation: active high except during vertical sync pulse period
            if ((v_counter >= (V_ACTIVE + V_FRONT)) && (v_counter < (V_ACTIVE + V_FRONT + V_PULSE)))
                vsync <= 1'b0;
            else
                vsync <= 1'b1;

            // Pixel position tracking for the next pixel coordinates
            if (h_counter < H_ACTIVE)
                next_x_reg <= h_counter;
            else
                next_x_reg <= 10'd0;

            if (v_counter < V_ACTIVE)
                next_y_reg <= v_counter;
            else
                next_y_reg <= 10'd0;

            // RGB output assignment based on active display region
            if ((h_counter < H_ACTIVE) && (v_counter < V_ACTIVE)) begin
                red_reg   <= {color_in[7:5], 5'd0};  // Scale red value
                green_reg <= {color_in[4:2], 5'd0};  // Scale green value
                blue_reg  <= {color_in[1:0], 6'd0};  // Scale blue value
            end else begin
                red_reg   <= 8'd0;
                green_reg <= 8'd0;
                blue_reg  <= 8'd0;
            end

            // Blank signal: active high when outside the active display area
            if ((h_counter >= H_ACTIVE) || (v_counter >= V_ACTIVE))
                blank_reg <= 1'b1;
            else
                blank_reg <= 1'b0;

            // sync is fixed to 0 as per design specification
            sync_reg <= 1'b0;
        end
    end

    // Continuous assignments for outputs
    assign red     = red_reg;
    assign green   = green_reg;
    assign blue    = blue_reg;
    assign next_x  = next_x_reg;
    assign next_y  = next_y_reg;
    assign sync    = sync_reg;
    assign clk     = clock;
    assign blank   = blank_reg;

endmodule