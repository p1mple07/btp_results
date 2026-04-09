module nbit_swizzling (#(parameter DATA_WIDTH = 64));
  parameter PARITY_BITS = $clog2(DATA_WIDTH + $clog2(DATA_WIDTH)) + 1;

  integer i;
  wire [DATA_WIDTH + PARITY_BITS - 1 : 0] ecc_out;

  assign parity_bit = ^data_in;

  always @(*) begin
    case(sel)
      2'b00: begin
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
          data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
      end
      2'b01: begin
        for (i = 0; i < DATA_WIDTH / 2; i = i + 1) begin
          data_out[i] = data_in[DATA_WIDTH / 2 - 1 - i];
          data_out[DATA_WIDTH / 2 + i] = data_in[DATA_WIDTH - 1 - i];
        end
      end
      2'b10: begin
        for (i = 0; i < DATA_WIDTH / 4; i = i + 1) begin
          data_out[i] = data_in[DATA_WIDTH / 4 - 1 - i];
          data_out[DATA_WIDTH / 4 + i] = data_in[DATA_WIDTH / 2 - 1 - i];
          data_out[DATA_WIDTH / 2 + i] = data_in[3 * DATA_WIDTH / 4 - 1 - i];
          data_out[3 * DATA_WIDTH / 4 + i] = data_in[DATA_WIDTH - 1 - i];
        end
      end
      2'b11: begin
        for (i = 0; i < DATA_WIDTH / 8; i = i + 1) begin
          data_out[i] = data_in[DATA_WIDTH / 8 - 1 - i];
          data_out[DATA_WIDTH / 8 + i] = data_in[DATA_WIDTH / 4 - 1 - i];
          data_out[DATA_WIDTH / 4 + i] = data_in[3 * DATA_WIDTH / 8 - 1 - i];
          data_out[3 * DATA_WIDTH / 8 + i] = data_in[DATA_WIDTH / 2 - 1 - i];
          data_out[DATA_WIDTH / 2 + i] = data_in[5 * DATA_WIDTH / 8 - 1 - i];
          data_out[5 * DATA_WIDTH / 8 + i] = data_in[3 * DATA_WIDTH / 4 - 1 - i];
          data_out[3 * DATA_WIDTH / 4 + i] = data_in[7 * DATA_WIDTH / 8 - 1 - i];
          data_out[7 * DATA_WIDTH / 8 + i] = data_in[DATA_WIDTH - 1 - i];
        end
      end
      default: begin
        data_out = data_in;
        data_out[DATA_WIDTH] = parity_bit;
      end
    endcase
  end

  // Compute parity bits
  for (int p = 0; p < PARITY_BITS; p++) begin
    ecc_out[DATA_WIDTH + p] = parity_bit_for_pos(p);
  end

  assign data_out = [data_in, ecc_out];
endmodule
