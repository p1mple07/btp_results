module rgb_color_space_hsv (
    input clock,
    input rst,
    input [7:0] we,
    input [7:0] waddr,
    input [24:0] wdata,
    input [7:0] r_component,
    input [7:0] g_component,
    input [7:0] b_component,
    output reg [11:0] h_component,
    output reg [12:0] s_component,
    output reg [11:0] v_component,
    output reg valid_out
);