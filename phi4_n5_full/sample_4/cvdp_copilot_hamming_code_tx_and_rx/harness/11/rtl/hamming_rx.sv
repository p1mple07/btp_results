module hamming_rx 
  #(parameter DATA_WIDTH = 4,
    parameter PARITY_BIT  = 3)
   (
    input  logic [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_in,  // Encoded input: width = PARITY_BIT + DATA_WIDTH + 1
    output logic [DATA_WIDTH-1:0] data_out                  // Corrected data output
   );

  // ENCODED_DATA is the total number of bits in the encoded input.
  localparam ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;

  // Internal register to hold the (possibly) corrected encoded data.
  reg [ENCODED_DATA-1:0] corrected_data;
  // Array to hold the computed parity bits.
  logic [PARITY_BIT-1:0] parity;
  // Variables for loop indices and syndrome computation.
  integer syndrome;
  integer i, n, bit;

  // Function to check if a given integer is a power of two.
  function automatic bit is_power_of_two(input int x);
    is_power_of_two = (x != 0) && ((x & (x-1)) == 0);
  endfunction

  // Combinational logic: detect and correct single-bit errors, then extract data bits.
  always_comb begin
    //-------------------------------------------------------------------------
    // 1. Calculate parity bits using even parity logic.
    //    For each parity bit index n (0 to PARITY_BIT-1), XOR together all data_in
    //    bits whose binary index has the n-th bit set. Note: We skip index 0.
    //-------------------------------------------------------------------------
    for (n = 0; n < PARITY_BIT; n++) begin
      parity[n] = 1'b0;
      for (i = 1; i < ENCODED_DATA; i++) begin
        if (((i >> n) & 1) == 1)
          parity[n] = parity[n] ^ data_in[i];
      end
    end

    //-------------------------------------------------------------------------
    // 2. Compute the syndrome from the parity bits.
    //    The syndrome is formed by concatenating the parity bits (parity[0] as LSB).
    //    If the syndrome is 0, then no error is detected.
    //-------------------------------------------------------------------------
    syndrome = 0;
    for (n = 0; n < PARITY_BIT; n++) begin
      syndrome = (syndrome << 1) | parity[n];
    end

    //-------------------------------------------------------------------------
    // 3. Error Correction:
    //    If the syndrome is nonzero, interpret it as the index of the erroneous bit.
    //    Invert that bit in the encoded data. (Note: The redundant bit at index 0 is not inverted.)
    //-------------------------------------------------------------------------
    corrected_data = data_in;
    if (syndrome != 0)
      corrected_data[syndrome] = ~data_in[syndrome];

    //-------------------------------------------------------------------------
    // 4. Extract the data bits from the corrected encoded data.
    //    The transmitter places parity bits at positions that are powers of 2 (1, 2, 4, …)
    //    and a redundant bit at index 0. The remaining positions (non-power-of-2 and not 0)
    //    contain the original data bits. The lowest-index data bit is mapped to the LSB of data_out,
    //    progressing to the MSB.
    //-------------------------------------------------------------------------
    bit = 0;
    for (i = 1; i < ENCODED_DATA; i++) begin
      if (!is_power_of_two(i)) begin
        data_out[bit] = corrected_data[i];
        bit++;
      end
    end
  end

endmodule