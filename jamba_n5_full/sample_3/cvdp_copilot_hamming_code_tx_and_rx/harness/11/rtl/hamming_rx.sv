module hamming_rx #(
    parameter DATA_WIDTH = 4,
    parameter PARITY_BIT = 3
) (
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);

  localparam int max_parity = PARITY_BIT;
  localparam int num_parity_bits = max_parity;

  // Internal arrays to hold computed parity bits
  logic [num_parity_bits-1:0] parity;
  logic [DATA_WIDTH-1:0] correct_data;
  logic error;

  // --- Initialization -------------------------------------------------
  initial begin
    parity = {};
    // Clear all internal registers to zero
  end

  // --- Error Detection & Correction ----------------------------------
  always @(*) begin
    // Calculate parity bits using even‑parity logic
    parity[0] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
    parity[1] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    parity[2] = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    // Build the error‑detection mask
    bits [PARITY_BIT-1:0] errorMask = {
      parity[num_parity_bits-1],
      parity[num_parity_bits-2],
      parity[num_parity_bits-3]
    };

    // Check for single‑bit error
    error = (errorMask == 3'b0) ? 1'b0 : 1'b1;
  end

  // --- Data Output Generation -------------------------
  always @(*) begin
    // Set output to the original data when no error occurs
    if (!error) begin
      correct_data = data_in;
    end
    // If an error is found, invert the erroneous bit
    else begin
      for (int i = 0; i < num_parity_bits; i++) begin
        if (errorMask[i] == 1'b1) begin
          // Locate the error location and flip the bit
          data_in[i] = ~data_in[i];
          break;
        end
      end
      correct_data = 0;
    end

    // Reconstruct the data_out vector
    data_out = {
      correct_data[7], correct_data[6], correct_data[5], correct_data[3]
    };
  end

endmodule
