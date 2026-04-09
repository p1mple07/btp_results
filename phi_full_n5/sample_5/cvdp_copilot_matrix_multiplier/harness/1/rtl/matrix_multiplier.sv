module matrix_multiplier #(parameter INPUT_DATA_WIDTH = 8,
                          parameter OUTPUT_DATA_WIDTH = 16)
(
    input logic [INPUT_DATA_WIDTH-1:0] matrix_a[ROW_A-1:0][COL_A-1:0][INPUT_DATA_WIDTH],
    input logic [INPUT_DATA_WIDTH-1:0] matrix_b[ROW_B-1:0][COL_B-1:0][INPUT_DATA_WIDTH],
    output logic [OUTPUT_DATA_WIDTH-1:0] matrix_c[ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH]
);

    // Local variables for intermediate sums
    logic [OUTPUT_DATA_WIDTH-1:0] sum_row_elements [ROW_A-1:0][COL_B-1:0];

    // Compute the product matrix
    always_comb begin
        for (int i = 0; i < ROW_A; i++) begin
            for (int j = 0; j < COL_B; j++) begin
                sum_row_elements[i][j] = 0;
                for (int k = 0; k < COL_A; k++) begin
                    sum_row_elements[i][j] += matrix_a[i][k][INPUT_DATA_WIDTH] * matrix_b[k][j][INPUT_DATA_WIDTH];
                end
            end
        end

        // Assign the computed values to the output matrix
        for (int i = 0; i < ROW_A; i++) begin
            for (int j = 0; j < COL_B; j++) begin
                matrix_c[i][j] = sum_row_elements[i][j];
            end
        end
    end

endmodule
