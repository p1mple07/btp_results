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

    // Timing parameters for horizontal and vertical cycles
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
    
    // FSM state encoding
    parameter logic [7:0] H_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] H_FRONT_STATE   = 8'd1;
    parameter logic [7:0] H_PULSE_STATE   = 8'd2;
    parameter logic [7:0] H_BACK_STATE    = 8'd3;
    parameter logic [7:0] V_ACTIVE_STATE  = 8'd0;
    parameter logic [7:0] V_FRONT_STATE   = 8'd1;
    parameter logic [7:0] V_PULSE_STATE   = 8'd2;
    parameter logic [7:0] V_BACK_STATE    = 8'd3;

    // Internal signals for sync outputs and counters
    logic hsync_reg;
    logic vsync_reg;
    
    logic line_done;
    logic [9:0] h_counter;
    logic [9:0] v_counter;
    
    // Assign outputs based on internal registers and state
    assign hsync  = hsync_reg;
    assign vsync  = vsync_reg;
    assign clk    = clock;
    assign sync   = 1'b0;
    assign blank  = hsync_reg & vsync_reg;
    assign next_x = (h_state == H_ACTIVE_STATE) ? h_counter : 10'd0;
    assign next_y = (v_state == V_ACTIVE_STATE) ? v_counter : 10'd0;
    
    // Main sequential block implementing both horizontal and vertical FSMs
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            h_counter   <= 10'd0;
            v_counter   <= 10'd0;
            h_state     <= H_ACTIVE_STATE;
            v_state     <= V_ACTIVE_STATE;
            line_done   <= LOW;
            hsync_reg   <= HIGH;
            vsync_reg   <= HIGH;
            red         <= 8'd0;
            green       <= 8'd0;
            blue        <= 8'd0;
        end
        else begin
            // -----------------------
            // Horizontal State Machine
            // -----------------------
            case (h_state)
                H_ACTIVE_STATE: begin
                    // Active display period: increment h_counter from 0 to H_ACTIVE-1
                    if (h_counter < H_ACTIVE - 1)
                        h_counter <= h_counter + 1;
                    else begin
                        // Transition to front porch
                        h_state <= H_FRONT_STATE;
                    end
                    hsync_reg <= HIGH;
                end
                
                H_FRONT_STATE: begin
                    // Front porch: count from H_ACTIVE to H_ACTIVE+H_FRONT-1
                    if (h_counter < H_ACTIVE + H_FRONT - 1)
                        h_counter <= h_counter + 1;
                    else begin
                        // Transition to horizontal sync pulse
                        h_state <= H_PULSE_STATE;
                    end
                    hsync_reg <= HIGH;
                end
                
                H_PULSE_STATE: begin
                    // Horizontal sync pulse: count for H_PULSE cycles
                    if (h_counter < H_ACTIVE + H_FRONT + H_PULSE - 1)
                        h_counter <= h_counter + 1;
                    else begin
                        // Transition to back porch
                        h_state <= H_BACK_STATE;
                    end
                    hsync_reg <= LOW;
                end
                
                H_BACK_STATE: begin
                    // Back porch: count until end of line
                    if (h_counter < H_ACTIVE + H_FRONT + H_PULSE + H_BACK - 1)
                        h_counter <= h_counter + 1;
                    else begin
                        // End of line: reset horizontal counter and signal vertical FSM
                        h_counter <= 10'd0;
                        h_state   <= H_ACTIVE_STATE;
                        line_done <= HIGH;
                    end
                    hsync_reg <= HIGH;
                end
            endcase
            
            // -------------------------
            // Vertical State Machine
            // -------------------------
            // v_counter increments only when a line is complete (line_done==HIGH)
            if (line_done) begin
                case (v_state)
                    V_ACTIVE_STATE: begin
                        // Active display period: increment v_counter for V_ACTIVE lines
                        if (v_counter < V_ACTIVE - 1)
                            v_counter <= v_counter + 1;
                        else begin
                            // Transition to vertical front porch
                            v_counter <= 10'd0;
                            v_state   <= V_FRONT_STATE;
                        end
                        vsync_reg <= HIGH;
                    end
                    
                    V_FRONT_STATE: begin
                        // Vertical front porch: count for V_FRONT lines
                        if (v_counter < V_ACTIVE + V_FRONT - 1)
                            v_counter <= v_counter + 1;
                        else begin
                            // Transition to vertical sync pulse
                            v_counter <= V_ACTIVE;
                            v_state   <= V_PULSE_STATE;
                        end
                        vsync_reg <= HIGH;
                    end
                    
                    V_PULSE_STATE: begin
                        // Vertical sync pulse: count for V_PULSE lines
                        if (v_counter < V_ACTIVE + V_FRONT + V_PULSE - 1)
                            v_counter <= v_counter + 1;
                        else begin
                            // Transition to vertical back porch
                            v_counter <= V_ACTIVE + V_FRONT;
                            v_state   <= V_BACK_STATE;
                        end
                        vsync_reg <= LOW;
                    end
                    
                    V_BACK_STATE: begin
                        // Vertical back porch: count until end of frame
                        if (v_counter < V_ACTIVE + V_FRONT + V_PULSE + V_BACK - 1)
                            v_counter <= v_counter + 1;
                        else begin
                            // End of frame: reset vertical counter and return to active state
                            v_counter <= 10'd0;
                            v_state   <= V_ACTIVE_STATE;
                        end
                        vsync_reg <= HIGH;
                    end
                endcase
            end
            
            // -------------------------
            // RGB Signal Handling
            // -------------------------
            // When in active display period, drive RGB with color_in; otherwise, output zeros.
            if ((h_state == H_ACTIVE_STATE) && (v_state == V_ACTIVE_STATE)) begin
                red   <= color_in;
                green <= color_in;
                blue  <= color_in;
            end else begin
                red   <= 8'd0;
                green <= 8'd0;
                blue  <= 8'd0;
            end
            
            // Clear line_done at the start of a new line
            if (h_state == H_ACTIVE_STATE)
                line_done <= LOW;
        end
    end

endmodule