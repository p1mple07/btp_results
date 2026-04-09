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

    parameter logic [9:0] H_ACTIVE  =  10'd640;
    parameter logic [9:0] H_FRONT   =  10'd16;
    parameter logic [9:0] H_PULSE   =  10'd96;
    parameter logic [9:0] H_BACK    =  10'd48;
    parameter logic [9:0] V_ACTIVE  =  10'd480;
    parameter logic [9:0] V_FRONT   =  10'd10;
    parameter logic [9:0] V_PULSE   =  10'd2;
    parameter logic [9:0] V_BACK    =  10'd33;
    parameter logic LOW   = 1'b0;
    parameter logic HIGH  = 1'b1;

    logic line_done;
    logic [17:0] counter;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            counter <= 18'd0;
            line_done <= LOW;
        end
        else begin
            case (counter)
                18'd0: begin
                    h_state <= H_ACTIVE_STATE;
                    v_state <= V_ACTIVE_STATE;
                    line_done <= LOW;
                    counter <= 18'd1;
                end
                18'd1: begin
                    h_state <= H_FRONT_STATE;
                    v_state <= V_ACTIVE_STATE;
                    line_done <= LOW;
                    counter <= 18'd2;
                end
                18'd2: begin
                    h_state <= H_PULSE_STATE;
                    v_state <= V_ACTIVE_STATE;
                    line_done <= LOW;
                    counter <= 18'd3;
                end
                18'd3: begin
                    h_state <= H_BACK_STATE;
                    v_state <= V_ACTIVE_STATE;
                    line_done <= LOW;
                    counter <= 18'd4;
                end
                18'd4: begin
                    h_state <= H_ACTIVE_STATE;
                    v_state <= V_FRONT_STATE;
                    line_done <= LOW;
                    counter <= 18'd5;
                end
                18'd5: begin
                    h_state <= H_FRONT_STATE;
                    v_state <= V_PULSE_STATE;
                    line_done <= LOW;
                    counter <= 18'd6;
                end
                18'd6: begin
                    h_state <= H_PULSE_STATE;
                    v_state <= V_BACK_STATE;
                    line_done <= LOW;
                    counter <= 18'd7;
                end
                18'd7: begin
                    h_state <= H_BACK_STATE;
                    v_state <= V_ACTIVE_STATE;
                    line_done <= LOW;
                    counter <= 18'd8;
                end
                default: begin
                    if (line_done == HIGH) begin
                        if (counter == 18'd1 || counter == 18'd2) begin
                            counter <= 18'd0;
                            hsync <= HIGH;
                            vsync <= LOW;
                            line_done <= HIGH;
                        end
                        else if (counter == 18'd3 || counter == 18'd4) begin
                            counter <= 18'd0;
                            hsync <= LOW;
                            vsync <= HIGH;
                            line_done <= HIGH;
                        end
                        else if (counter == 18'd5 || counter == 18'd6) begin
                            counter <= 18'd0;
                            hsync <= HIGH;
                            vsync <= LOW;
                            line_done <= HIGH;
                        end
                        else if (counter == 18'd7 || counter == 18'd8) begin
                            counter <= 18'd0;
                            hsync <= LOW;
                            vsync <= HIGH;
                            line_done <= HIGH;
                        end
                        else begin
                            red <= color_in[7:5];
                            green <= color_in[4:2];
                            blue <= color_in[1:0];
                        end
                    end
                end
            endcase

            assign clk = clock;
            assign sync = 1'b0;
            assign blank = hsync & vsync;

            assign next_x = counter[9:0];
            assign next_y = counter[7:0];
        end
    end
endmodule
