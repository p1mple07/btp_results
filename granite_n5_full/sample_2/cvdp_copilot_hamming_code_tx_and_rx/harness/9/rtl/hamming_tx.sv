module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
)(
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [ encode_data(DATA_WIDTH, PARITY_BIT)-1:0] data_out
);

  function automatic int encode_data(int DATA_WIDTH, int PARITY_BIT);
    return DATA_WIDTH + PARITY_BIT + 1;
  endfunction

  // Calculate the total output width and the index bit-width.
  localparam int ENCODED_DATA = encode_data(DATA_WIDTH, PARITY_BIT);
  localparam int ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

  always_comb begin
    // Initialize internal registers to 0.
    logic [PARITY_BIT-1:0] parity;

    // Assign the input to the output.
    // Parity bits are placed at data_out positions corresponding to powers of 2 in data_out (e.g., indices 2**0 = 1, 2**1 = 2, 2**2 = 4, etc.).
    // A redundant bit is assigned to data_out[0].
    // The bits of data_in are mapped sequentially, starting from the LSB to the MSB, into the non-parity and non-redundant positions of data_out.
    // The bits of data_in are mapped sequentially, starting from the LSB to the MSB, into the non-parity and non-redundant positions of data_out.

    data_out <= {data_in, '0};

  end

endmodule