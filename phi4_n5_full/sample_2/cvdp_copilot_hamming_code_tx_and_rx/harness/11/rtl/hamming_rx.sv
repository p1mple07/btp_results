module hamming_rx #(
  parameter int DATA_WIDTH     = 4,
  parameter int PARITY_BIT     = 3,
  parameter int ENCODED_DATA   = PARITY_BIT + DATA_WIDTH + 1,
  parameter int ENCODED_DATA_BIT = $clog2(ENCODED_DATA)
)
(
  input  logic [ENCODED_DATA-1:0] data_in,
  output logic [DATA_WIDTH-1:0] data_out
);

  // Internal signals
  logic [ENCODED_DATA-1:0] corrected_data;
  logic [PARITY_BIT-1:0]   syndrome;
  logic [DATA_WIDTH-1:0]   data_temp;

  // Function to check if a number is a power of two.
  // Returns 1 if n is a power of two (and n != 0), else 0.
  function automatic bit is_power_of_two(input int n);
    if (n == 0)
      is_power_of_two = 0;
    else
      is_power_of_two = ((n & (n-1)) == 0);
  endfunction

  // Combinational block for error detection, correction, and data extraction.
  always_comb begin
    // Initialize corrected data with the input.
    corrected_data = data_in;
    syndrome       = '0;

    // Calculate syndrome bits using even parity logic.
    // For each parity bit index p, XOR all bits in data_in whose index has a 1 in the p-th bit.
    for (int p = 0; p < PARITY_BIT; p++) begin
      logic bit;  // local variable for XOR accumulation
      bit = 1'b0;
      for (int i = 0; i < ENCODED_DATA; i++) begin
        if (((i >> p) & 1'b1) == 1'b1) begin
          bit = bit ^ data_in[i];
        end
      end
      syndrome[p] = bit;
    end

    // Combine syndrome bits to form the error position.
    // The syndrome is interpreted as a binary number indicating the index of the erroneous bit.
    int error_position = 0;
    for (int p = 0; p < PARITY_BIT; p++) begin
      error_position |= (syndrome[p] << p);
    end

    // Correct single-bit error if detected.
    // Note: The redundant bit at position 0 is not inverted.
    if (error_position != 0) begin
      corrected_data[error_position] = ~corrected_data[error_position];
    end

    // Extract data bits from corrected_data.
    // Data bits are located at positions that are NOT 0 and NOT powers of 2.
    // They are mapped to data_out such that the lowest-index data bit becomes the LSB of data_out.
    data_temp = '0;
    int j = 0;
    for (int i = 0; i < ENCODED_DATA; i++) begin
      if (i != 0 && !is_power_of_two(i)) begin
        data_temp[j] = corrected_data[i];
        j++;
      end
    end
    data_out = data_temp;
  end

endmodule