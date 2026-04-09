module hamming_tx #(
  parameter DATA_WIDTH = 4,
  parameter PARITY_BIT  = 3
) (
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_out
);

  // Calculate total encoded output width and the bit-width needed to index it.
  localparam int ENCODED_DATA     = PARITY_BIT + DATA_WIDTH + 1;
  localparam int ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

  // Combinational logic for Hamming code transmitter.
  // This module maps data_in into non-parity positions of data_out,
  // computes even parity bits, and inserts them at positions corresponding
  // to powers of two. data_out[0] is a redundant bit always set to 0.
  always_comb begin
    // Step 1: Clear all outputs (and internal parity bits).
    data_out = '0;

    // Step 2: Map data_in bits into non-parity and non-redundant positions.
    // data_out[0] is reserved as redundant bit (always 0).
    // Parity bits will be inserted later at positions that are powers of 2.
    int j = 0;
    for (int i = 1; i < ENCODED_DATA; i++) begin
      // Check if 'i' is not a power of 2.
      if ((i & (i - 1)) !== 0) begin
        data_out[i] = data_in[j];
        j = j + 1;
      end
    end

    // Step 3 & 4: Calculate even parity bits and insert them.
    // For each parity bit position (corresponding to 2^p), compute the XOR
    // of all bits in data_out where the p-th bit (from LSB) of the index is 1.
    for (int p = 0; p < PARITY_BIT; p++) begin
      bit parity_bit = 1'b0;
      for (int k = 0; k < ENCODED_DATA; k++) begin
        if (((k >> p) & 1'b1) == 1'b1) begin
          parity_bit = parity_bit ^ data_out[k];
        end
      end
      // Insert the computed parity bit into its designated position.
      data_out[1 << p] = parity_bit;
    end
  end

endmodule