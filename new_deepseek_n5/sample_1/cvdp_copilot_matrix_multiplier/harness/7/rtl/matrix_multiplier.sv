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
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c,
  input  clock,
  input  srst,
  input  valid_in,
  output valid_out
);
  genvar gv1;
  genvar gv2;
  genvar gv3;
  genvar cnt;
  genvar valid_shift;
  
  // Multiplication stage
  logic [(COL_A*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_c_mult;
  generate
    for (gv1 = 0; gv1 < COL_A; gv1++) begin: row_mult_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_mult_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_mult_gb
          if (gv3 == 0)
            assign matrix_c_mult[((gv1*COL_B)+gv2)*COL_A + gv3] = matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH:INPUT_DATA_WIDTH];
          else
            assign matrix_c_mult[((gv1*COL_B)+gv2)*COL_A + gv3] = matrix_c_mult[((gv1*COL_B)+gv2)*COL_A + gv3-1] + matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH:INPUT_DATA_WIDTH];
        end
      end
    end
  endgenerate
  
  // Accumulation stage
  logic [(COL_A*COL_B*COL_A)-1:0] matrix_c_acc;
  generate
    for (cnt = 0; cnt < COL_A; cnt++) begin: acc_cycle
      for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_acc_gb
        for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_acc_gb
          assign matrix_c_acc[((gv1*COL_B)+gv2)*COL_A + cnt] = matrix_c_mult[((gv1*COL_B)+gv2)*COL_A + cnt] + matrix_c_acc[((gv1*COL_B)+gv2)*COL_A + cnt];
        end
      end
    end
  endgenerate
  
  // Output stage
  logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c_out;
  logic valid_shift_reg;
  
  // Valid signal handling
  genvar valid_shift;
  assign valid_shift_reg = 0;
  genvar valid_shift_count;
  genvar valid_shift_Enable;
  
  always begin
    if (valid_in) begin
      valid_shift_Enable = 1;
      valid_shift = valid_shift_reg;
    end else begin
      valid_shift_Enable = 0;
      valid_shift = 0;
    end
  end
  
  generate
    for (cnt = 0; cnt < COL_A + 2; cnt++) begin: valid_out_cycle
      if (valid_shift_Enable) begin
        assign valid_out = valid_shift_reg;
        assign valid_shift_reg = 0;
      end
    end
  endgenerate
  
  assign matrix_c = matrix_c_out;
  assign valid_out;
endmodule