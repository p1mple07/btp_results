endgenerate

// Scramble data block
assign data_out = data_in & lfsr[DATA_WIDTH-1:0] ^ lfsr[DATA_WIDTH-1:LFSR_WIDTH];
