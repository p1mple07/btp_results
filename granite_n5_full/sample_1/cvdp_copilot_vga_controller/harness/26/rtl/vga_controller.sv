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
    output logic blank      // BLANK to VGA connector
);

    parameter logic [9:0] H_ACTIVE  = 10'd640;
    parameter logic [9:0] H_FRONT   = 10'd16;
    parameter logic [9:0] H_PULSE   = 10'd96;
    parameter logic [9:0] H_BACK    = 10'd48;
    parameter logic [9:0] V_ACTIVE  = 10'd480;
    parameter logic [9:0] V_FRONT   = 10'd10;
    parameter logic [9:0] V_PULSE   = 10'd2;
    parameter logic [9:0] V_BACK    = 10'd33;
    parameter logic LOW   = 1'b0;
    parameter logic HIGH  = 1'b1;
    
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE  = 8'd1;
    parameter logic [7:0] H_PULSE_STATE  = 8'd2;
    parameter logic [7:0] H_BACK_STATE  = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE  = 8'd1;
    parameter logic [7:0] V_PULSE_STATE  = 8'd2;
    parameter logic [7:0] V_BACK_STATE  = 8'd33;

    // Code that needs to be included in the code

begin
    always_ff @(posedge clock or posedge reset
    assign line_done = HIGH;

    reg [7:0] h_counter;
    reg [7:0] v_counter;

    always_ff @(posedge clock or posedge reset
    always_ff @(posedge clock or posedge reset
    assign h_counter = 10'd0
    assign v_counter = 10'd0

    always_ff @(posedge clock or posedge reset
    assign h_counter = 10'd0
    assign v_counter = 10'd0

    always_ff @(posedge clock or posedge reset
    always_ff @(posedge clock or posedge reset
    assign h_counter = 10'd0
    assign v_counter = 10'd0

endmodule