module vga_controller (
    input logic clock,      // 25 MHz
    input logic reset,      // Active high
    input logic [7:0] color_in, // Pixel color data (RRRGGGBB)
    output logic [9:0] next_x,  // x-coordinate of NEXT pixel that will be drawn
    output logic [9:0] next_y,  // y-coordinate of NEXT pixel that will be drawn
    output logic hsync,     // HSYNC (to VGA connector)
    output logic vsync,     // VSYNC (to VGA connector)
    output logic [7:0] red, // RED (to resistor DAC VGA connector)
    output logic [7:0] green, // GREEN (to resistor DAC to VGA connector)
    output logic [7:0] blue, // BLUE (to resistor DAC to VGA connector)
    output logic sync,      // SYNC to VGA connector
    output logic clk,       // CLK to VGA connector
    output logic blank,      // BLANK to VGA connector
    output logic [7:0] h_state, // States of Horizontal FSM
    output logic [7:0] v_state, // States of Vertical FSM
);

    // Parameterized Constants for H/W (e.g. number of pixels per row).

    localparam H_ACTIVE  = 10'd640;
    localparam H_FRONT   = 10'd16;
    localparam H_PULSE   = 10'd96;
    localparam H_BACK    = 10'd48;
    localparam V_ACTIVE  = 10'd480;
    localparam V_FRONT   = 10'd10;
    localparam V_PULSE   = 10'd2;
    localparam V_BACK    = 10'd33;
    localparam LOW   = 1'b0;
    localparam HIGH  = 1'b1;
    localparam H_ACTIVE_STATE  = 8'd0;
    localparam H_FRONT_STATE   = 8'd1;
    localparam H_PULSE_STATE   = 8'd2;
    localparam H_BACK_STATE    = 8'd3;

    // Define the module inputs and outputs using the "input" and "output" statements.
    input logic clock,      // 25 MHz
    input logic reset,      // Active high
    input logic [7:0] color_in, // Pixel color data (RRRGGGBB)
    output logic [9:0] next_x,  // x-coordinate of NEXT pixel that will be drawn
    output logic [9:0] next_y,  // y-coordinate of NEXT pixel that will be drawn
    output logic hsync,     // HSYNC (to VGA connector)
    output logic vsync,     // VSYNC (to VGA connector)
    output logic [7:0] red,  // RED (to resistor DAC VGA connector
    output logic [7:0] green,  // GREEN (to resistor DAC to VGA connector
    output logic [7:0] blue,  // BLUE (to resistor DAC to VGA connector
    output logic sync,      // SYNC to VGA connector
    output logic clk,       // CLK to VGA connector
    output logic blank,      // BLANK to VGA connector
    output logic [7:0] h_state,  // States of Horizontal FSM
    output logic [7:0] v_state,  // States of Vertical FSM
endmodule