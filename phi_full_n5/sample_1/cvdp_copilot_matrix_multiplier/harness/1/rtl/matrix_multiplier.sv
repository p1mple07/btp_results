module matrix_multiplier #(
    parameter int ROW_A = 4,
    parameter int COL_A = 4,
    parameter int ROW_B = COL_A,
    parameter int COL_B = 4,
    parameter logic [7:0] INPUT_DATA_WIDTH = 8,
    parameter logic [7:0] OUTPUT_DATA_WIDTH // Calculated to handle overflow
) (
    input logic [INPUT_DATA_WIDTH-1:0] matrix_a[ROW_A-1:0][COL_A-1:0][INPUT_DATA_WIDTH],
    input logic [INPUT_DATA_WIDTH-1:0] matrix_b[ROW_B-1:0][COL_B-1:0][INPUT_DATA_WIDTH],
    output logic [OUTPUT_DATA_WIDTH-1:0] matrix_c[ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH]
);

    // Internal declaration for the output matrix
    logic [OUTPUT_DATA_WIDTH-1:0] flattened_matrix_c[ROW_A*COL_B-1:0];

    // Combinational logic to calculate the multiplication and store the result
    always_comb begin
        integer i, j, k;
        for (i = 0; i < ROW_A; i++) begin
            for (j = 0; j < COL_B; j++) begin
                flattened_matrix_c[i*COL_B+j] = 0; // Initialize the result to zero
                for (k = 0; k < COL_A; k++) begin
                    flattened_matrix_c[i*COL_B+j] += matrix_a[i][k][:] * matrix_b[k][j][:];
                end
            end
        end
    end

    // Assigning the flattened result to the output matrix
    always_comb begin
        integer index;
        for (index = 0; index < ROW_A*COL_B; index++) begin
            matrix_c[index][:] = flattened_matrix_c[index];
        end
    end

endmodule
