module vga_controller (
    input clock,
    input reset,
    input [7:0] color_in,
    output reg hsync,
    output reg vsync,
    output reg [9:0] red,
    output reg [9:0] green,
    output reg [9:0] blue,
    output reg [9:0] next_x,
    output reg [9:0] next_y,
    output reg sync,
    output reg [9:0] clk,
    output reg blank
);

// ... state machine ...

endmodule
