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
    reg [3:0] h_state = 0;
    // Vertical State Machine
    reg [3:0] v_state = 0;
    // Counters
    reg [9:0] h_counter = 0;
    reg [9:0] v_counter = 0;
    // RGB Signals
    reg [7:0] red_val = 0;
    reg [7:0] green_val = 0;
    reg [7:0] blue_val = 0;

    // Horizontal State Transitions
    always_ff (posedge clock or reset) begin
        if (reset) begin
            h_state = 0;
            h_counter = 0;
            v_state = 0;
            v_counter = 0;
            line_done = 0;
            red_val = 0;
            green_val = 0;
            blue_val = 0;
        else begin
            case (h_state)
                0: h_counter = 1; h_state = 1; // Active
                1: if (h_counter == H_ACTIVE) begin
                    h_counter = 0; h_state = 2; // Front Porch
                    line_done = 1;
                end else h_counter++;
                2: if (h_counter == H_FRONT + H_PULSE) begin
                    h_counter = 0; h_state = 3; // Back Porch
                    line_done = 1;
                end else h_counter++;
                3: if (h_counter == H_BACK) begin
                    h_counter = 0; h_state = 0; // Active
                    line_done = 0;
                end else h_counter++;
                default: h_counter++;
            endcase
        end
    end

    // Vertical State Transitions
    always_ff (posedge clock or reset) begin
        if (reset) begin
            v_state = 0;
            v_counter = 0;
        else begin
            case (v_state)
                0: v_counter = 1; v_state = 1; // Active
                1: if (v_counter == V_ACTIVE) begin
                    v_counter = 0; v_state = 2; // Front Porch
                end else v_counter++;
                2: if (v_counter == V_FRONT + V_PULSE) begin
                    v_counter = 0; v_state = 3; // Back Porch
                end else v_counter++;
                3: if (v_counter == V_BACK) begin
                    v_counter = 0; v_state = 0; // Active
                end else v_counter++;
                default: v_counter++;
            endcase
        end
    end

    // RGB Signal Assignment
    always_ff (posedge clock or reset) begin
        case (h_state)
            0: red = (color_in[7:5] << 5) | 0b00000000000;
               green = (color_in[4:2] << 5) | 0b00000000000;
               blue = (color_in[1:0] << 6) | 0b000000000000000;
            2: red = 0b00000000000;
               green = 0b00000000000;
               blue = 0b00000000000;
            default: red = 0b00000000000;
                     green = 0b00000000000;
                     blue = 0b00000000000;
        endcase
    end

    // Sync Signals
    hsync = (h_state == 1) ? 1 : 0;
    vsync = (v_state == 1) ? 1 : 0;

    // Blank Signal
    blank = !hsync & !vsync;
endmodule