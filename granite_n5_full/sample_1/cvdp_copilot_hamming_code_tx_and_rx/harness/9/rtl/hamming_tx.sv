module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
)(
  input wire [DATA_WIDTH-1:0] data_in,
  output wire [encoded_data_bit-1:0] data_out
);

  localparam int ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  localparam int ENCODED_DATA_BIT = $clog2(Encoded_DATA);

  assign data_out = {
    data_in,
    '{
      (PARITY_BIT-1){1'b0},
      (Encoded_DATA-1){1'b0}
    }
  };

  genvar i;
  generate
    for (i=0; i<PARITY_BIT; i++) begin : parity_gen
      assign data_out[i] = ^(data_in & ({data_in[i]}));
    end
  endgenerate

endmodule