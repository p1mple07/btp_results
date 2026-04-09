module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic clk,
  input  logic srst,
  input  logic valid_in,
  input  logic [(ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [(ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

  logic [COL_A-1:0] intermediate_products [ROW_A:0];
  logic [OUTPUT_DATA_WIDTH-1:0] accumulated_results [ROW_B:0];
  logic [OUTPUT_DATA_WIDTH-1:0] temp_accumulated_results [ROW_B:0];
  logic [OUTPUT_DATA_WIDTH-1:0] valid_out_temp;

  always_ff @(posedge clk) begin
    if (srst) begin
      // Reset all registers and outputs
      for (int i = 0; i < ROW_A; i++) begin
        intermediate_products[i] <= 0;
      end
      for (int i = 0; i < COL_B; i++) begin
        accumulated_results[i] <= 0;
      end
      for (int i = 0; i < COL_A; i++) begin
        temp_accumulated_results[i] <= 0;
      end
      valid_out <= 0;
    end else begin
      // Computation stages
      if (valid_in) begin
        // Multiplication stage
        for (int i = 0; i < ROW_A; i++) begin
          for (int j = 0; j < COL_B; j++) begin
            for (int k = 0; k < COL_A; k++) begin
              intermediate_products[i] = intermediate_products[i] +
                matrix_a[i*COL_A*INPUT_DATA_WIDTH + k*INPUT_DATA_WIDTH] *
                matrix_b[j*COL_B*INPUT_DATA_WIDTH + k*INPUT_DATA_WIDTH];
            end
          end
        end

        // Accumulation stage
        for (int i = 0; i < COL_B; i++) begin
          accumulated_results[i] = temp_accumulated_results[i] +
            intermediate_products[COL_A-1-i];
        end

        // Output stage
        for (int i = 0; i < COL_B; i++) begin
          valid_out_temp = accumulated_results[i];
          temp_accumulated_results[i] = 0;
          accumulated_results[i] <= valid_out_temp;
        end

        valid_out = valid_out_temp;
      end
    end
  end

  assign matrix_c = {COL_B{valid_out}}, // Flatten the valid_out signal
                {[(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0](valid_out)};

endmodule
