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
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    logic [9:0] counter;
    logic [7:0] state;

    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            counter   <= 10'd0;
            state     <= H_ACTIVE_STATE;
            line_done <= LOW;
        end
        else begin
            case (state)
                H_ACTIVE_STATE: begin
                    counter <= (counter == H_ACTIVE - 1) ? 10'd0 : (counter + 1);
                    hsync     <= HIGH;
                    line_done <= LOW;
                    state     <= (counter == H_ACTIVE - 1) ? H_FRONT_STATE : H_ACTIVE_STATE;
                end
                H_FRONT_STATE: begin
                    counter <= (counter == H_FRONT - 1) ? 10'd0 : (counter + 1);
                    hsync     <= HIGH;
                    state     <= (counter == H_FRONT - 1) ? H_PULSE_STATE : H_FRONT_STATE;
                end
                H_PULSE_STATE: begin
                    counter <= (counter == H_PULSE - 1) ? 10'd0 : (counter + 1);
                    hsync     <= LOW;
                    state     <= (counter == H_PULSE - 1) ? H_BACK_STATE : H_PULSE_STATE;
                end
                H_BACK_STATE: begin
                    counter <= (counter == H_BACK - 1) ? 10'd0 : (counter + 1);
                    hsync     <= HIGH;
                    line_done <= (counter == H_BACK - 1) ? HIGH: LOW;
                    state     <= (counter == H_BACK - 1) ? H_ACTIVE_STATE : H_BACK_STATE;
                end
            endcase
            
            case (state)
                V_ACTIVE_STATE: begin
                    if (line_done == HIGH) begin
                        counter <= (counter == V_ACTIVE - 1) ? 10'd0 : (counter + 1);
                        vsync  <= HIGH;
                    end
                    state     <= (counter == V_ACTIVE - 1) ? V_FRONT_STATE : V_ACTIVE_STATE;
                end
                V_FRONT_STATE: begin
                    if (line_done == HIGH) begin
                        counter <= (counter == V_FRONT - 1) ? 10'd0 : (counter + 1);
                        vsync  <= HIGH;
                    end
                    state     <= (counter == V_FRONT - 1) ? V_PULSE_STATE : V_FRONT_STATE;
                end
                V_PULSE_STATE: begin
                    if (line_done == HIGH) begin
                        counter <= (counter == V_PULSE - 1) ? 10'd0 : (counter + 1);
                        vsync  <= LOW;
                    end
                    state     <= (counter == V_PULSE - 1) ? V_BACK_STATE : V_PULSE_STATE;
                end
                V_BACK_STATE: begin
                    if (line_done == HIGH) begin
                        counter <= (counter == V_BACK - 1) ? 10'd0 : (counter + 1);
                        vsync  <= HIGH;
                    end
                    state     <= (counter == V_BACK - 1) ? V_ACTIVE_STATE : V_BACK_STATE;
                end
            endcase
            if (state == H_ACTIVE_STATE && state == V_ACTIVE_STATE) begin
                red       <= {color_in[7:5], 5'd0};
                green     <= {color_in[4:2], 5'd0};
                blue      <= {color_in[1:0], 6'd0};
            end
            else begin
                red       <= 8'd0;
                green     <= 8'd0;
                blue      <= 8'd0;
            end
        end
    end
    
     
    assign clk = clock;
    assign sync = 1'b0;
    assign blank = hsync & vsync;

    assign next_x = (state == H_ACTIVE_STATE) ? counter : 10'd0;
    assign next_y = (state == V_ACTIVE_STATE) ? counter : 10'd0;

endmodule