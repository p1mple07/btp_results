module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 64
)(
    output logic [ROW_A][COL_B][OUTPUT_DATA_WIDTH] matrix_c
);

    reg [WIDTH_C - 1:0] matrix_a [0: (ROW_A-1)*COL_A];
    reg [WIDTH_C - 1:0] matrix_b [0: (ROW_B-1)*COL_B];
    wire [ROW_A][COL_B][OUTPUT_DATA_WIDTH] temp_matrix_c;

    always @(*) begin
        for (int i = 0; i < ROW_A; i++) begin
            for (int j = 0; j < COL_B; j++) begin
                for (int k = 0; k < COL_A; k++) begin
                    for (int l = 0; l < ROW_B; l++) begin
                        temp_matrix_c[i][j][k * ROW_B + l] = matrix_a[i * COL_A + k] * matrix_b[l * COL_B + j];
                    end
                end
            end
        end
    end

    assign matrix_c = temp_matrix_c;

endmodule
