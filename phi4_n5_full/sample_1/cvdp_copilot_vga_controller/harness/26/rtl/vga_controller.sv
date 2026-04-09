module vga_controller (
    input  logic         clock,      // 25 MHz
    input  logic         reset,      // Active high
    input  logic [7:0]   color_in,   // Pixel color data (RRRGGGBB)
    output logic [9:0]   next_x,     // x-coordinate of NEXT pixel that will be drawn
    output logic [9:0]   next_y,     // y-coordinate of NEXT pixel that will be drawn
    output logic         hsync,      // HSYNC (to VGA connector)
    output logic         vsync,      // VSYNC (to VGA connector)
    output logic [7:0]   red,        // RED (to resistor DAC VGA connector)
    output logic [7:0]   green,      // GREEN (to resistor DAC to VGA connector)
    output logic [7:0]   blue,       // BLUE (to resistor DAC to VGA connector)
    output logic         sync,       // SYNC to VGA connector
    output logic         clk,        // CLK to VGA connector
    output logic         blank,      // BLANK to VGA connector
    output logic [7:0]   h_state,    // Horizontal FSM state (derived)
    output logic [7:0]   v_state     // Vertical FSM state (derived)
);

    // Timing parameters
    parameter logic [9:0] H_ACTIVE  = 10'd640;
    parameter logic [9:0] H_FRONT   = 10'd16;
    parameter logic [9:0] H_PULSE   = 10'd96;
    parameter logic [9:0] H_BACK    = 10'd48;
    parameter logic [9:0] V_ACTIVE  = 10'd480;
    parameter logic [9:0] V_FRONT   = 10'd10;
    parameter logic [9:0] V_PULSE   = 10'd2;
    parameter logic [9:0] V_BACK    = 10'd33;
    parameter logic        LOW       = 1'b0;
    parameter logic        HIGH      = 1'b1;

    // FSM state encodings
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    // Total periods for modulo counters
    localparam [9:0] H_TOTAL = H_ACTIVE + H_FRONT + H_PULSE + H_BACK; // 800
    localparam [9:0] V_TOTAL = V_ACTIVE + V_FRONT + V_PULSE + V_BACK; // 525

    // Sequential counters replacing explicit FSM state registers
    logic [9:0] h_counter;
    logic [9:0] v_counter;

    // Always update horizontal counter and vertical counter only at line end
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;
        end else begin
            // Horizontal counter always increments modulo H_TOTAL
            h_counter <= (h_counter == H_TOTAL - 1) ? 10'd0 : h_counter + 10'd1;
            // Vertical counter increments only at the end of a horizontal line
            if (h_counter == H_TOTAL - 1)
                v_counter <= (v_counter == V_TOTAL - 1) ? 10'd0 : v_counter + 10'd1;
        end
    end

    // Combinational state decoding from counters
    assign h_state = (h_counter < H_ACTIVE) ? H_ACTIVE_STATE :
                     (h_counter < (H_ACTIVE + H_FRONT)) ? H_FRONT_STATE :
                     (h_counter < (H_ACTIVE + H_FRONT + H_PULSE)) ? H_PULSE_STATE : H_BACK_STATE;

    assign v_state = (v_counter < V_ACTIVE) ? V_ACTIVE_STATE :
                     (v_counter < (V_ACTIVE + V_FRONT)) ? V_FRONT_STATE :
                     (v_counter < (V_ACTIVE + V_FRONT + V_PULSE)) ? V_PULSE_STATE : V_BACK_STATE;

    // Generate synchronization signals based on state
    assign hsync = (h_state != H_PULSE_STATE) ? HIGH : LOW;
    assign vsync = (v_state != V_PULSE_STATE) ? HIGH : LOW;

    // Combinational pixel color generation
    always_comb begin
        if ((h_state == H_ACTIVE_STATE) && (v_state == V_ACTIVE_STATE))
        begin
            red   = {color_in[7:5], 5'd0};
            green = {color_in[4:2], 5'd0};
            blue  = {color_in[1:0], 6'd0};
        end
        else begin
            red   = 8'd0;
            green = 8'd0;
            blue  = 8'd0;
        end
    end

    // Other outputs
    assign clk   = clock;
    assign sync  = 1'b0;
    assign blank = hsync & vsync;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule