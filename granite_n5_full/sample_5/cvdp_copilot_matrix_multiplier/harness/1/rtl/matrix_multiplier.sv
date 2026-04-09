module matrix_multiplier #(
  parameter ROW_A     = 4,
  parameter COL_A     = 4,
  parameter ROW_B     = 4,
  parameter COL_B     = 4,
  parameter INPUT_DATA_WIDTH = 8,
  parameter OUTPUT_DATA_WIDTH = $clog2(ROW_A * COL_B) + INPUT_DATA_WIDTH
)(
  // Input ports
  input wire [ (ROW_A * COL_A * INPUT_DATA_WIDTH) -1 : 0] matrix_a,
  input wire [ (ROW_B * COL_B * INPUT_DATA_WIDTH) -1 : 0] matrix_b,
  
  // Output port
  output wire [ (ROW_A * COL_B * OUTPUT_DATA_WIDTH) -1 : 0] matrix_c
);

  // Define internal signals and variables here

  // Implement the matrix multiplication algorithm here

  // Assign the output signal here

endmodule