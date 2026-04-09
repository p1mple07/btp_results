module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = $clog2(ROW_A * COL_B + 1)
)(
    input [INPUT_DATA_WIDTH - 1:0] matrix_a [ROW_A - 1:0][COL_A - 1:0],
    input [INPUT_DATA_WIDTH - 1:0] matrix_b [ROW_B - 1:0][COL_B - 1:0],
    output [OUTPUT_DATA_WIDTH - 1:0] matrix_c [ROW_A - 1:0][COL_B - 1:0]
);

// Your code implementation here

endmodule