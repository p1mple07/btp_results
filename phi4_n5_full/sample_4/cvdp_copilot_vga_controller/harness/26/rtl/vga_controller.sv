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

    // Timing and state parameters
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
    parameter logic [7:0]  H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0]  H_FRONT_STATE   = 8'd1;
    parameter logic [7:0]  H_PULSE_STATE   = 8'd2;
    parameter logic [7:0]  H_BACK_STATE    = 8'd3;
    parameter logic [7:0]  V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0]  V_FRONT_STATE   = 8'd1;
    parameter logic [7:0]  V_PULSE_STATE   = 8'd2;
    parameter logic [7:0]  V_BACK_STATE    = 8'd3;

    // Internal signals
    logic                    line_done;
    logic [9:0]              h_counter;
    logic [9:0]              v_counter;

    // ---------------------------------------------------------------------
    // Sequential block for horizontal and vertical FSM updates.
    // This block minimizes redundant assignments by consolidating
    // counter and state updates.
    // ---------------------------------------------------------------------
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter <= 10'd0;
            v_counter <= 10'd0;
            h_state   <= H_ACTIVE_STATE;
            v_state   <= V_ACTIVE_STATE;
            line_done <= LOW;
        end
        else begin
            // -------------------------------
            // Horizontal FSM update
            // -------------------------------
            case (h_state)
                H_ACTIVE_STATE: begin
                    if (h_counter == H_ACTIVE - 1) begin
                        h_counter <= 10'd0;
                        h_state   <= H_FRONT_STATE;
                        line_done <= LOW;
                    end
                    else begin
                        h_counter <= h_counter + 10'd1;
                        h_state   <= H_ACTIVE_STATE;
                        line_done <= LOW;
                    end
                end
                H_FRONT_STATE: begin
                    if (h_counter == H_FRONT - 1) begin
                        h_counter <= 10'd0;
                        h_state   <= H_PULSE_STATE;
                    end
                    else begin
                        h_counter <= h_counter + 10'd1;
                        h_state   <= H_FRONT_STATE;
                    end
                    line_done <= LOW;
                end
                H_PULSE_STATE: begin
                    if (h_counter == H_PULSE - 1) begin
                        h_counter <= 10'd0;
                        h_state   <= H_BACK_STATE;
                    end
                    else begin
                        h_counter <= h_counter + 10'd1;
                        h_state   <= H_PULSE_STATE;
                    end
                    line_done <= LOW;
                end
                H_BACK_STATE: begin
                    if (h_counter == H_BACK - 1) begin
                        h_counter <= 10'd0;
                        h_state   <= H_ACTIVE_STATE;
                        line_done <= HIGH;
                    end
                    else begin
                        h_counter <= h_counter + 10'd1;
                        h_state   <= H_BACK_STATE;
                        line_done <= LOW;
                    end
                end
            endcase

            // -------------------------------
            // Vertical FSM update (triggered by line_done)
            // -------------------------------
            case (v_state)
                V_ACTIVE_STATE: begin
                    if (line_done) begin
                        if (v_counter == V_ACTIVE - 1)
                            v_state <= V_FRONT_STATE;
                        else
                            v_state <= V_ACTIVE_STATE;
                        v_counter <= (v_counter == V_ACTIVE - 1) ? 10'd0 : v_counter + 10'd1;
                    end
                end
                V_FRONT_STATE: begin
                    if (line_done) begin
                        if (v_counter == V_FRONT - 1)
                            v_state <= V_PULSE_STATE;
                        else
                            v_state <= V_FRONT_STATE;
                        v_counter <= (v_counter == V_FRONT - 1) ? 10'd0 : v_counter + 10'd1;
                    end
                end
                V_PULSE_STATE: begin
                    if (line_done) begin
                        if (v_counter == V_PULSE - 1)
                            v_state <= V_BACK_STATE;
                        else
                            v_state <= V_PULSE_STATE;
                        v_counter <= (v_counter == V_PULSE - 1) ? 10'd0 : v_counter + 10'd1;
                    end
                end
                V_BACK_STATE: begin
                    if (line_done) begin
                        if (v_counter == V_BACK - 1)
                            v_state <= V_ACTIVE_STATE;
                        else
                            v_state <= V_BACK_STATE;
                        v_counter <= (v_counter == V_BACK - 1) ? 10'd0 : v_counter + 10'd1;
                    end
                end
            endcase

            // -------------------------------
            // Color assignment based on active video state
            // -------------------------------
            if (h_state == H_ACTIVE_STATE && v_state == V_ACTIVE_STATE) begin
                red   <= {color_in[7:5], 5'd0};
                green <= {color_in[4:2], 5'd0};
                blue  <= {color_in[1:0], 6'd0};
            end
            else begin
                red   <= 8'd0;
                green <= 8'd0;
                blue  <= 8'd0;
            end
        end
    end

    // ---------------------------------------------------------------------
    // Optimized generation of hsync and vsync signals.
    // These signals are derived from the FSM state registers using simple
    // combinational expressions, and then registered to preserve the 1-cycle
    // latency.
    // ---------------------------------------------------------------------
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            hsync <= HIGH;
            vsync <= HIGH;
        end
        else begin
            // hsync is LOW only in the H_PULSE_STATE.
            hsync <= (h_state != H_PULSE_STATE) ? HIGH : LOW;
            // vsync is LOW only in the V_PULSE_STATE.
            vsync <= (v_state != V_PULSE_STATE) ? HIGH : LOW;
        end
    end

    // ---------------------------------------------------------------------
    // Combinational assignments for other outputs
    // ---------------------------------------------------------------------
    assign clk    = clock;
    assign sync   = 1'b0;
    assign blank  = hsync & vsync;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;

endmodule