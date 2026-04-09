module matrix_multiplier #(
  parameter ROW_A      = 4,
  parameter COL_A      = 4,
  parameter ROW_B      = 4,  // Must equal COL_A for valid multiplication
  parameter COL_B      = 4,
  parameter INPUT_DATA_WIDTH = 8,
  // OUTPUT_DATA_WIDTH is set to handle the maximum sum from multiplying
  // two INPUT_DATA_WIDTH-bit numbers and summing COL_A products.
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH*2 + $clog2(COL_A))
)(
  input  logic [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] matrix_a,
  input  logic [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] matrix_b,
  output logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

  // The flattened representation of each matrix is in reversed order:
  // For an element at row i and column j in a matrix with ROWS x COLS,
  // the flattened index is: (ROWS*COLS - 1) - (i*COLS + j).

  always_comb begin
    // Temporary variable to hold the computed output matrix.
    logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] local_matrix_c;

    // Loop over rows of matrix_a and columns of matrix_b.
    for (int i = 0; i < ROW_A; i++) begin
      for (int j = 0; j < COL_B; j++) begin
        logic [OUTPUT_DATA_WIDTH-1:0] sum = '0;
        // Loop over the common dimension: columns of matrix_a (rows of matrix_b).
        for (int k = 0; k < COL_A; k++) begin
          // Calculate flattened indices for matrix_a and matrix_b.
          int idx_a = ROW_A*COL_A - 1 - (i*COL_A + k);
          int idx_b = ROW_B*COL_B - 1 - (k*COL_B + j);

          // Extract the individual elements.
          logic [INPUT_DATA_WIDTH-1:0] a_val = matrix_a[(idx_a*INPUT_DATA_WIDTH) +: INPUT_DATA_WIDTH];
          logic [INPUT_DATA_WIDTH-1:0] b_val = matrix_b[(idx_b*INPUT_DATA_WIDTH) +: INPUT_DATA_WIDTH];

          // Multiply and accumulate.
          sum = sum + a_val * b_val;
        end

        // Determine the flattened index for the output matrix.
        int idx_c = ROW_A*COL_B - 1 - (i*COL_B + j);
        local_matrix_c[(idx_c*OUTPUT_DATA_WIDTH) +: OUTPUT_DATA_WIDTH] = sum;
      end
    end

    // Drive the output with the computed matrix.
    matrix_c = local_matrix_c;
  end

endmodule