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
    output logic [9:0] h_counter, // Counter of horizontal position
    output logic [9:0] v_counter, // Counter of vertical position
    output logic [9:0] h_state, // States of Horizontal FSM
    output logic [9:0] v_state  // States of Vertical FSM
);

    parameter logic [9:0] H_ACTIVE  = 10'd640;
    parameter logic [9:0] H_FRONT   = 10'd16;
    parameter logic [9:0] H_PULSE   = 10'd2;
    parameter logic [9:0] H_BACK    = 10'd33;
    parameter logic [9:0] V_ACTIVE  = 10'd480;
    parameter logic [9:0] V_FRONT   = 10'd10;
    parameter logic [9:0] V_PULSE   = 10'd2;
    parameter logic [9:0] V_BACK    = 10'd33;
    parameter logic [9:0] H_ACTIVE_STATE  = 10'd0;
    parameter logic [9:0] H_FRONT_STATE   = 10'd1;
    parameter logic [9:0] H_PULSE_STATE = 10'd2;
    parameter logic [9:0] H_BACK_STATE   = 10'd33;
    parameter logic [9:0] V_ACTIVE_STATE  = 10'd0;
    parameter logic [9:0] V_FRONT_STATE   = 10'd1;
    parameter logic [9:0] V_PULSE_STATE = 10'd2;
    parameter logic [9:0] V_BACK_STATE   = 10'd33;

endmodule