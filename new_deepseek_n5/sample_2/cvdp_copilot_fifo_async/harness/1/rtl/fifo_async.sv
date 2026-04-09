parameter DATA_WIDTH = 8;
parameter DEPTH = 16;

input clock_w;
input clock_r;
input wire [DATA_WIDTH-1:0] w_data;
input wire [DATA_WIDTH-1:0] r_data;
input wire w_rst;
input wire w_inc;
input wire w_rst_w;
input wire r_rst;
input wire r_inc;
output wire [DATA_WIDTH-1:0] r_data;
output wire w_full;
output wire r_empty;

reg [DEPTH-1:0] w_ptr, r_ptr;

always
    if (w_rst) w_ptr = 0;
    else if (w_inc) w_ptr = w_ptr + 1;

always
    if (r_rst) r_ptr = 0;
    else if (r_inc) r_ptr = r_ptr + 1;

always
    w_full = (w_ptr >= DEPTH);
    r_empty = (r_ptr >= DEPTH);

always
    if (w_full) w_ptr = 0;
    if (r_empty) r_ptr = 0;

always
    w_data <= w_data;
    r_data <= r_data;