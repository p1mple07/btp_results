module hamming_tx #(
    parameter INTEGER DATA_WIDTH = 4,
    parameter INTEGER PARITY_BIT = 3
) (
    input logic [DATASIZE-1:0] data_in,
    output logic [ENCODED_DATA_BIT-1:0] data_out
);

  localparam ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  localparam ENCODED_DATA_BIT = ENCODED_DATA.bit_length();

  logic [ENCODED_DATA_BIT-1:0] data_out;

  initial begin
    data_out = 0;
  end

  data_out[0] = 1'b0;

  for (int n = 0; n < PARITY_BIT; n++) begin
    int parity_index = (1 << n) - 1;
    data_out[parity_index] = data_in[parity_index ^ (1 << n)];
  end

  data_out[ENCODED_DATA - 1] = data_in[DATASIZE - 1];
  for (int i = 0; i < DATASIZE; i++) begin
    data_out[i] = data_in[i];
  end

endmodule
