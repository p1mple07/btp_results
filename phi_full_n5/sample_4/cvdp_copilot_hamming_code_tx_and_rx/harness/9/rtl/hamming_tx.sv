module hamming_tx #(parameter DATA_WIDTH = 4, parameter PARITY_BIT = 3)
(
    input [DATA_WIDTH-1:0] data_in,
    output reg [PARITY_BIT+DATA_WIDTH+1:0] data_out
);

  // Step 1: Clear all internal registers
  reg [PARITY_BIT-1:0] parity[PARITY_BIT-1:0];

  // Step 2: Assign data_in to data_out
  integer i;
  always_comb begin
    data_out = {(PARITY_BIT+DATA_WIDTH+1) -1'b0, data_in}; // Initialize with 0s

    // Mapping data_in bits to non-parity and non-redundant positions
    for (i = 0; i < DATA_WIDTH; i++) begin
      data_out[DATA_WIDTH - i] = data_in[i];
    end

    // Step 3: Calculate the even parity bits
    for (i = 0; i < PARITY_BIT; i++) begin
      case (i)
        0: parity[i] = data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
        1: parity[i] = data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
        2: parity[i] = data_out[4] ^ data_out[5] ^ data_out[6] ^ data_out[7];
        default: parity[i] = 1'b0;
      endcase
    end

    // Step 4: Insert the calculated parity bits into data_out
    for (i = 0; i < PARITY_BIT; i++) begin
      data_out[2**i] = parity[i];
    end

endmodule
