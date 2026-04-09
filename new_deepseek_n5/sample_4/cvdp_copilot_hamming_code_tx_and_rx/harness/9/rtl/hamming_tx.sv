module hamming_tx(
  parameter DATA_WIDTH,
  parameter PARITY_BIT,
  input[data_in_width:0] data_in,
  output[encoded_data_width:0] data_out
);
  parameter ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  parameter ENCODED_DATA_BIT = ceil(log2(ENCODED_DATA));
  
  // Initialize parity bits to 0
  wire [PARITY_BIT-1:0] parity = 0;
  
  // Map data_in bits to data_out positions
  integer i;
  for(i = 0; i < DATA_WIDTH; i++) begin
    data_out[3 + i] = data_in[i];
  end
  
  // Calculate parity bits
  integer p;
  for(p = 0; p < PARITY_BIT; p++) begin
    integer mask = 1 << p;
    integer parity_bit_pos = 0;
    for(bit in 0 to ENCODED_DATA-1) begin
      if((bit & mask) != 0) parity_bit_pos = bit;
    end
    wire [data_out[parity_bit_pos] = parity[p]];
  end
  
  // Set redundant bit
  data_out[0] = 0;
endmodule