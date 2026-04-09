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
  output valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c_stage
);
  genvar gv1;
  genvar gv2;
  genvar gv3;
  genvar shift_reg;

  generate
    logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] matrix_c_stage;

    for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
          if (gv3 == 0)
            assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];
          else
            assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + (matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]);
        end
        // Accumulate result
        if (gv3 == COL_A - 1)
          assign matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + matrix_c_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end
      end
      // Valid signal propagation
      if (valid_in) begin
        if (gv1 == COL_A - 1) begin
          if (gv2 == COL_B - 1) begin
            if (gv3 == COL_A - 1) begin
              // Final accumulation
              assign matrix_c[(gv1*COL_B + gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = matrix_c_stage[((gv1*COL_B + gv2)*COL_A + (COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
              // Valid signal after COL_A + 2 cycles
              assign valid_out = 1;
              // Reset all registers
              assign matrix_c_stage = 0;
            end
          end
        end
      end
    end
  endgenerate

  // Valid signal shift register
  always @posedge clock or (valid_in & !valid_out) begin
    if (valid_in) begin
      if (shift_reg < (COL_A + 2)) begin
        assign valid_out = 1;
        assign shift_reg = shift_reg + 1;
      end else begin
        assign valid_out = 0;
        assign shift_reg = 0;
      end
    end else begin
      assign valid_out = 0;
      assign shift_reg = 0;
    end
  end
endmodule