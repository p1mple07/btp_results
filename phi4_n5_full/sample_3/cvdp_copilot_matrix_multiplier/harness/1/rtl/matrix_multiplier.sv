module matrix_multiplier #(
  parameter int ROW_A        = 4,  // Number of rows in matrix A
  parameter int COL_A        = 4,  // Number of columns in matrix A
  parameter int ROW_B        = 4,  // Number of rows in matrix B (must equal COL_A)
  parameter int COL_B        = 4,  // Number of columns in matrix B
  parameter int INPUT_DATA_WIDTH = 8,  // Bit-width of each unsigned element in input matrices
  parameter int OUTPUT_DATA_WIDTH = 16 // Bit-width of each unsigned element in the output matrix
)(
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1 : 0 ] matrix_a,  // Flattened matrix A (row-major order reversed per row & col)
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1 : 0 ] matrix_b,  // Flattened matrix B (row-major order reversed per row & col)
  output logic [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1 : 0 ] matrix_c   // Flattened matrix C (result of multiplication)
);

  //-------------------------------------------------------------------------
  // Internal Array for Computed Output Elements
  //-------------------------------------------------------------------------
  // We create an array of wires, one for each output element (ROW_A x COL_B).
  // The final flattened order will be constructed in the next generate block.
  wire [OUTPUT_DATA_WIDTH-1:0] c_elem [0:ROW_A*COL_B - 1];

  //-------------------------------------------------------------------------
  // Generate Block: Compute Each Element of the Output Matrix
  //-------------------------------------------------------------------------
  // For each output element c[i][j], compute:
  //   c[i][j] = Σ (over k = 0 to COL_A-1) { A[i][k] * B[k][j] }
  //
  // Note:
  //   - The flattened indexing for matrix A: element at row i, col k is at index:
  //         (ROW_A - i - 1) * COL_A + (COL_A - k - 1)
  //   - Similarly, for matrix B: element at row k, col j is at index:
  //         (ROW_B - k - 1) * COL_B + (COL_B - j - 1)
  generate
    genvar i, j, k;
    for (i = 0; i < ROW_A; i = i + 1) begin : gen_row
      for (j = 0; j < COL_B; j = j + 1) begin : gen_col
        // Create an array to hold the partial products for each multiplication term.
        wire [OUTPUT_DATA_WIDTH-1:0] partial [0:COL_A - 1];
        // First partial product for k = 0:
        assign partial[0] =
          matrix_a[(ROW_A - i - 1)*COL_A + (COL_A - 0 - 1)] *
          matrix_b[(ROW_B - 0 - 1)*COL_B + (COL_B - j - 1)];
        // Chain the remaining partial products with addition.
        generate
          for (k = 1; k < COL_A; k = k + 1) begin : gen_partial_sum
            assign partial[k] =
              partial[k-1] +
              ( matrix_a[(ROW_A - i - 1)*COL_A + (COL_A - k - 1)] *
                matrix_b[(ROW_B - k - 1)*COL_B + (COL_B - j - 1)] );
          end
        endgenerate
        // The final computed value for element (i, j) is stored in partial[COL_A-1].
        assign c_elem[i*COL_B + j] = partial[COL_A - 1];
      end
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Generate Block: Flatten the Computed Matrix into the Output Vector
  //-------------------------------------------------------------------------
  // The flattened representation for the output matrix is defined such that:
  //   For element at (i, j), its flattened index is:
  //         (ROW_A - i - 1) * COL_B + (COL_B - j - 1)
  // We assign each computed element (stored in c_elem) to the corresponding slice
  // of the output vector 'matrix_c'.
  generate
    for (i = 0; i < ROW_A; i = i + 1) begin : gen_flat_row
      for (j = 0; j < COL_B; j = j + 1) begin : gen_flat_col
        // Compute the starting bit index for the element (i, j) in matrix_c.
        // The slice is of width OUTPUT_DATA_WIDTH.
        assign matrix_c[ ((ROW_A - i - 1)*COL_B + (COL_B - j - 1)) * OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH ] =
                c_elem[i*COL_B + j];
      end
    end
  endgenerate

endmodule