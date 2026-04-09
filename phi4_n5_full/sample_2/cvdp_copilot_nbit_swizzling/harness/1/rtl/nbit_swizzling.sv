module nbit_swizzling #(
  parameter DATA_WIDTH = 64
)(
  input  logic [DATA_WIDTH-1:0] data_in,
  input  logic [1:0]            sel,
  output logic [DATA_WIDTH-1:0] data_out
);

  always_comb begin
    case (sel)
      2'b00: begin
        // Reverse the entire input.
        for (int i = 0; i < DATA_WIDTH; i++) begin
          data_out[i] = data_in[DATA_WIDTH-1-i];
        end
      end
      2'b01: begin
        // Divide into two equal halves and reverse each half.
        int half = DATA_WIDTH / 2;
        for (int j = 0; j < 2; j++) begin
          // For the first half, the MSB of that segment is at DATA_WIDTH-1.
          // For the second half, the MSB is at half-1.
          for (int i = 0; i < half; i++) begin
            data_out[j*half + i] = data_in[(j==0 ? DATA_WIDTH-1 : half-1) - i];
          end
        end
      end
      2'b10: begin
        // Divide into four equal quarters and reverse each quarter.
        int quarter = DATA_WIDTH / 4;
        for (int j = 0; j < 4; j++) begin
          for (int i = 0; i < quarter; i++) begin
            data_out[j*quarter + i] = data_in[DATA_WIDTH - 1 - j*quarter - i];
          end
        end
      end
      2'b11: begin
        // Divide into eight equal eighths and reverse each eighth.
        int eighth = DATA_WIDTH / 8;
        for (int j = 0; j < 8; j++) begin
          for (int i = 0; i < eighth; i++) begin
            data_out[j*eighth + i] = data_in[DATA_WIDTH - 1 - j*eighth - i];
          end
        end
      end
      default: begin
        // In the default case, pass the input directly.
        data_out = data_in;
      end
    endcase
  end

endmodule