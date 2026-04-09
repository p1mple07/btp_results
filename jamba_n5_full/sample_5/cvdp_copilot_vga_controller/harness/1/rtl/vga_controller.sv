module vga_controller (
    input wire clock,
    input wire reset,
    input [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output reg [9:0] next_x,
    output reg [9:0] next_y,
    output reg sync,
    output reg [3:0] blank,
    output reg [9:0] next_x_next,
    output reg [9:0] next_y_next,
    output reg sync_clk,
    output reg blank_clk
);

// Reset initialization
reg h_counter, v_counter, h_front, h_pulse, h_back;
reg v_counter_val, v_front, v_pulse, v_back;

initial begin
    h_counter = 0;
    v_counter = 0;
    h_front = 640;
    h_pulse = 16;
    h_back = 48;
    v_front = 10;
    v_pulse = 96;
    v_back = 33;
end

always_ff @(posedge clock) begin
    if (~reset) begin
        h_counter <= 0;
        v_counter <= 0;
        h_front <= 640;
        h_pulse <= 16;
        h_back <= 48;
        v_front <= 10;
        v_pulse <= 96;
        v_back <= 33;
        hsync <= 1;
        vsync <= 1;
        red = 0;
        green = 0;
        blue = 0;
        next_x <= 0;
        next_y <= 0;
        sync <= 0;
        blank <= 0;
        next_x_next <= 0;
        next_y_next <= 0;
        sync_clk <= 0;
        blank_clk <= 0;
    end else begin
        case (horizontal_state)
            H_ACTIVE: begin
                if (h_counter < h_front) begin
                    h_counter <= h_counter + 1;
                end else if (h_counter == h_front) begin
                    h_front_done = 1;
                    h_counter <= 0;
                end
            end
            front_porch: begin
                if (h_front_done) begin
                    h_front_done <= 0;
                    h_front_pulse = 16;
                    v_front <= 1;
                    v_counter <= v_counter + 1;
                end else begin
                    h_front_pulse <= 0;
                end
            end
            // more states
        endcase
    end
end

assign hsync = h_front_done ? 1 : 0;
assign vsync = v_front_done ? 1 : 0;

assign red = {color_in[7:5], 5'd0};
assign green = {color_in[4:2], 5'd0};
assign blue = {color_in[1:0], 6'd0};

assign next_x = next_x_next;
assign next_y = next_y_next;

assign sync = hsync;
assign blank = h_front_done || v_front_done;

always_ff @(posedge clock) begin
    if (hsync) begin
        // Generate sync pulses
        if (h_front_done) begin
            vsync <= 1;
        end
        if (h_pulse > 0) begin
            h_pulse <= h_pulse - 1;
        end else begin
            hsync <= 0;
        end
    end
end

endmodule
