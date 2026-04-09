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
  genvar MODIFIED_COL_A;
  genvar HALF_MODIFIED_COL_A;

  generate
    logic [                                  COL_A:0] valid_out_reg; // Pipeline valid signal shift register
    logic [(ROW_A*COL_B*MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage   ; // Intermediate multiplication results
    logic [(ROW_A*COL_B*HALF_MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] add_stage    ; // Accumulated addition results

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in}; 

    for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: row_a_gb
      for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: col_b_gb
        for (gv3 = 0 ; gv3 < MODIFIED_COL_A ; gv3++) begin: col_a_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
            else
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]; 

          
          always_ff @(posedge clk)
            if (srst)
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
            else if (gv3 == 0)
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
            else if (gv3 < HALF_MODIFIED_COL_A)
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + add_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
            else
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + add_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end

        
        always_ff @(posedge clk)
          if (srst)
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; // Reset output matrix element
          else if (valid_out_reg[COL_A])
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]; // Set output to the accumulated result
      end
    end

  endgenerate

endmodule