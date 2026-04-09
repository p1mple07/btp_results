rtl/matrix_multiplier.sv
--------------------------------------------------
module matrix_multiplier #(
  parameter ROW_A             = 4,                       // Number of rows in matrix A
  parameter COL_A             = 4,                       // Number of columns in matrix A
  parameter ROW_B             = 4,                       // Number of rows in matrix B
  parameter COL_B             = 4,                       // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8,                       // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A) // Bit-width of output data
) (
  input  logic clk,
  input  logic srst,
  input  logic valid_in,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic