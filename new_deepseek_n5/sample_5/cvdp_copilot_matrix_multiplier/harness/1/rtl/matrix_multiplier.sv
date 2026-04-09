module matrix_multiplier(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = INPUT_DATA_WIDTH * 2
);

    // Input matrices
    input [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1 : 0 ] matrix_a;
    input [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1 : 0 ] matrix_b;

    // Output matrix
    output [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1 : 0 ] matrix_c;

    // Internal variables
    reg [OUTPUT_DATA_WIDTH-1:0] c_tmp;
    reg [COL_A-1:0]   a_row;
    reg [ROW_B-1:0]   b_col;
    reg [COL_A-1:0]   a_index;
    reg [ROW_B-1:0]   b_index;
    reg [COL_A-1:0]   a_k;
    reg [ROW_B-1:0]   b_k;

    // Matrix multiplication logic
    always_comb begin
        for (a_row = 0; a_row < ROW_A; a_row++) begin
            for (b_col = 0; b_col < COL_B; b_col++) begin
                c_tmp = 0;
                for (a_k = 0; a_k < COL_A; a_k++) begin
                    // Load matrix_a row a_row into a_row_reg
                    a_index = a_row * COL_A + a_k;
                    c_tmp = c_tmp + (matrix_a[a_index] << a_k) & ( (1 << OUTPUT_DATA_WIDTH) - 1 );
                    // Load matrix_b column b_col into b_k_reg
                    b_index = b_col * ROW_B + a_k;
                    c_tmp = c_tmp + (matrix_b[b_index] << b_k) & ( (1 << OUTPUT_DATA_WIDTH) - 1 );
                end
                // Store result in matrix_c
                matrix_c[ (a_row * COL_B) + b_col ] = c_tmp;
            end
        end
    end
endmodule