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
    output sync,
    output blank
);

    // Horizontal State Machine
    reg [3:0] h_state = 3;
    reg h_counter = 0;
    // Vertical State Machine
    reg [3:0] v_state = 3;
    reg v_counter = 0;

    // Horizontal FSM
    always_ff (posedge clock) begin
        case (h_state)
            3: // Active
                h_counter = h_counter + 1;
                if (h_counter == 640) begin
                    h_state = 2;
                    hsync = 1;
                    blank = 0;
                end
            2: // Front Porch
                if (h_counter == 16) begin
                    h_state = 1;
                    hsync = 0;
                end
            1: // Sync Pulse
                h_counter = h_counter + 1;
                if (h_counter == 96) begin
                    h_state = 0;
                    vsync = 1;
                end
            0: // Back Porch
                if (h_counter == 48) begin
                    h_state = 3;
                    hsync = 0;
                end
            default:
                h_state = 3;
        end
    end

    // Vertical FSM
    always_ff (posedge clock) begin
        case (v_state)
            3: // Active
                v_counter = v_counter + 1;
                if (v_counter == 480) begin
                    v_state = 2;
                    vsync = 1;
                end
            2: // Front Porch
                if (v_counter == 10) begin
                    v_state = 1;
                    vsync = 0;
                end
            1: // Sync Pulse
                v_counter = v_counter + 1;
                if (v_counter == 2) begin
                    v_state = 0;
                    blank = 1;
                end
            0: // Back Porch
                if (v_counter == 33) begin
                    v_state = 3;
                    vsync = 0;
                end
            default:
                v_state = 3;
        end
    end

    // Color Control
    always clock begin
        case (h_state)
            3: // Active
                red = (color_in[7:5] << 3) | 8'd0;
                green = (color_in[4:2] << 3) | 8'd0;
                blue = (color_in[1:0] << 5) | 8'd0;
            default:
                red = 8'd0;
                green = 8'd0;
                blue = 8'd0;
        end
    end

    // Line Done Signal
    line_done = (h_state == 3 && h_counter == 640);

    // Blank Signal
    blank = (hsync == 0 && vsync == 0);

    // Synchronization Signals
    hsync = (h_state == 1 || h_state == 0);
    vsync = (v_state == 1 || v_state == 0);
    sync = 8'd0;

endmodule