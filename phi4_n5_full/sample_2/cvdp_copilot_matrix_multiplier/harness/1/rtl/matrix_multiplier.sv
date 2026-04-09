module matrix_multiplier #(
  parameter int ROW_A     = 4,
  parameter int COL_A     = 4,
  parameter int ROW_B     = 4,  // Must equal COL_A for valid multiplication
  parameter int COL_B     = 4,
  parameter int INPUT_DATA_WIDTH = 8,
  // OUTPUT_DATA_WIDTH is calculated to cover two INPUT_DATA_WIDTH numbers plus extra bits for accumulation.
  parameter int OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
)(
  input  logic [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] matrix_a,
  input  logic [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] matrix_b,
  output logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

  // The design is purely combinational.
  // Note: The flattened input vectors are assumed to be stored in little-endian order.
  // That is, for matrix A of size ROW_A x COL_A, the element A[i][j] is stored at:
  //    matrix_a[((i*COL_A + j + 1)*INPUT_DATA_WIDTH - 1) -: INPUT_DATA_WIDTH]
  // and similarly for matrix B.
  //
  // The output matrix C (of size ROW_A x COL_B) is produced with the same ordering:
  //    matrix_c[((i*COL_B + j + 1)*OUTPUT_DATA_WIDTH - 1) -: OUTPUT_DATA_WIDTH]
  // For example, for a 2x2 matrix C, the flattened representation will be:
  //    matrix_c = { c22, c21, c12, c11 }
  // (i.e. the LSB corresponds to c11).

  always_comb begin
    integer i, j, k;
    for (i = 0; i < ROW_A; i = i + 1) begin
      for (j = 0; j < COL_B; j = j + 1) begin
        logic [OUTPUT_DATA_WIDTH-1:0] sum;
        sum = '0;
        for (k = 0; k < COL_A; k = k + 1) begin
          logic [INPUT_DATA_WIDTH-1:0] a_val, b_val;
          // Extract element A[i][k] from the flattened matrix_a.
          // The element is located starting at bit: ((i*COL_A + k + 1)*INPUT_DATA_WIDTH - 1)
          a_val = matrix_a[ ((i*COL_A + k + 1)*INPUT_DATA_WIDTH - 1) -: INPUT_DATA_WIDTH ];
          // Extract element B[k][j] from the flattened matrix_b.
          b_val = matrix_b[ ((k*COL_B + j + 1)*INPUT_DATA_WIDTH - 1) -: INPUT_DATA_WIDTH ];
          sum = sum + a_val * b_val;
        end
        // Assign the computed sum to the corresponding slice of matrix_c.
        // For element C[i][j], the slice is:
        //    matrix_c[ ((i*COL_B + j + 1)*OUTPUT_DATA_WIDTH - 1) -: OUTPUT_DATA_WIDTH ]
        matrix_c[ ((i*COL_B + j + 1)*OUTPUT_DATA_WIDTH - 1) -: OUTPUT_DATA_WIDTH ] = sum;
      end
    end
  end

endmodule