module matrix_multiplier #(
  parameter ROW_A             = 4                                                  , // Number of rows in matrix A
  parameter COL_A             = 4                                                  , // Number of columns in matrix A
  parameter ROW_B             = 4                                                  , // Number of rows in matrix B
  parameter COL_B             = 4                                                  , // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8                                                  , // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)                // Bit-width of output data
) (
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a, // Input matrix A in 1D form
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b, // Input matrix B in 1D form
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c  // Output matrix C in 1D form
);
  typedef logic [OUTPUT_DATA_WIDTH-1:0] data_type;

  data_type matrix_c_stage [(ROW_A*COL_A)*(COL_B)]; // Intermediate storage for multiplication results

  always @(posedge clk or posedge srst) begin
    if (srst) begin
      for (int i = 0; i < (ROW_A*COL_A)*(COL_B); i++) begin
        matrix_c_stage[i] <= 0;
      end
    end else begin
      if (valid_out) begin
        for (int i = 0; i < COL_B; i++) begin
          for (int j = 0; j < COL_A; j++) begin
            if (j == 0) begin
              matrix_c_stage[(i*(COL_A)) + j] <= matrix_a[(i*(COL_A)) + j] * matrix_b[(i*(COL_B)) + 0];
            end else begin
              matrix_c_stage[(i*(COL_A)) + j] <= matrix_c_stage[(i*(COL_A)) + (j-1)] + (matrix_a[(i*(COL_A)) + j] * matrix_b[(i*(COL_B)) + j-1]);
            end
          end
        end

        for (int i = 0; i < (ROW_A*COL_B); i++) begin
          if (i % COL_A == 0) begin
            matrix_c[i] <= matrix_c_stage[i].s[OUTPUT_DATA_WIDTH-1:0];
          end
        end
      end
    end
  end

endmodule