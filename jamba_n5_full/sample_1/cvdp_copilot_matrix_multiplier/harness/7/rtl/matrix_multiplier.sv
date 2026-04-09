module matrix_multiplier #(
    parameter ROW_A             = 4,
    parameter COL_A             = 4,
    parameter ROW_B             = 4,
    parameter COL_B             = 4,
    parameter INPUT_DATA_WIDTH  = 8,
    parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
    input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
    input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
    output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

    localparam NUM_CYCLES = COL_A + 2;
    reg [NUM_CYCLES-1:0] cycle_num;
    reg [NUM_CYCLES-1:0] prod;
    reg [NUM_CYCLES-1:0] acc;
    logic valid_out;

    always_ff @(posedge clk) begin
        if (~srst) begin
            cycle_num <= 0;
            valid_out <= 0;
            matrix_c <= 0;
        end else begin
            if (cycle_num < NUM_CYCLES) begin
                prod = matrix_a[((row_a*col_a*input_data_width)-1):0] * matrix_b[((row_b*col_b*input_data_width)-1):0];
            end
            if (cycle_num < NUM_CYCLES-1) begin
                acc = acc + prod;
            end
            cycle_num <= cycle_num + 1;
        end
    end

    always_comb begin
        if (cycle_num == NUM_CYCLES) begin
            valid_out = 1;
            matrix_c <= acc;
        end else
            matrix_c <= 0;
    end

endmodule
