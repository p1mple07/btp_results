module vga_controller (
    input wire clk,
    input wire reset,
    input wire color_in[7:0],
    output reg hsync,
    output reg vsync,
    output reg red, green, blue,
    output reg next_x, next_y,
    output reg sync,
    output reg blank
);

reg hcounter, vcounter, h_front, v_front, h_back, v_back;
reg state;

initial begin
    hsync = vsync = red = green = blue = next_x = next_y = sync = blank = '0;
end

always_ff @(posedge clk) begin
    if (reset) begin
        hcounter <= 0;
        vcounter <= 0;
        sync <= '0;
        blank <= '0;
        red = 0; green = 0; blue = 0;
        hsync = vsync = '0;
    end else begin
        if (h_active) begin
            hcntr <= hcntr + 1;
            if (hcntr == 640) begin
                hcntr <= 0;
                hsync <= '1;
                vsync <= '0;
                red <= color_in[7:5];
                green <= color_in[4:2];
                blue <= color_in[1:0];
            end
        end else if (h_front) begin
            h_front <= 0;
        end else if (h_back) begin
            h_back <= 0;
        end else begin
            sync <= '0;
        end
    end
end

endmodule
