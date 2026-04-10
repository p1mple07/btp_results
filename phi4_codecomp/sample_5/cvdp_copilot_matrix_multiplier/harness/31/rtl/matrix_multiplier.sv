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

  localparam MODIFIED_COL_A      = 1<<($clog2(COL_A));
  localparam HALF_MODIFIED_COL_A = MODIFIED_COL_A/2  ;

  generate
    logic [                                        $clog2(COL_A):0] valid_out_reg;
    logic [     (ROW_A*COL_B*MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage   ;

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in}; 

    for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: mult_row_a_gb
      for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: mult_col_b_gb
        for (gv3 = 0 ; gv3 < MODIFIED_COL_A ; gv3++) begin: mult_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[((((gv1*COL_B)+gv2)*MODIFIED_COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
            else if (gv3 < COL_A)
              mult_stage[((((gv1*COL_B)+gv2)*MODIFIED_COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]; 
        end
      end
    end

    if (HALF_MODIFIED_COL_A > 0) begin
      logic [($clog2(COL_A)*ROW_A*COL_B*HALF_MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] add_stage    ; 
      for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: accum_row_a_gb
        for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: accum_col_b_gb
          for (gv3 = 0 ; gv3 < HALF_MODIFIED_COL_A ; gv3++) begin: accum_gb
            for (gv4 = 0 ; gv4 < $clog2(COL_A) ; gv4++) begin: pipe_gb
              if (gv4 == 0) begin
                always_ff @(posedge clk)
                  if (srst)
                    add_stage[((0*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+gv3))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
                  else if (valid_out_reg[0])
                    add_stage[((0*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+gv3))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*MODIFIED_COL_A)+(2*gv3))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + mult_stage[((((gv1*COL_B)+gv2)*MODIFIED_COL_A)+((2*gv3)+1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
              end
              else begin
                always_ff @(posedge clk)
                  if (srst)
                    add_stage[((gv4*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+gv3))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
                  else if ((HALF_MODIFIED_COL_A > 1) && (gv3 < (HALF_MODIFIED_COL_A/2)))
                    add_stage[((gv4*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+gv3))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[(((gv4-1)*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+(2*gv3)))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + add_stage[(((gv4-1)*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+((2*gv3)+1)))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
              end
            end
          end
          for (gv3 = 0 ; gv3 < MODIFIED_COL_A ; gv3++) begin: out_add_gb
            always_ff @(posedge clk)
              if (srst)
                matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0;
              else if (valid_out_reg[$clog2(COL_A)])
                matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((($clog2(COL_A)-1)*ROW_A*COL_B*HALF_MODIFIED_COL_A)+((((gv1*COL_B)+gv2)*HALF_MODIFIED_COL_A)+0))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]; 
          end
        end
      end
    end
    else begin
      for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: out_row_a_gb
        for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: out_col_b_gb
          for (gv3 = 0 ; gv3 < MODIFIED_COL_A ; gv3++) begin: out_mult_gb
            always_ff @(posedge clk)
              if (srst)
                matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0;
              else if (valid_out_reg[$clog2(COL_A)])
                matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*MODIFIED_COL_A)+0)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]; 
          end
        end
      end
    end

  endgenerate

endmodule