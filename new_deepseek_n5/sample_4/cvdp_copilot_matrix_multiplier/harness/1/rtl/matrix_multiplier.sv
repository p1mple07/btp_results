parameter ROW_A = 4;
parameter COL_A = 4;
parameter ROW_B = 4;
parameter COL_B = 4;
parameter INPUT_DATA_WIDTH = 8;
parameter OUTPUT_DATA_WIDTH = 16;

input matrix_a[(ROW_A*COL_A)-1:0][INPUT_DATA_WIDTH];
input matrix_b[(ROW_B*COL_B)-1:0][INPUT_DATA_WIDTH];
output matrix_c[(ROW_A*COL_B)-1:0][OUTPUT_DATA_WIDTH];

reg matrix_a[(ROW_A*COL_A)-1:0][INPUT_DATA_WIDTH];
reg matrix_b[(ROW_B*COL_B)-1:0][INPUT_DATA_WIDTH];
reg matrix_c[(ROW_A*COL_B)-1:0][OUTPUT_DATA_WIDTH];

always_comb begin
    for (int i = 0; i < ROW_A; i++) begin
        for (int j = 0; j < COL_B; j++) begin
            integer sum = 0;
            for (int k = 0; k < COL_A; k++) begin
                sum += matrix_a[i][k] * matrix_b[k][j];
            end
            matrix_c[i * COL_B + j] = (sum) [ (OUTPUT_DATA_WIDTH-1):0 ];
        end
    end
end