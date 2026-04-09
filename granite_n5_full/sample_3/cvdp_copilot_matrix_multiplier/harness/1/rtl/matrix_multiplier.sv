module matrix_multiplier #(
  parameter int ROW_A = 4,
  parameter int COL_A = 4,
  parameter int ROW_B = 4,
  parameter int COL_B = 4,
  parameter int INPUT_DATA_WIDTH = 8,
  parameter int OUTPUT_DATA_WIDTH = $clog2(ROW_B * COL_A) + INPUT_DATA_WIDTH
) (
  input wire [ROW_A*COL_A*INPUT_DATA_WIDTH-1:0] matrix_a,
  input wire [ROW_B*COL_B*INPUT_DATA_WIDTH-1:0] matrix_b,
  output reg [(ROW_A*COL_B)*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

  // Check if the dimensions of the matrices are valid
  generate
    if (ROW_A * COL_A!= ROW_B * COL_B) begin
      $error("Invalid matrix dimensions");
    end
  endgenerate

  // Calculate the product of the matrices
  always @(*) begin
    for (int row = 0; row < ROW_A; row++) begin
      for (int col = 0; col < COL_B; col++) begin
        int prod = 0;
        for (int k = 0; k < COL_A; k++) begin
          prod += matrix_a[(row*COL_A)+k] * matrix_b[(k*COL_B)+col];
        end
        matrix_c[(row*COL_B)+col] = prod[$clog2(ROW_B * COL_A)-1:0];
      end
    end
  end

endmodule