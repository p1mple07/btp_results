parameter DATA_WIDTH = 8;
parameter DEPTH = 16;

input clock_w, clock_r;
input wire [DATA_WIDTH-1:0] data_w, data_r;
input wire [DEPTH-1:0] address_w, address_r;
output wire [DATA_WIDTH-1:0] data_out;
output wire w_full, r_empty;

reg [DEPTH-1:0] ptr_w, ptr_r;
reg [DEPTH-1:0] ptr_w_reg, ptr_r_reg;

always @posedge clock_w begin
    if (w_rst) 
        ptr_w = 0;
    else if (w_inc) 
        ptr_w = ptr_w + 1;
    ptr_w_reg = ptr_w;
end

always @posedge clock_r begin
    if (r_rst) 
        ptr_r = 0;
    else if (r_inc) 
        ptr_r = ptr_r + 1;
    ptr_r_reg = ptr_r;
end

always @* begin
    if (ptr_w >= DEPTH) begin
        w_full = 1;
        r_empty = 0;
    end
    else if (ptr_w == ptr_r) begin
        r_empty = 1;
    end
    else if ((ptr_w ^ ptr_r) & (1 << (DATA_WIDTH-1))) begin
        w_full = 1;
        r_empty = 1;
    end
end

always @* begin
    data_out = data_w;
end