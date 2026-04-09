module matrix_multiplier #(
    parameter ROW_A             = 4,
    parameter COL_A             = 4,
    parameter ROW_B             = 4,
    parameter COL_B             = 4,
    parameter INPUT_DATA_WIDTH  = 8,
    parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
    input  logic               clk,
    input  logic               srst,
    input  logic               valid_in,
    input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
    input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
    output logic               valid_out,
    output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

localparam MODIFIED_COL_A = 1 << (CEIL(LOG2(COL_A)));
localparam HALF_MODIFIED_COL_A = MODIFIED_COL_A / 2;

// ... rest of the code ...

always_ff @(posedge clk) begin
    if (srst)
        {valid_out, valid_out_reg} <= '0;
        mult_stage <= '0;
        add_stage <= '0;
    else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

        // Binary reduction tree accumulation
        if (COL_A == 1) begin
            for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
                for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
                    for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
                        mult_stage[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];
                    end
                end
            end
        end
        else
            // Use reduction tree
            // ... similar to original but with reduction logic ...
        end

    // Update output when ready
    if (valid_out_reg[COL_A])
        matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
end

endmodule
