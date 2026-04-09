module vga_controller(
    input clock,
    input reset,
    input color_in,
    output hsync,
    output vsync,
    output [7:0] red, green, blue,
    output [9:0] next_x, next_y
);

    // Horizontal State Machine
    state h_state = h_state_initial;
    reg h_state_state = h_state_initial;

    state v_state = v_state_initial;
    reg v_state_state = v_state_initial;

    // Counters
    reg h_counter = 0;
    reg v_counter = 0;

    // Color Control
    reg [7:0] color_red = 0;
    reg [7:0] color_green = 0;
    reg [7:0] color_blue = 0;

    // State Transitions
    always_edge clock begin
        case (h_state_state)
            h_state_initial: 
                h_counter = 0;
                v_counter = 0;
                h_state = h_active;
                v_state = v_active;
                blank = 0;
                line_done = 0;
                vsync = 1;
                vsync = 0;
            h_active:
                h_counter = h_counter + 1;
                if (h_counter == h_active) h_counter = 0;
                if (h_counter == h_front) begin
                    hsync = 1;
                    h_state = h_front porch;
                    vsync = 0;
                end else if (h_counter == h_pulse) begin
                    hsync = 0;
                    h_state = h_back porch;
                    vsync = 0;
                end else if (h_counter == h_back) h_state = h_active;
            h_front porch:
                h_counter = h_counter + 1;
                if (h_counter == h_back) begin
                    hsync = 0;
                    h_state = h_back porch;
                    vsync = 0;
                else vsync = 1;
                vsync = 0;
                h_counter = h_counter + 1;
                if (h_counter == h_active) h_state = h_active;
            h_back porch:
                h_counter = h_counter + 1;
                if (h_counter == h_active) h_state = h_active;
                vsync = 1;
        endcase

        case (v_state_state)
            v_state_initial:
                v_counter = 0;
                v_state = v_active;
                vsync = 1;
                line_done = 0;
                blank = 0;
            v_active:
                v_counter = v_counter + 1;
                if (v_counter == v_active) v_counter = 0;
                if (v_counter == v_front) v_state = v_front porch;
                else if (v_counter == v_pulse) begin
                    vsync = 0;
                    v_state = v_back porch;
                    line_done = 1;
                end else if (v_counter == v_back) v_state = v_active;
            v_front porch:
                v_counter = v_counter + 1;
                if (v_counter == v_back) begin
                    vsync = 0;
                    v_state = v_back porch;
                    line_done = 1;
                else line_done = 0;
                v_counter = v_counter + 1;
                if (v_counter == v_active) v_state = v_active;
            v_back porch:
                v_counter = v_counter + 1;
                if (v_counter == v_active) v_state = v_active;
                vsync = 1;
        endcase
    end

    // Color Control Logic
    always h_state_state, v_state_state, h_counter, v_counter begin
        if (h_state_state == h_active || v_state_state == v_active) begin
            if (color_in[7:5]) red = 128;
            else red = 0;
            if (color_in[4:2]) green = 128;
            else green = 0;
            if (color_in[1:0]) blue = 128;
            else blue = 0;
        else begin
            red = 0;
            green = 0;
            blue = 0;
        end
    end

    // Blank Signal
    blank = hsync & vsync;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

    // Synchronous Output Signals
    hsync = 1;
    vsync = 1;
    blank = 0;

endmodule