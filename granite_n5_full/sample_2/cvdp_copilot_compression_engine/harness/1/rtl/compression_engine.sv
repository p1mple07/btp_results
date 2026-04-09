assign exp_oh[23:0].

// Insert code here for one-hot encoding of `exp_oh`.

assign exp_bin[3:0] = exp_oh[3:0], and then generate the final exponent by adding 4 to the binary representation of the exponent.

// Insert code here for extracting the 12-bit mantissa.

assign mantissa_o[11:0] = num_i[11:0].

assign exponent_o[3:0] = 4'h1;