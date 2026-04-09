module matrix_multiplier #(
  parameter int ROW_A             = 4,
  parameter int COL_A             = 4,
  parameter int ROW_B             = 4,  // Must equal COL_A for valid multiplication
  parameter int COL_B             = 4,
  parameter int INPUT_DATA_WIDTH  = 8,
  // OUTPUT_DATA_WIDTH is chosen to safely accommodate the maximum sum:
  // Each product is 2*INPUT_DATA_WIDTH bits and we sum COL_A products.
  // An extra bit is added for safety.
  parameter int OUTPUT_DATA_WIDTH = (2 * INPUT_DATA_WIDTH) + $clog2(COL_A) + 1
) (
  input  wire [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] matrix_a,
  input  wire [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] matrix_b,
  output wire [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

  // Check that matrix dimensions are compatible for multiplication.
  // ROW_B must equal COL_A.
  initial begin
    if (ROW_B != COL_A) begin
      $error("Matrix dimensions are incompatible: ROW_B (%0d) must equal COL_A (%0d)", ROW_B, COL_A);
      $finish;
    end
  end

  // Combinational logic to compute matrix multiplication.
  // The flattened representation is assumed to be in reverse row-major order:
  // For matrix A: element (row, col) is stored at index (ROW_A*COL_A - 1) - (row*COL_A + col)
  // For matrix B: element (row, col) is stored at index (ROW_B*COL_B - 1) - (row*COL_B + col)
  // For matrix C: element (row, col) is stored at index (ROW_A*COL_B - 1) - (row*COL_B + col)
  always_comb begin
    integer row, col, k;
    for (row = 0; row < ROW_A; row = row + 1) begin
      for (col = 0; col < COL_B; col = col + 1) begin
        logic [OUTPUT_DATA_WIDTH-1:0] sum;
        sum = '0;
        for (k = 0; k < COL_A; k = k + 1) begin
          // Extract element from matrix_a at position (row, k)
          // Flattened index: (ROW_A*COL_A - 1) - (row*COL_A + k)
          // Slice width: INPUT_DATA_WIDTH bits.
          // Extract element from matrix_b at position (k, col)
          // Flattened index: (ROW_B*COL_B - 1) - (k*COL_B + col)
          // Slice width: INPUT_DATA_WIDTH bits.
          sum = sum + (
            matrix_a[(ROW_A*COL_A - 1) - (row*COL_A + k)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] *
            matrix_b[(ROW_B*COL_B - 1) - (k*COL_B + col)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH]
          );
        end
        // Store the computed sum in matrix_c at position (row, col)
        // Flattened index: (ROW_A*COL_B - 1) - (row*COL_B + col)
        // Slice width: OUTPUT_DATA_WIDTH bits.
        matrix_c[(ROW_A*COL_B - 1) - (row*COL_B + col)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] = sum;
      end
    end
  end

endmodule