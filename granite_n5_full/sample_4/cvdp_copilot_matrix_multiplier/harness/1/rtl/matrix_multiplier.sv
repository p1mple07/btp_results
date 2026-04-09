module matrix_multiplier #(
  parameter int ROW_A = 4,
  parameter int COL_A = 4,
  parameter int ROW_B = 4,
  parameter int COL_B = 4,
  parameter int INPUT_DATA_WIDTH = 8,
  parameter int OUTPUT_DATA_WIDTH = (ROW_B * INPUT_DATA_WIDTH),
  localparam int PRODUCTS_PER_CYCLE = (OUTPUT_DATA_WIDTH / INPUT_DATA_WIDTH),
  localparam int COL_PRODUCTS = (COL_A * PRODUCTS_PER_CYCLE)
)(
  input [ (ROW_A * COL_A * INPUT_DATA_WIDTH) -1 : 0] matrix_a,
  input [ (ROW_B * COL_B * INPUT_DATA_WIDTH) -1 : 0] matrix_b,
  output [ (ROW_A * COL_B * OUTPUT_DATA_WIDTH) -1 : 0] matrix_c
);

  //... (rest of the code goes here)
  
endmodule