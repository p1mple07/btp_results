module matrix_multiplier #(
  parameter ROW_A             = 4                                                   , // Number of rows in matrix A
  parameter COL_A             = 4                                                   , // Number of columns in matrix A
  parameter ROW_B             = 4                                                   , // Number of rows in matrix B
  parameter COL_B             = 4                                                   , // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8                                                   , // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)                // Bit-width of output data
) (
  input  logic                                       clk      , // Clock input
  input  logic                                       srst     , // Active-high Synchronous reset
  input  logic                                       valid_in , // Indicates valid input matrices
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a , // Input matrix A in 1D form
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b , // Input matrix B in 1D form
  output logic                                       valid_out, // Indicates valid output matrix
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c   // Output matrix C in 1D form
);
  genvar gv1;
  genvar gv2;
  genvar gv3;
  genvar gv4;
  genvar gv5;

  parameter MODIFIED_COL_A = $nextpower2(COL_A);
  parameter HALF_MODIFIED_COL_A = $clog2(MODIFIED_COL_A);
  
  generate
    logic [ (MODIFIED_COL_A * COL_B * COL_A * OUTPUT_DATA_WIDTH)-1:0 ] mult_stage;
    logic [ (MODIFIED_COL_A * COL_B * HALF_MODIFIED_COL_A * OUTPUT_DATA_WIDTH)-1:0 ] add_stage;

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
        matrix_c <= 0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

    for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[(((gv1*COL_B)+gv2)*COL_A + gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0;
            else
              mult_stage[(((gv1*COL_B)+gv2)*COL_A + gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];

          always_ff @(posedge clk)
            if (srst || gv3 == 0)
              add_stage[(((gv1*COL_B)+gv2)*COL_A + gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0;
            else
              add_stage[(((gv1*COL_B)+gv2)*COL_A + gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[(((gv1*COL_B)+gv2)*COL_A + gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] 
                + add_stage[(((gv1*COL_B)+gv2)*COL_A + (gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end
      end
    end

    always_ff @(posedge clk)
      if (srst)
        matrix_c <= 0;
      else if (valid_out_reg[HALF_MODIFIED_COL_A - 1])
        for (gv4 = 0; gv4 < HALF_MODIFIED_COL_A; gv4++) begin: col_a_gb
          for (gv5 = 0; gv5 < MODIFIED_COL_A; gv5++) begin: col_b_gb
            matrix_c[((gv4*COL_B)+gv5)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((gv4*COL_B)+gv5)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
          end
        end
      else
        matrix_c <= 0;
    end
  endgenerate

endmodule