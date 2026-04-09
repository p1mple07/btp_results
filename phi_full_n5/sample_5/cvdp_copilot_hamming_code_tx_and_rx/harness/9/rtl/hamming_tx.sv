module hamming_tx #(parameter DATA_WIDTH = 4, PARITY_BIT = 3) (
    input [DATA_WIDTH-1:0] data_in,
    output reg [PARITY_BIT + DATA_WIDTH + 1 - 1:0] data_out
);

  // Step 1: Clear all internal registers to 0
  reg [PARITY_BIT-1:0] parity;

  // Step 2: Assign data_in to data_out
  integer i;
  always_comb begin
    for (i = 0; i < DATA_WIDTH; i++) begin
      data_out[i] = data_in[i];
    end
    data_out[DATA_WIDTH] = 1'b0; // Redundant bit
  end

  // Step 3: Calculate the even parity bits
  integer j;
  always_comb begin
    for (j = 0; j < PARITY_BIT; j++) begin
      case (j)
        0: parity[j] = data_out[(j + 1) << 1 | 1];
        1: parity[j] = data_out[(j + 2) << 1 | 1];
        2: parity[j] = data_out[(j + 4) << 1 | 1];
        default: parity[j] = 1'b0;
      endcase
    end
  end

  // Step 4: Insert the calculated parity bits into data_out
  integer k;
  always_comb begin
    for (k = 0; k < PARITY_BIT; k++) begin
      case (k)
        0: data_out[(k + 1) << 1 | 1] = parity[k];
        1: data_out[(k + 2) << 1 | 1] = parity[k];
        2: data_out[(k + 4) << 1 | 1] = parity[k];
        default: break;
      endcase
    end
  end

endmodule
