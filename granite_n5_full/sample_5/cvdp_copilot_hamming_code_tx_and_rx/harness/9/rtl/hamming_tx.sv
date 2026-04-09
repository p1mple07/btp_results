module hamming_tx #(
  parameter int DATA_WIDTH = 4,
  parameter int PARITY_BIT = 3
)(
  input wire [DATA_WIDTH-1:0] data_in,
  output logic [DATA_WIDTH+PARITY_BIT+1-1:0] data_out
);

  localparam int ENCODED_DATA = PARITY_BIT + DATA_WIDTH + 1;
  localparam int ENCODED_DATA_BIT = $clog2(Encoded Data Width);
  
  // Step 1: Initialize Internal Registers
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      parity <= 0;
    end else begin
      parity <= 0;
    end
  end

  // Step 2: Assign data_in to data_out
  assign data_out = {data_in, 1'b0};

  // Step 3: Calculate Even Parity Bits
  always_comb begin
    parity[0] = data_out[1] ^ data_out[3] ^ data_out[5] ^ data_out[7];
    parity[1] = data_out[2] ^ data_out[3] ^ data_out[6] ^ data_out[7];
    parity[2] = data_out[0] ^ data_out[1] ^ data_out[2] ^ data_out[3] ^ data_out[4] ^ data_out[5] ^ data_out[6] ^ data_out[7] ^ data_out[8] ^ data_out[9] ^ data_out[10] ^ data_out[11];
  end

  // Step 4: Insert calculated parity bits into data_out
  always_comb begin
    data_out = {data_out[0], parity[0], parity[1], parity[2]};
  end

endmodule