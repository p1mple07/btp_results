// Insert code for one-hot encoding of `exp_oh` for priority encoding
assign exp_oh[23:0] = num_i[23:0];
assign exp_oh[23] = num_i[23], and other bits are cleared using `~|`.