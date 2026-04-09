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
    output logic [7:0]   h_state,    // States of Horizontal FSM
    output logic [7:0]   v_state     // States of Vertical FSM
);

    // Timing parameters for horizontal timing
    parameter logic [9:0] H_ACTIVE  =  10'd640;
    parameter logic [9:0] H_FRONT   =  10'd16;
    parameter logic [9:0] H_PULSE   =  10'd96;
    parameter logic [9:0] H_BACK    =  10'd48;
    // Timing parameters for vertical timing
    parameter logic [9:0] V_ACTIVE  =  10'd480;
    parameter logic [9:0] V_FRONT   =  10'd10;
    parameter logic [9:0] V_PULSE   =  10'd2;
    parameter logic [9:0] V_BACK    =  10'd33;
    // Logic levels
    parameter logic LOW   = 1'b0;
    parameter logic HIGH  = 1'b1;
    // Horizontal state encoding
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    // Vertical state encoding
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    // Internal signals
    logic line_done;
    logic [9:0] h_counter;
    logic [9:0] v_counter;
    // Registers to hold previous sync values for blank calculation
    logic hsync_reg, vsync_reg;

    // Total periods
    localparam logic [9:0] T_H = H_ACTIVE + H_FRONT + H_PULSE + H_BACK; // 800
    localparam logic [9:0] T_V = V_ACTIVE + V_FRONT + V_PULSE + V_BACK; // 525

    // Main state machine: Horizontal and Vertical timing
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter   <= 10'd0;
            v_counter   <= 10'd0;
            h_state     <= H_ACTIVE_STATE;
            v_state     <= V_ACTIVE_STATE;
            line_done   <= LOW;
            hsync_reg   <= LOW;
            vsync_reg   <= LOW;
        end
        else begin
            // -------------------------------
            // Horizontal Timing FSM
            // -------------------------------
            case (h_state)
                H_ACTIVE_STATE: begin
                    if (h_counter < H_ACTIVE - 1) begin
                        h_counter <= h_counter + 1;
                        h_state   <= H_ACTIVE_STATE;
                    end
                    else begin
                        h_state   <= H_FRONT_STATE;
                        h_counter <= h_counter + 1;
                    end
                    hsync <= HIGH;
                end
                H_FRONT_STATE: begin
                    if (h_counter < (H_ACTIVE + H_FRONT) - 1) begin
                        h_counter <= h_counter + 1;
                        h_state   <= H_FRONT_STATE;
                    end
                    else begin
                        h_state   <= H_PULSE_STATE;
                        h_counter <= h_counter + 1;
                    end
                    hsync <= HIGH;
                end
                H_PULSE_STATE: begin
                    if (h_counter < (H_ACTIVE + H_FRONT + H_PULSE) - 1) begin
                        h_counter <= h_counter + 1;
                        h_state   <= H_PULSE_STATE;
                    end
                    else begin
                        h_state   <= H_BACK_STATE;
                        h_counter <= h_counter + 1;
                    end
                    hsync <= LOW;
                end
                H_BACK_STATE: begin
                    if (h_counter < T_H - 1) begin
                        h_counter <= h_counter + 1;
                        h_state   <= H_BACK_STATE;
                    end
                    else begin
                        h_state   <= H_ACTIVE_STATE;
                        h_counter <= 10'd0;
                        line_done <= HIGH;
                    end
                    hsync <= HIGH;
                end
            endcase

            // -------------------------------
            // Vertical Timing FSM
            // -------------------------------
            case (v_state)
                V_ACTIVE_STATE: begin
                    if (v_counter < V_ACTIVE - 1) begin
                        v_counter <= v_counter + 1;
                        v_state   <= V_ACTIVE_STATE;
                    end
                    else begin
                        v_state   <= V_FRONT_STATE;
                        v_counter <= v_counter + 1;
                    end
                    vsync <= HIGH;
                end
                V_FRONT_STATE: begin
                    if (v_counter < (V_ACTIVE + V_FRONT) - 1) begin
                        v_counter <= v_counter + 1;
                        v_state   <= V_FRONT_STATE;
                    end
                    else begin
                        v_state   <= V_PULSE_STATE;
                        v_counter <= v_counter + 1;
                    end
                    vsync <= HIGH;
                end
                V_PULSE_STATE: begin
                    if (v_counter < (V_ACTIVE + V_FRONT + V_PULSE) - 1) begin
                        v_counter <= v_counter + 1;
                        v_state   <= V_PULSE_STATE;
                    end
                    else begin
                        v_state   <= V_BACK_STATE;
                        v_counter <= v_counter + 1;
                    end
                    vsync <= LOW;
                end
                V_BACK_STATE: begin
                    if (v_counter < T_V - 1) begin
                        v_counter <= v_counter + 1;
                        v_state   <= V_BACK_STATE;
                    end
                    else begin
                        v_state   <= V_ACTIVE_STATE;
                        v_counter <= 10'd0;
                    end
                    vsync <= HIGH;
                end
            endcase

            // -------------------------------
            // Update sync registers for blank signal
            // -------------------------------
            hsync_reg <= hsync;
            vsync_reg <= vsync;

            // -------------------------------
            // RGB Signal Handling
            // -------------------------------
            // During active periods, drive RGB with color_in; otherwise, zero.
            if (h_state == H_ACTIVE_STATE && v_state == V_ACTIVE_STATE) begin
                red   <= color_in;
                green <= color_in;
                blue  <= color_in;
            end
            else begin
                red   <= 8'd0;
                green <= 8'd0;
                blue  <= 8'd0;
            end
        end
    end

    // Combinational assignments
    assign clk   = clock;
    assign sync  = 1'b0;
    assign blank = hsync_reg & vsync_reg;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule