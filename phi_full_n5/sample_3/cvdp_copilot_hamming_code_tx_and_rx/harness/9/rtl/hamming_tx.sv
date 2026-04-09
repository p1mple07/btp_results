module hamming_tx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH + PARITY_BIT + 1 - 1:0] data_out
);
  integer i;
  logic [PARITY_BIT-1:0] parity;

  // Step 1: Clear all internal registers
  initial begin
    parity = {1'b0, (DATA_WIDTH + PARITY_BIT + 1) - PARITY_BIT - 1{1'b0}};
  end

  // Step 2: Assign data_in to data_out
  always_comb begin
    for (i = 0; i < DATA_WIDTH; i++) begin
      data_out[i] = data_in[i];
    end
    for (i = 0; i < PARITY_BIT; i++) begin
      data_out[(2**i)-1] = parity[i];
    end
    data_out[0] = 1'b0; // Redundant bit
  end

  // Step 3: Calculate even parity bits
  always_comb begin
    parity[0] = data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
    parity[1] = data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
    parity[2] = data_out[4] ^ data_out[5] ^ data_out[6] ^ data_out[7];
  end

endmodule
 module hamming_tx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH + PARITY_BIT + 1 - 1:0] data_out
);
  integer i;
  logic [PARITY_BIT-1:0] parity;

  // Clear all internal registers
  initial begin
    parity = {1'b0, (DATA_WIDTH + PARITY_BIT + 1) - PARITY_BIT - 1{1'b0}};
  end

  // Assign data_in to data_out
  always_comb begin
    for (i = 0; i < DATA_WIDTH; i++) begin
      data_out[i] = data_in[i];
    end
    for (i = 0; i < PARITY_BIT; i++) begin
      data_out[(2**i)-1] = parity[i];
    end
    data_out[0] = 1'b0; // Redundant bit
  end

  // Calculate even parity bits
  always_comb begin
    parity[0] = data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
    parity[1] = data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
    parity[2] = data_out[4] ^ data_out[5] ^ data_out[6] ^ data_out[7];
  end

endmodule
 module hamming_tx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
  input [DATA_WIDTH-1:0] data_in,
  output [DATA_WIDTH + PARITY_BIT + 1 - 1:0] data_out
);
  integer i;
  logic [PARITY_BIT-1:0] parity;

  // Clear all internal registers
  initial begin
    parity = {1'b0, (DATA_WIDTH + PARITY_BIT + 1) - PARITY_BIT - 1{1'b0}};
  end

  // Assign data_in to data_out
  always_comb begin
    for (i = 0; i < DATA_WIDTH; i++) begin
      data_out[i] = data_in[i];
    end
    for (i = 0; i < PARITY_BIT; i++) begin
      data_out[(2**i)-1] = parity[i];
    end
    data_out[0] = 1'b0; // Redundant bit
  end

  // Calculate even parity bits
  always_comb begin
    parity[0] = data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
    parity[1] = data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
    parity[2] = data_out[4] ^ data_out[5] ^ data_out[6] ^ data_out[7];
  end

endmodule