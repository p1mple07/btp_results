
module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                  clk,
  input  logic                  srst,
  input  logic                  valid_in,
  input  logic [(ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [(ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic                  valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);
