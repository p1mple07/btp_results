module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
)(
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_out  // ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1
);

  // Calculate the total encoded output width and the bit-width needed to index it.
  localparam int ENCODED_DATA    = PARITY_BIT + DATA_WIDTH + 1;
  localparam int ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

  // Temporary register to hold the encoded data.
  logic [ENCODED_DATA-1:0] temp_data_out;

  // Loop variables.
  integer i, j;
  integer data_index;

  always_comb begin
    // Step 1: Clear all bits.
    temp_data_out = {ENCODED_DATA{1'b0}};
    data_index    = 0;

    // Step 2: Map data_in bits to non-parity positions.
    // The encoded word positions are 0 to ENCODED_DATA-1.
    // Position 0 is reserved as a redundant bit (always 0).
    // Positions that are powers of 2 (e.g., 1, 2, 4, ...) are reserved for parity bits.
    for (i = 1; i < ENCODED_DATA; i = i + 1) begin
      // Check if i is a power of 2. (A number is a power of 2 if (i & (i-1)) == 0.)
      if ((i != 0) && ((i & (i-1)) == 0)) begin
        // i is a parity position; leave it unassigned for now.
      end else begin
        // Assign the next bit from data_in.
        temp_data_out[i] = data_in[data_index];
        data_index = data_index + 1;
      end
    end

    // Step 3: Calculate even parity bits.
    // For each parity bit position (which are powers of 2), compute the XOR
    // of all data bits (i.e. bits from non-parity positions) in positions where
    // the corresponding bit in the index is 1.
    for (i = 0; i < PARITY_BIT; i = i + 1) begin
      integer p = 1 << i;  // p is the parity position (e.g., 1, 2, 4, ...)
      logic parity_bit;
      parity_bit = 1'b0;
      // Loop over all positions (except position 0 which is redundant).
      for (j = 1; j < ENCODED_DATA; j = j + 1) begin
        // Skip parity positions.
        if ((j & (j-1)) == 0) begin
          // j is a power of 2 (a reserved parity position); skip it.
        end else begin
          // If the i-th bit (from LSB) of j is 1, include temp_data_out[j] in the XOR.
          if (((j >> i) & 1'b1) == 1'b1) begin
            parity_bit = parity_bit ^ temp_data_out[j];
          end
        end
      end
      // Step 4: Insert the calculated parity bit into its reserved position.
      temp_data_out[p] = parity_bit;
    end

    // Drive the output with the fully encoded data.
    data_out = temp_data_out;
  end

endmodule