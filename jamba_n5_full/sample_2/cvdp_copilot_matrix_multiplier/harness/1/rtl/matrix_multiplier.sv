module matrix_multiplier #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = 32
) (
    input wire [ROW_A*COL_A-1:0] matrix_a,
    input wire [ROW_B*COL_B-1:0] matrix_b,
    output reg [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

always @(*) begin
    matrix_c = 0;
    for (integer i = 0; i < ROW_A; i++) begin
        for (integer j = 0; j < COL_B; j++) begin
            for (integer k = 0; k < COL_A; k++) begin
                for (integer l = 0; l < ROW_B; l++) begin
                    wire val = matrix_a[i*COL_A + k];
                    val = val * matrix_b[k*ROW_B + l];
                    matrix_c[i*COL_B*OUTPUT_DATA_WIDTH + j*OUTPUT_DATA_WIDTH + k*OUTPUT_DATA_WIDTH + l] = val;
                end
            end
        end
    end
end

endmodule
