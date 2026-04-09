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
    output logic blank,     // BLANK to VGA connector
    output logic [7:0] h_state, // States of Horizontal FSM
    output logic [7:0] v_state  // States of Vertical FSM
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
    logic [7:0] h_counter;
    logic [9:0] v_counter;
    logic line_done;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;
            h_state <= H_ACTIVE;
            v_state <= V_ACTIVE;
            line_done <= LOW;
        else begin
            h_counter <= h_counter + 1;
            v_counter <= v_counter + 1;
            
            if (h_counter == H_PULSE) begin
                h_state <= H_BACK;
                h_counter <= 10'd0;
                line_done <= HIGH;
            end
            if (v_counter == V_PULSE) begin
                v_state <= V_BACK;
                v_counter <= 10'd0;
            end
        end
    end

    assign hsync = (h_state == H_BACK) ? 1 : 0;
    assign vsync = (v_state == V_BACK) ? 1 : 0;

    assign red = (color_in[7:5] & (h_state == H_ACTIVE)) | (color_in[7:5] & (h_state == H_FRONT) & (h_state != H_PULSE));
    assign green = (color_in[4:2] & (h_state == H_ACTIVE)) | (color_in[4:2] & (h_state == H_FRONT) & (h_state != H_PULSE));
    assign blue = (color_in[1:0] & (h_state == H_ACTIVE)) | (color_in[1:0] & (h_state == H_FRONT) & (h_state != H_PULSE));

    assign next_x = (h_state == H_ACTIVE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE) ? v_counter : 10'd0;
endmodule