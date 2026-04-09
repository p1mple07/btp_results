module vga_controller(
    input clock,
    input reset,
    input color_in,
    output hsync,
    output vsync,
    output red,
    output green,
    output blue,
    output next_x,
    output next_y,
    output blank
);

    // Horizontal State Machine
    state h_state, v_state;
    reg [9:0] h_counter, v_counter;

    // State Definitions
    // Horizontal States:
    // 0 - Active
    // 1 - Front Porch
    // 2 - Sync Pulse
    // 3 - Back Porch
    // Vertical States:
    // 0 - Active
    // 1 - Front Porch
    // 2 - Sync Pulse
    // 3 - Back Porch

    always_ff (posedge clock) begin
        case(reset)
            1: h_state = 0; v_state = 0; h_counter = 0; v_counter = 0; line_done = 0;
        endcase

        case(h_state)
            0: 
                if (line_done) begin
                    h_counter = 0;
                    h_state = 1;
                end
            1: 
                h_counter = h_counter + 1;
                if (h_counter == H_ACTIVE) begin
                    h_counter = 0;
                    h_state = 2;
                    vsync = 1;
                end
            2: 
                if (h_counter == H_FRONT) begin
                    h_counter = 0;
                    h_state = 3;
                    vsync = 0;
                end
            3: 
                if (h_counter == H_PULSE) begin
                    h_counter = 0;
                    h_state = 4;
                    vsync = 1;
                end
            4: 
                if (h_counter == H_BACK) begin
                    h_counter = 0;
                    h_state = 0;
                    vsync = 0;
                end
        endcase

        case(v_state)
            0: 
                if (vsync == 1) begin
                    v_counter = v_counter + 1;
                    if (v_counter == V_ACTIVE) begin
                        v_counter = 0;
                        v_state = 1;
                        hsync = 1;
                    end
                end
            1: 
                v_counter = v_counter + 1;
                if (v_counter == V_FRONT) begin
                    v_counter = 0;
                    v_state = 2;
                    hsync = 0;
                end
            2: 
                if (v_counter == V_PULSE) begin
                    v_counter = 0;
                    v_state = 3;
                    hsync = 1;
                end
            3: 
                if (v_counter == V_BACK) begin
                    v_counter = 0;
                    v_state = 0;
                    hsync = 0;
                end
        endcase
    end

    // Color Control
    always clock begin
        if (hsync == 1 || vsync == 1) begin
            red = (color_in[7:5] << 3) | (3'd0);
            green = (color_in[4:2] << 2) | (5'd0);
            blue = (color_in[1:0] << 1) | (6'd0);
        else begin
            red = 3'd0;
            green = 5'd0;
            blue = 6'd0;
        end
    end

    // Blank Signal
    blank = (hsync & vsync);

    // Synchronization Signal
    sync = 0;

    // Pixel Position Tracking
    next_x = h_counter;
    next_y = v_counter;

    // Active Mode Indicator
    line_done = 0;

    // Horizontal and Vertical Timing Parameters
    const H_ACTIVE = 640;
    const H_FRONT = 16;
    const H_PULSE = 96;
    const H_BACK = 48;
    const V_ACTIVE = 480;
    const V_FRONT = 10;
    const V_PULSE = 2;
    const V_BACK = 33;

endmodule