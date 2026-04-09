module matrix_multiplier_seq #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
    input  logic clk,
    input  logic srst,
    input  logic valid_in,
    input  logic matrix_a[ROW_A-1:0][COL_A-1:0],
    input  logic matrix_b[ROW_B-1:0][COL_B-1:0],
    output logic valid_out,
    output logic [ROW_A*COL_B*OUTPUT_DATA_WIDTH-1:0] matrix_c
);

    reg [COL_A*OUTPUT_DATA_WIDTH-1:0] matrix_c_temp;
    reg valid_out_reg;
    reg [COL_A-1:0] matrix_a_reg;
    reg [COL_A-1:0] matrix_b_reg;
    reg [COL_A*OUTPUT_DATA_WIDTH-1:0] matrix_c_reg;

    // Reset on synchronous reset
    always_ff @(posedge clk or posedge srst) begin
        if (srst) begin
            matrix_a_reg <= 0;
            matrix_b_reg <= 0;
            matrix_c_reg <= 0;
            valid_out_reg <= 0;
        end else begin
            matrix_a_reg <= matrix_a;
            matrix_b_reg <= matrix_b;
            matrix_c_reg <= matrix_c;
            valid_out_reg <= 0;
        end
    end

    // Stage 1: Multiplication
    always_comb begin
        matrix_c_temp = { [0:(ROW_A*COL_B*OUTPUT_DATA_WIDTH)] 0 };
        for (genvar i = 0; i < ROW_A*COL_B*OUTPUT_DATA_WIDTH; i++) begin
            matrix_c_temp[i] = matrix_a[i] * matrix_b[i];
        end
    end

    // Stage 2: Accumulation
    always_ff @(posedge clk) begin
        if (valid_out_reg) begin
            for (genvar j = 0; j < COL_A; j++) begin
                matrix_c_reg[j*OUTPUT_DATA_WIDTH + (j/2)*OUTPUT_DATA_WIDTH] = matrix_c_temp[j*OUTPUT_DATA_WIDTH];
            end
        end
    end

    // Stage 3: Output
    always_ff @(posedge clk) begin
        if (valid_out_reg && !srst) begin
            matrix_c <= matrix_c_reg;
            valid_out <= 1;
        end else if (valid_out_reg) begin
            matrix_c <= 0;
            valid_out <= 0;
        end
    end

    assign valid_out = valid_out_reg;

endmodule
