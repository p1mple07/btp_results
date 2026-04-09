module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 64
) (
    input logic [ROWS_A - 1:0] matrix_a,
    input logic [COL_A - 1:0] matrix_b,
    output logic [ROWS_A * COL_B * OUTPUT_DATA_WIDTH - 1 : 0] matrix_c
);

always @(*) begin
    matrix_c = 0;
    for (int i = 0; i < ROW_A; i++) begin
        for (int j = 0; j < COL_B; j++) begin
            matrix_c[i * COL_B + j] = 0;
            for (int k = 0; k < COL_A; k++) begin
                matrix_c[i * COL_B + j] += matrix_a[i * COL_A + k] * matrix_b[k * COL_B + j];
            end
        end
    end
end

endmodule
