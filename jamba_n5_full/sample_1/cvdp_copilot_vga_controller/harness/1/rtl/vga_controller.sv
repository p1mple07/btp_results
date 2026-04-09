module vga_controller (
    input wire clock,
    input wire reset,
    input wire [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [7:0] red,
    output reg [7:0] green,
    output reg [7:0] blue,
    output reg next_x,
    output reg next_y,
    output wire sync,
    output wire [9:0] next_y_plus_one,
    output wire [9:0] next_x_plus_one,
    output wire [9:0] next_y_plus_one,
    output wire blank
);

initial begin
    hsync = 1'b1;
    vsync = 1'b1;
    red = 8'b0;
    green = 8'b0;
    blue = 8'b0;
    next_x = 10'd0;
    next_y = 10'd0;
    next_y_plus_one = 0;
    next_x_plus_one = 0;
    next_y_plus_one = 0;
    next_y_plus_one = 0;
end

always_ff @(posedge clock) begin
    if (reset) begin
        h_counter <= 0;
        v_counter <= 0;
        hsync = 1'b1;
        vsync = 1'b1;
        red = 8'b0;
        green = 8'b0;
        blue = 8'b0;
        next_x = 10'd0;
        next_y = 10'd0;
    end else begin
        case (h_state)
            H_ACTIVE: begin
                if (h_counter < H_ACTIVE) begin
                    h_counter <= h_counter + 1;
                    next_x = next_x + 1;
                    next_y = next_y + 1;
                end else begin
                    h_state = H_FRONT;
                end
            end
            H_FRONT: begin
                end
            H_PULSE: begin
                h_state = H_BACK;
            end
            H_BACK: begin
                h_state = H_ACTIVE;
            end
        endcase
    end

    case (v_state)
        V_ACTIVE: begin
            if (v_counter < V_ACTIVE) begin
                v_counter <= v_counter + 1;
            end else begin
                v_state = V_FRONT;
            end
        end
        V_FRONT: begin
            vsync = 1'b0;
        end
        V_PULSE: begin
        V_BACK: begin
            v_state = V_ACTIVE;
        end
    endcase
end

assign hsync = h_state == H_ACTIVE;
assign vsync = v_state == V_ACTIVE;
assign red = color_in[7:5];
assign green = color_in[4:2];
assign blue = color_in[1:0];

endmodule
