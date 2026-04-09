module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 16
) (
    input [ROW_A x COL_A x INPUT_DATA_WIDTH] -1 : 0 matrix_a,
    input [ROW_B x COL_B x INPUT_DATA_WIDTH] -1 : 0 matrix_b,
    output [(ROW_A x COL_B x OUTPUT_DATA_WIDTH) -1 : 0] matrix_c
);

    reg [INPUT_DATA_WIDTH:0] temp_c;
    reg [OUTPUT_DATA_WIDTH:0] acc;

    initial begin
        for (int i = 0; i < ROW_A; i++) begin
            for (int j = 0; j < COL_B; j++) begin
                temp_c = 0;
                for (int k = 0; k < INPUT_DATA_WIDTH; k++) begin
                    temp_c += matrix_a[i][k][];
                    temp_c += matrix_b[k][j];
                end
                matrix_c[i][j] = temp_c;
            end
        end
    end

endmodule
