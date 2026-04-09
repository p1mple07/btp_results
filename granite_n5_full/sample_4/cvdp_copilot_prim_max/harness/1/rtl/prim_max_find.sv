localparam int NumLevels = ($clog2(NumSrc) - 1) >= 0? ($clog2(NumSrc) - 1) : 0;
localparam int NumNodes = 2**(NumLevels+1);

localparam int Base0 = (2**level);
localparam int Base1 = (2**(level+1));

wire [7:0] values_i;
//...
assign values_i = src_i;
//...
assign max_value_o = values_i[(offset+1)*Width : offset*Width];
assign max_idx_o   = offset;
assign max_valid_o = 1'b1;
//...