module hamming_tx #(
  parameter DATA_WIDTH = 4,
  parameter PARITY_BIT  = 3
)(
  input  logic [DATA_WIDTH-1:0] data_in,
  output logic [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_out
);

  // Calculate total encoded data width and the bit width needed to index it
  localparam integer ENCODED_DATA    = PARITY_BIT + DATA_WIDTH + 1;
  localparam integer ENCODED_DATA_BIT = $clog2(ENCODED_DATA);

  // Internal array to hold calculated parity bits
  logic [PARITY_BIT-1:0] parity;

  // Function to check if a number is a power of two (n > 0)
  function automatic bit is_power_of_two(input int n);
    begin
      is_power_of_two = (n > 0) && ((n & (n-1)) == 0);
    end
  endfunction

  // Temporary vector to hold the encoded data
  logic [ENCODED_DATA-1:0] encoded;

  // Combinational logic to generate the encoded output
  always_comb begin
    integer i;
    integer data_idx;

    // Step 1: Clear internal registers
    data_idx    = 0;
    encoded     = '0;
    parity      = '0;

    // Step 2: Map data_in bits to non-parity and non-redundant positions in encoded
    // The redundant bit is at index 0 and is always 0.
    // Parity bit positions (powers of 2) are left as 0 for now.
    for (i = 0; i < ENCODED_DATA; i = i + 1) begin
      if (i == 0) begin
        // Redundant bit (always 0)
        encoded[i] = 1'b0;
      end else if (is_power_of_two(i)) begin
        // Parity positions: leave as 0 for now
        encoded[i] = 1'b0;
      end else begin
        // Non-parity positions: assign data bits sequentially from data_in
        encoded[i] = data_in[data_idx];
        data_idx   = data_idx + 1;
      end
    end

    // Step 3: Calculate even parity bits based on Hamming code principle
    // For each parity bit position (which is a power of two), compute the XOR of all bits
    // in the encoded vector where the corresponding bit (counting from LSB) in the index is 1.
    for (i = 0; i < ENCODED_DATA; i = i + 1) begin
      if (is_power_of_two(i)) begin
        // Determine the index (p) in the parity array corresponding to this parity position.
        int p = $clog2(i);
        // XOR all bits in encoded where the p-th bit of the index is 1.
        for (int j = 0; j < ENCODED_DATA; j = j + 1) begin
          if (((j >> p) & 1) == 1) begin
            parity[p] = parity[p] ^ encoded[j];
          end
        end
      end
    end

    // Step 4: Insert the calculated parity bits into the encoded vector at positions
    // corresponding to powers of two.
    for (i = 0; i < ENCODED_DATA; i = i + 1) begin
      if (is_power_of_two(i) && i != 0) begin
        int p = $clog2(i);
        encoded[i] = parity[p];
      end
    end

    // Final output: assign the encoded vector to data_out
    data_out = encoded;
  end

endmodule