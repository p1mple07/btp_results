module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3,
  parameter int ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1,
  parameter int ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)
(
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [ENCODED_DATA-1:0] data_out
);

  // Internal register to hold the encoded data before parity insertion.
  logic [ENCODED_DATA-1:0] encoded;
  // Internal array to hold calculated parity bits.
  logic [PARITY_BIT-1:0] parity;

  always_comb begin
    // Clear the encoded vector.
    encoded = '0;
    // The redundant bit at index 0 is always 0.
    encoded[0] = 1'b0;
    int data_cnt = 0;
    
    // Map data bits to non-parity positions in the encoded vector.
    // The positions that are powers of two (e.g. 1, 2, 4, ...) are reserved for parity.
    for (int i = 1; i < ENCODED_DATA; i++) begin
      if ((i & (i-1)) == 0) begin
        // i is a power of two: reserved for a parity bit.
      end else begin
        if (data_cnt < DATA_WIDTH) begin
          encoded[i] = data_in[data_cnt];
          data_cnt++;
        end else begin
          // Should not occur if mapping is correct.
          encoded[i] = 1'b0;
        end
      end
    end

    // Calculate even parity bits.
    // For each parity bit (indexed by n), XOR together all data bits in positions
    // where the n-th bit (from LSB) of the binary index is 1, excluding positions reserved for parity.
    parity = '0;
    for (int n = 0; n < PARITY_BIT; n++) begin
      for (int i = 1; i < ENCODED_DATA; i++) begin
        if ((i & (i-1)) != 0) begin  // Exclude parity positions.
          if (((i >> n) & 1'b1) == 1'b1) begin
            parity[n] ^= encoded[i];
          end
        end
      end
    end

    // Insert the calculated parity bits into the encoded vector at positions that are powers of two.
    for (int i = 1; i < ENCODED_DATA; i++) begin
      if ((i & (i-1)) == 0) begin
        // Determine which parity bit index corresponds to this power-of-two position.
        int p_index = $clog2(i);
        encoded[i] = parity[p_index];
      end
    end

    // Drive the output.
    data_out = encoded;
  end

endmodule