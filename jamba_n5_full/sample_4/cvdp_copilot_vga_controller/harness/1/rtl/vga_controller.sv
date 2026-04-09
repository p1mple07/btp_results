module vga_controller (
    input clock,
    input reset,
    input [7:0] color_in[7:0],
    output reg hsync,
    output reg vsync,
    output reg [9:0] next_x, next_y,
    output reg sync,
    output reg [9:0] h_counter, v_counter,
    output reg line_done,
    output reg blank
);

reg [9:0] h_counter, v_counter;

always_ff @(posedge clock) begin
    if (reset) begin
        h_counter <= 0;
        v_counter <= 0;
        hsync <= 1;
        vsync <= 1;
        line_done <= 0;
    end else begin
        if (h_counter < 640) begin
            h_counter <= h_counter + 1;
            if (h_counter == 640) h_counter <= 0;
        end
        else begin
            h_counter <= 0;
        end

        if (v_counter < 480) begin
            v_counter <= v_counter + 1;
            if (v_counter == 480) v_counter <= 0;
        end
    end
end

output sync;
always_ff @(posedge clock) begin
    sync <= hsync & vsync;
end

output hsync, vsync, red, green, blue;

red = (color_in[7:5] == '1') ? 1'b1 : 8'b0;
green = (color_in[4:2] == '1') ? 1'b1 : 8'b0;
blue = (color_in[1:0] == '1') ? 1'b1 : 8'b0;

output next_x, next_y, line_done, blank;

endmodule
