module matrix_multiplier_seq #(
    parameter ROW_A = 4,
    parameter COL_A = 4,
    parameter ROW_B = 4,
    parameter COL_B = 4,
    parameter INPUT_DATA_WIDTH = 8,
    parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
    input wire clk,
    input wire srst,
    input wire valid_in,
    input matrix_a[?][?],
    input matrix_b[?][?],
    output matrix_c[?][?],
    output valid_out
);

localparam num_cycles = COL_A + 2;
reg [num_cycles - 1:0] cycle_counter;
reg [ROWS_A*COLS_B*INOUT_DATA_WIDTH - 1:0] matrix_c_stage;

initial begin
    cycle_counter = 0;
end

always @(posedge clk or posedge srst) begin
    if (srst) begin
        cycle_counter <= 0;
        matrix_c_stage <= 0;
        valid_out <= 0;
        valid_in <= 1;
    end else begin
        cycle_counter <= cycle_counter + 1;
        if (cycle_counter < num_cycles) begin
            // Multiplication stage
            for (genvar i = 0; i < ROW_A*COL_A*INPUT_DATA_WIDTH; i++) begin
                matrix_c_stage[i*OUTPUT_DATA_WIDTH + (i%OUTPUT_DATA_WIDTH)] = matrix_a[i/INPUT_DATA_WIDTH][i%INPUT_DATA_WIDTH] * matrix_b[i/INPUT_DATA_WIDTH][i%INPUT_DATA_WIDTH];
            end

            // Accumulation stage
            for (genvar j = 0; j < COL_A; j++) begin
                for (genvar k = 0; k < COL_A; k++) begin
                    // accumulate over COL_A cycles
                    matrix_c_stage[(j*COL_A + k)*OUTPUT_DATA_WIDTH + (j%COL_A)*OUTPUT_DATA_WIDTH] += matrix_c_stage[((j*COL_A + k)*OUTPUT_DATA_WIDTH + (j%COL_A)*OUTPUT_DATA_WIDTH) - 1];
                end
            end

            // Output stage
            for (genvar l = 0; l < ROW_A*COL_B*OUTPUT_DATA_WIDTH; l++) begin
                matrix_c[l] = matrix_c_stage[l];
            end
        end else begin
            matrix_c_stage <= 0;
            valid_out <= 0;
        end
    end
end

assign valid_out = (cycle_counter >= num_cycles) ? 1 : 0;

endmodule
