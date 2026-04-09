module matrix_multiplier #(
  parameter ROW_A     = 4, 
  parameter COL_A     = 4, 
  parameter ROW_B     = 4, // Assuming square matrices
  parameter COL_B     = ROW_A, 
  parameter INPUT_DATA_WIDTH = 8, 
  parameter OUTPUT_DATA_WIDTH = $clog2(COL_B*ROW_A) // Calculated to handle potential overflow from multiplication
) (
  input [ (ROW_A * COL_A * INPUT_DATA_WIDTH)-1 : 0] matrix_a,
  input [ (ROW_B * COL_B * INPUT_DATA_WIDTH)-1 : 0] matrix_b,
  output reg [ (ROW_A * COL_B * OUTPUT_DATA_WIDTH)-1 : 0] matrix_c
);

// Convert flattened matrices to 2D arrays
reg [ (ROW_A*INPUT_DATA_WIDTH)-1 : 0 ] flattened_matrix_a [0 : ROW_A-1];
reg [ (ROW_B*INPUT_DATA_WIDTH)-1 : 0 ] flattened_matrix_b [0 : ROW_B-1];
reg [ (ROW_A*ROW_B*OUTPUT_DATA_WIDTH)-1 : 0 ] flattened_matrix_c;

// Assign flattened matrices from input
assign flattened_matrix_a = {matrix_a [(ROW_A * INPUT_DATA_WIDTH)-1 : 0]};
assign flattened_matrix_b = {matrix_b [(ROW_B * INPUT_DATA_WIDTH)-1 : 0]};

// Perform matrix multiplication
generate
  if (ROW_B == COL_A) begin : matrix_multiplication
    genvar i;
    generate
      for (i=0; i<ROW_A; i++) begin
        assign flattened_matrix_c[((ROW_B-1)*OUTPUT_DATA_WIDTH)+:OUTPUT_DATA_WIDTH] =
            $signed(flattened_matrix_a[((ROW_A-1)*INPUT_DATA_WIDTH)+:INPUT_DATA_WIDTH]) *
            $signed(flattened_matrix_b[((ROW_B-1)*INPUT_DATA_WIDTH)+:INPUT_DATA_WIDTH]);
      end
    endgenerate
  end else begin : invalid_matrix_size
    // Handle invalid matrix size error
    initial $display("Error: Invalid matrix size. Row A (%d) and Column B (%d) must be equal.", ROW_A, COL_B);
    $stop();
  end
endgenerate

// Convert flattened output back to 2D array
assign matrix_c = {flattened_matrix_c[(ROW_A*ROW_B*OUTPUT_DATA_WIDTH)-1 : 0]};

endmodule