module hamming_rx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
)(
  input  logic [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_in,  // ENCODED_DATA width
  output logic [DATA_WIDTH-1:0] data_out
);

  // Calculate the total encoded data width and the number of bits needed to index it.
  localparam int ENCODED_DATA   = PARITY_BIT + DATA_WIDTH + 1;  // redundant bit + parity bits + data bits
  localparam int ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

  //-------------------------------------------------------------------------
  // Function: is_power_of_two
  // Returns true if the input integer is a power of two.
  // Note: For x = 0, (0 & -1) == 0, but we will not call this function for 0.
  //-------------------------------------------------------------------------
  function automatic bit is_power_of_two(input int x);
    is_power_of_two = ((x & (x-1)) == 0);
  endfunction

  //-------------------------------------------------------------------------
  // Internal Signals
  //-------------------------------------------------------------------------
  logic [PARITY_BIT-1:0] syndrome;         // Syndrome bits computed from even parity
  logic [ENCODED_DATA-1:0] corrected_data;  // Data after error correction

  //-------------------------------------------------------------------------
  // Compute Syndrome Bits
  // For each parity bit (n = 0 to PARITY_BIT-1), compute the XOR of all bits in
  // data_in at positions where the n-th bit (counting from LSB) of the index is 1.
  //-------------------------------------------------------------------------
  integer n, i;
  always_comb begin
    syndrome = '0;
    for (n = 0; n < PARITY_BIT; n = n + 1) begin
      bit parity_bit = 1'b0;
      for (i = 1; i < ENCODED_DATA; i = i + 1) begin
        // Check if the n-th bit of index i is 1.
        if (((i >> n) & 1'b1) == 1'b1) begin
          parity_bit = parity_bit ^ data_in[i];
        end
      end
      syndrome[n] = parity_bit;
    end
  end

  //-------------------------------------------------------------------------
  // Error Correction
  // If the syndrome (interpreted as a binary number) is non-zero, then a single-bit
  // error is detected. The erroneous bit is located at the position given by the syndrome.
  // Note: The redundant bit at position 0 is not inverted.
  //-------------------------------------------------------------------------
  always_comb begin
    corrected_data = data_in;  // Default: no error correction
    if (syndrome != 0) begin
      int err_index = $unsigned(syndrome);
      // Only correct if the error is not in the redundant bit (index 0)
      if (err_index != 0) begin
        corrected_data[err_index] = ~corrected_data[err_index];
      end
    end
  end

  //-------------------------------------------------------------------------
  // Extract Data Bits
  // The encoded input (corrected_data) contains:
  //   - Bit 0: redundant bit (always 0 in transmitted data)
  //   - Bits at positions that are powers of 2: parity bits
  //   - All other bits: data bits (filled sequentially from LSB to MSB)
  //
  // This block extracts the data bits from corrected_data and assigns them to data_out,
  // mapping the lowest-index data bit to data_out[0] (LSB) and so on.
  //-------------------------------------------------------------------------
  integer j;
  always_comb begin
    j = 0;
    for (i = 1; i < ENCODED_DATA; i = i + 1) begin
      // Skip parity bits (positions that are powers of 2)
      if (!is_power_of_two(i)) begin
        data_out[j] = corrected_data[i];
        j = j + 1;
      end
    end
  end

endmodule