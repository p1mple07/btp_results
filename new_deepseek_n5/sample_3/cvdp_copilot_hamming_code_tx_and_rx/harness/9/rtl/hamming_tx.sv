module hamming_tx(
  parameter DATA_WIDTH,
  parameter PARITY_BIT,
  input[data_in_width:0] data_in,
  output[encoded_data_width:0] data_out
);
  parameter encoded_data_width = DATA_WIDTH + PARITY_BIT + 1;
  parameter encoded_data_bit_width = ceil(log2(encoded_data_width)) + 1;
  
  // Initialize output with zeros
  data_out = 0;
  data_out[0] = 0;

  // Calculate parity bits
  for (int n = 0; n < PARITY_BIT; n++) {
    int pos = 1 << n;
    data_out[pos] = 0;
  }

  // Map data_in to data_out
  for (int i = 0; i < DATA_WIDTH; i++) {
    data_out[i+1] = data_in[i];
  }

  // Calculate parity bits
  for (int n = 0; n < PARITY_BIT; n++) {
    int parity_bit = 0;
    int pos = 1 << n;
    for (int i = 0; i < encoded_data_width; i++) {
      if ((i & pos) != 0) {
        parity_bit ^= data_out[i];
      }
    }
    data_out[pos] = parity_bit;
  }
endmodule