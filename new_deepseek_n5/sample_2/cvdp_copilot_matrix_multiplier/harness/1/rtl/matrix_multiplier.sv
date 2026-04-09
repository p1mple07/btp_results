parameter ROW_A = 4;
parameter COL_A = 4;
parameter ROW_B = 4;
parameter COL_B = 4;
parameter INPUT_DATA_WIDTH = 8;
parameter OUTPUT_DATA_WIDTH = 16;

input matrix_a[(ROW_A-1)*COL_A*INPUT_DATA_WIDTH + {(ROW_A-1)*COL_A, 0, 0, 0}] unsigned;
input matrix_b[(ROW_B-1)*COL_B*INPUT_DATA_WIDTH + {(ROW_B-1)*COL_B, 0, 0, 0}] unsigned;
output matrix_c[(ROW_A-1)*COL_B*OUTPUT_DATA_WIDTH + {(ROW_A-1)*COL_B, 0, 0, 0}] unsigned;

integer i, j, k;
integer index_c;

for (i = 0; i < ROW_A; i++) begin
    for (j = 0; j < COL_B; j++) begin
        index_c = i * COL_B * OUTPUT_DATA_WIDTH + i * COL_B + j;
        integer sum = 0;
        for (k = 0; k < COL_A; k++) begin
            integer a = matrix_a[i * COL_A * INPUT_DATA_WIDTH + i * COL_A + k];
            integer b = matrix_b[k * COL_B * INPUT_DATA_WIDTH + k * COL_B + j];
            sum = sum + (a * b);
        end
        matrix_c[index_c] = sum;
    end
end