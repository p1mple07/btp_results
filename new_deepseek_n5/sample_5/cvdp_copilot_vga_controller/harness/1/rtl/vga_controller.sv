module vga_controller(
    input clock,
    input reset,
    input color_in,
    output hsync,
    output vsync,
    output [7:0] red,
    output [7:0] green,
    output [7:0] blue,
    output next_x,
    output next_y,
    output blank
);

    // Horizontal State Machine
    state h_state = h_active;
    state v_state = v_active;

    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;

    // Horizontal State Transitions
    always_ff (posedge clock) begin
        case (h_state)
            h_active: 
                h_counter = h_counter + 1;
                if (h_counter == H_ACTIVE) begin
                    hsync = 1;
                    h_state = h_front;
                    h_counter = 0;
                end
            h_front: 
                if (h_counter == H_FRONT) begin
                    hsync = 0;
                    h_state = h_sync;
                    h_counter = 0;
                end
                h_counter = h_counter + 1;
            h_sync: 
                if (h_counter == H_PULSE) begin
                    hsync = 0;
                    h_state = h_back;
                    h_counter = 0;
                end
                h_counter = h_counter + 1;
            h_back: 
                if (h_counter == H_BACK) begin
                    hsync = 1;
                    h_state = h_active;
                    h_counter = 0;
                end
                h_counter = h_counter + 1;
        endcase
    end

    // Vertical State Machine
    always_ff (posedge clock) begin
        case (v_state)
            v_active: 
                v_counter = v_counter + 1;
                if (v_counter == V_ACTIVE) begin
                    vsync = 1;
                    v_state = v_front;
                    v_counter = 0;
                end
            v_front: 
                if (v_counter == V_FRONT) begin
                    vsync = 0;
                    v_state = v_sync;
                    v_counter = 0;
                end
                v_counter = v_counter + 1;
            v_sync: 
                if (v_counter == V_PULSE) begin
                    vsync = 0;
                    v_state = v_back;
                    v_counter = 0;
                end
                v_counter = v_counter + 1;
            v_back: 
                if (v_counter == V_BACK) begin
                    vsync = 1;
                    v_state = v_active;
                    v_counter = 0;
                end
                v_counter = v_counter + 1;
        endcase
    end

    // Color Control
    always clock begin
        case (h_state)
            h_active: 
                if (v_state == v_active) begin
                    red = (color_in[7:5] << 4) | (color_in[4:2] << 3) | (color_in[1:0] << 2);
                    green = (color_in[4:2] << 3) | (color_in[1:0] << 2);
                    blue = (color_in[1:0] << 2);
                else begin
                    red = 0;
                    green = 0;
                    blue = 0;
                end
            h_front: 
                red = 0;
                green = 0;
                blue = 0;
            h_sync: 
                red = 0;
                green = 0;
                blue = 0;
            h_back: 
                red = 0;
                green = 0;
                blue = 0;
        endcase
    end

    // Blank Signal
    blank = ~hsync & ~vsync;

    // Next_x and Next_y
    always clock begin
        next_x = h_counter;
        next_y = v_counter;
    end
endmodule