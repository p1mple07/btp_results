module matrix_multiplier (
    input logic [MAX_ROWS-1:0] matrix_a,
    input logic [MAX_COLS_A-1:0] matrix_b,
    output logic [MAX_ROWS_C-1:0][MAX_OUT_DEPTH-1:0] matrix_c
);

    localparam int DEFAULT_ROW_A = 4;
    localparam int DEFAULT_COL_A = 4;
    localparam int DEFAULT_ROW_B = 4;
    localparam int DEFAULT_COL_B = 4;
    localparam int DEFAULT_INPUT_DATA_WIDTH = 8;
    localparam int DEFAULT_OUTPUT_DATA_WIDTH = 8;

    wire [MAX_ROWS_C-1:0] rows_a = matrix_a.length();
    wire [MAX_COLS_A-1:0] cols_a = matrix_a.size();
    wire [MAX_ROWS_C-1:0] rows_b = matrix_b.length();
    wire [MAX_COLS_B-1:0] cols_b = matrix_b.size();
    wire [DEFAULT_OUTPUT_DATA_WIDTH-1:0] out_depth = 1;

    if (cols_a != rows_b)
        $error("Matrix A columns must match Matrix B rows.");

    assign out_depth = cols_a;

    logic [rows_a * cols_b * out_depth - 1: 0] temp_result;

    initial begin
        for (int i = 0; i < rows_a; i++) begin
            for (int j = 0; j < cols_b; j++) begin
                for (int k = 0; k < out_depth; k++) begin
                    temp_result[i * cols_b * out_depth + j * out_depth + k] = matrix_a[i * cols_a + k] * matrix_b[j * rows_b + k];
                end
            end
        end
    end

    logic [MAX_ROWS_C-1:0][MAX_OUT_DEPTH-1:0] matrix_c;
    for (int i = 0; i < rows_a; i++) begin
        for (int j = 0; j < cols_b; j++) begin
            for (int k = 0; k < out_depth; k++) begin
                matrix_c[i * cols_b * out_depth + j * out_depth + k] = temp_result[i * cols_b * out_depth + j * out_depth + k];
            end
        end
    end

    assign matrix_c = matrix_c;

endmodule
