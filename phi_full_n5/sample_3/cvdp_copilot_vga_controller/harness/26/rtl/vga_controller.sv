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
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    logic [9:0] h_counter;
    logic [9:0] v_counter;

    // Combine H_ACTIVE and V_ACTIVE states since they both reset
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter   <= 10'd0;
            v_counter   <= 10'd0;
            h_state     <= H_ACTIVE_STATE;
            v_state     <= V_ACTIVE_STATE;
            line_done   <= LOW;
        end
        else begin
            // Combine horizontal state logic
            case (h_state)
                H_ACTIVE_STATE: begin
                    h_counter <= (h_counter == H_ACTIVE - 1) ? 10'd0 : (h_counter + 10'd1);
                    hsync     <= HIGH;
                    line_done <= LOW;
                    h_state   <= (h_counter == H_FRONT - 1) ? H_PULSE_STATE : H_ACTIVE_STATE;
                end
                H_FRONT_STATE: begin
                    h_counter <= (h_counter == H_FRONT - 1) ? 10'd0 : (h_counter + 10'd1);
                    hsync     <= HIGH;
                    h_state   <= (h_counter == H_PULSE - 1) ? H_BACK_STATE : H_FRONT_STATE;
                end
                H_PULSE_STATE: begin
                    h_counter <= (h_counter == H_PULSE - 1) ? 10'd0 : (h_counter + 10'd1);
                    hsync     <= LOW;
                    h_state   <= (h_counter == H_BACK - 1) ? H_ACTIVE_STATE : H_BACK_STATE;
                    line_done <= (h_counter == H_BACK - 1) ? HIGH: LOW;
                end
                H_BACK_STATE: begin
                    h_counter <= (h_counter == H_BACK - 1) ? 10'd0 : (h_counter + 10'd1);
                    hsync     <= HIGH;
                    h_state   <= H_ACTIVE_STATE;
                    line_done <= HIGH;
                end
            endcase

            // Combine vertical state logic
            case (v_state)
                V_ACTIVE_STATE: begin
                    if (line_done == HIGH) begin
                        v_counter <= (v_counter == V_ACTIVE - 1) ? 10'd0 : (v_counter + 10'd1);
                        v_state   <= (v_counter == V_FRONT - 1) ? V_PULSE_STATE : V_ACTIVE_STATE;
                    end
                    vsync  <= HIGH;
                end
                V_FRONT_STATE: begin
                    if (line_done == HIGH) begin
                        v_counter <= (v_counter == V_FRONT - 1) ? 10'd0 : (v_counter + 10'd1);
                        v_state   <= (v_counter == V_PULSE - 1) ? V_BACK_STATE : V_FRONT_STATE;
                    end
                    vsync  <= HIGH;
                end
                V_PULSE_STATE: begin
                    if (line_done == HIGH) begin
                        v_counter <= (v_counter == V_PULSE - 1) ? 10'd0 : (v_counter + 10'd1);
                        v_state   <= (v_counter == V_BACK - 1) ? V_ACTIVE_STATE : V_PULSE_STATE;
                    end
                    vsync  <= LOW;
                end
                V_BACK_STATE: begin
                    if (line_done == HIGH) begin
                        v_counter <= (v_counter == V_BACK - 1) ? 10'd0 : (v_counter + 10'd1);
                        v_state   <= V_ACTIVE_STATE;
                    end
                end
            endcase

            // Combine color output logic
            if (h_state == H_ACTIVE_STATE && v_state == V_ACTIVE_STATE) begin
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

    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule
