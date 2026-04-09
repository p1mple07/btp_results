parameter ROW_A = 4;
parameter COL_A = 4;
parameter ROW_B = 4;
parameter COL_B = 4;
parameter INPUT_DATA_WIDTH = 8;
parameter OUTPUT_DATA_WIDTH = 16;

// Matrix A (RTL) input
input [ (ROW_A * COL_A) * INPUT_DATA_WIDTH - 1 : 0 ] matrix_a;

// Matrix B (RTL) input
input [ (ROW_B * COL_B) * INPUT_DATA_WIDTH - 1 : 0 ] matrix_b;

// Matrix C (RTL) output
output [ (ROW_A * COL_B) * OUTPUT_DATA_WIDTH - 1 : 0 ] matrix_c;

// Module Implementation
parameter i, j, k;

for (i = 0; i < ROW_A; i++) begin
    for (j = 0; j < COL_B; j++) begin
        integer sum = 0;
        for (k = 0; k < COL_A; k++) begin
            sum += matrix_a[ (i * COL_A) + k ] * matrix_b[ (k * COL_B) + j ];
        end
        matrix_c[ (i * COL_B) + j ] = sum;
    end
end