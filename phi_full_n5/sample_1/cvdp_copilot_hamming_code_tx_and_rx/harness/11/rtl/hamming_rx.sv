module hamming_rx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
    input wire [ENCODED_DATA-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out
);

  // Internal registers
  reg [PARITY_BIT-1:0] parity;

  // Initialization
  initial begin
    parity = {PARITY_BIT{1'b0}};
    data_out = {DATA_WIDTH{1'b0}};
  end

  // Error Detection Using Even Parity Logic
  always_comb begin
    // Calculate parity bits
    for (int i = 0; i < PARITY_BIT; i++) begin
      for (int j = 1; j < (1 << i); j <<= 1) begin
        parity[i] ^= data_in[j-1];
      end
    end

    // Error detection code
    wire error_detected = ^parity;

    // Error Correction
    always_comb begin
      if (error_detected == 1'b0) begin
        // No error, output data as is
        data_out = data_in[DATA_WIDTH-1:DATA_WIDTH-PARITY_BIT-1];
      end else begin
        // Single-bit error, correct it
        int error_position;
        parity = {error_detected, PARITY_BIT-1{1'b0}}; // Extract error position
        error_position = parity;
        data_in[error_position] = ~data_in[error_position]; // Correct the error
        data_out = data_in[DATA_WIDTH-1:DATA_WIDTH-PARITY_BIT-1]; // Output corrected data
      end
    end
  end

endmodule
