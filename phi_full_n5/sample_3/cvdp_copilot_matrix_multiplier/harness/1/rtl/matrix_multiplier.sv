module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = COL_A,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 16 // Calculated to handle potential overflow
) (
    input logic [INPUT_DATA_WIDTH-1:0] matrix_a [ROW_A-1:0][COL_A-1:0],
    input logic [INPUT_DATA_WIDTH-1:0] matrix_b [ROW_B-1:0][COL_B-1:0],
    output logic [OUTPUT_DATA_WIDTH-1:0] matrix_c [ROW_A-1:0][COL_B-1:0]
);

    // Intermediate storage for the multiplication results
    logic [OUTPUT_DATA_WIDTH-1:0] temp_result [ROW_A-1:0][COL_B-1:0];

    // Compute the product of each row of matrix_a with each column of matrix_b
    generate
        for (int i = 0; i < ROW_A; i++) begin
            for (int j = 0; j < COL_B; j++) begin
                for (int k = 0; k < COL_A; k++) begin
                    temp_result[i][j] = temp_result[i][j] +
                                        ((matrix_a[i][k] & matrix_b[k][j]) << (INPUT_DATA_WIDTH * k));
                end
            end
        end
    endgenerate

    // Assign the computed result to the output matrix
    assign matrix_c = temp_result;

endmodule
