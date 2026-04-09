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
  input  logic valid_in,
  output logic [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c,
  input  logic [ COL_A*COL_B*INPUT_DATA_WIDTH-1:0 ] valid_in_reg,
  output logic [ COL_A*COL_B*OUTPUT_DATA_WIDTH-1:0 ] valid_out,
  output logic [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0 ] output_reg
);
  genvar gv1, gv2, gv3;
  genvar m1, m2, m3;
  genvar shift_reg, shift_reg_valid;

  generate
    // Multiplication stage
    logic [(COL_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c_stage;
    for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
          if (gv3 == 0)
            assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];
          else
            assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + (matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]);
        end
        assign output_reg[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
      end
    end

    // Accumulation stage
    for (m1 = 0; m1 < COL_A; m1++) begin: acc_stage
      assign shift_reg = shift_reg << 1;
      assign shift_reg_valid = 1;
    end

    // Output stage
    for (m2 = 0; m2 < COL_A; m2++) begin: out_stage
      assign shift_reg = shift_reg >> 1;
      assign shift_reg_valid = 0;
    end

    // Final output
    assign matrix_c = output_reg;
    assign valid_out = shift_reg_valid;
  endgenerate

  // Reset stage
  always begin
    if (srst) begin
      assign matrix_c_stage = 0;
      assign output_reg = 0;
      assign shift_reg = 0;
      assign shift_reg_valid = 0;
    end
  end
endmodule