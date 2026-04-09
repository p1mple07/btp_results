module hamming_rx #(parameter DATA_WIDTH = 4, parameter PARITY_BIT = 3) (
    input [ENCODED_DATA-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);

  wire [PARITY_BIT-1:0] parity;
  wire error;

  // Initialize all internal registers to 0
  initial begin
    parity = {PARITY_BIT{1'b0}};
    error = 1'b0;
  end

  // Error detection using even parity logic
  // Rule for power-of-2 positions
  genvar i;
  always_comb begin
    for (i = 0; i < PARITY_BIT; i++) begin
      case (i)
        0: parity[0] = data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        1: parity[1] = data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        2: parity[2] = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        default: parity[i] = 1'b0;
      endcase
    end

    // Error detection code
    error = (parity == {PARITY_BIT{1'b0}}) ? 1'b0 : 1'b1;
  end

  // Error correction
  always_comb begin
    if (error) begin
      // Calculate the error position
      int error_pos;
      for (error_pos = 0; error_pos < ENCODED_DATA; error_pos++) begin
        if (parity[PARITY_BIT-1:0] == {error_pos}) begin
          // Invert the erroneous bit
          data_in[error_pos] = ~data_in[error_pos];
          break;
        end
      end
    end
  end

  // Output assignment
  assign data_out = {data_in[3], data_in[5], data_in[6], data_in[7]};

endmodule
