module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = COL_A,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 32
) (
    input [INPUT_DATA_WIDTH-1:0] matrix_a [ROW_A-1:0][COL_A-1:0],
    input [INPUT_DATA_WIDTH-1:0] matrix_b [ROW_B-1:0][COL_B-1:0],
    output [OUTPUT_DATA_WIDTH-1:0] matrix_c [ROW_A-1:0][COL_B-1:0]
);

    integer i, j, k, col_index;

    always_comb begin
        matrix_c = new [OUTPUT_DATA_WIDTH-1:0][ROW_A-1:0][COL_B-1:0];
        for (i = 0; i < ROW_A; i++) begin
            for (j = 0; j < COL_B; j++) begin
                col_index = j;
                matrix_c[i][j] = 0;
                for (k = 0; k < COL_A; k++) begin
                    matrix_c[i][j] = matrix_c[i][j] + (matrix_a[i][k] * matrix_b[k][col_index]);
                end
            end
        end
    end

endmodule
