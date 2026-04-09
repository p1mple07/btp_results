module matrix_multiplier #(
    parameter int ROW_A = 4,
    parameter int COL_A = 4,
    parameter int ROW_B = COL_A,
    parameter int COL_B = 4,
    parameter logic [7:0] INPUT_DATA_WIDTH = 8,
    parameter logic [7:0] OUTPUT_DATA_WIDTH = 8
) (
    input logic [INPUT_DATA_WIDTH-1:0] matrix_a[ROW_A-1:0][COL_A-1:0][INPUT_DATA_WIDTH],
    input logic [INPUT_DATA_WIDTH-1:0] matrix_b[ROW_B-1:0][COL_B-1:0][INPUT_DATA_WIDTH],
    output logic [OUTPUT_DATA_WIDTH-1:0] matrix_c[ROW_A-1:0][COL_B-1:0][OUTPUT_DATA_WIDTH]
);

    // Internal storage for the flattened matrices
    logic [INPUT_DATA_WIDTH-1:0] flattened_matrix_a [ROW_A*COL_A-1:0];
    logic [INPUT_DATA_WIDTH-1:0] flattened_matrix_b [ROW_B*COL_B-1:0];
    logic [OUTPUT_DATA_WIDTH-1:0] flattened_matrix_c [ROW_A*COL_B-1:0];

    // Compute the product of the flattened matrices
    always_comb begin
        for (int i = 0; i < ROW_A*COL_B; i++) begin
            flattened_matrix_c[i] = 0;
            for (int j = 0; j < ROW_B; j++) begin
                flattened_matrix_c[i] += flattened_matrix_a[(i/COL_B)*COL_A + (i%COL_B)] * flattened_matrix_b[j*COL_B + j];
            end
        end
    end

    // Assign the product matrix back to the output
    assign matrix_c = reinterpret_cast<logic [OUTPUT_DATA_WIDTH-1:0] [ROW_A-1:0][COL_B-1:0]>(flattened_matrix_c);

endmodule
