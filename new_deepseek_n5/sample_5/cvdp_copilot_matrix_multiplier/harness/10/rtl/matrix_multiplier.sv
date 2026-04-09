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
  genvar level;
  genvar current_level;

  parameter MODIFIED_COL_A = $next_power_of_two(COL_A);
  parameter HALF_MODIFIED_COL_A = $next_power_of_two(COL_A) / 2;

  generate
    logic [ (MODIFIED_COL_A * HALF_MODIFIED_COL_A * COL_A * OUTPUT_DATA_WIDTH)-1:0 ] mult_stage;
    logic [ (MODIFIED_COL_A * HALF_MODIFIED_COL_A * COL_A * OUTPUT_DATA_WIDTH)-1:0 ] add_stage;
    logic [ (MODIFIED_COL_A * HALF_MODIFIED_COL_A * COL_A * OUTPUT_DATA_WIDTH)-1:0 ] next_add_stage;

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in}; 

    for (gv1 = 0; gv1 < ROW_A; gv1++) begin: row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin: col_b_gb
        for (gv3 = 0; gv3 < COL_A; gv3++) begin: col_a_gb
          always_ff @(posedge clk)
            if (srst)
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
            else
              mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH]; 

          always_ff @(posedge clk)
            if (srst || current_level >= $clog2(COL_A))
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; 
            else if (gv3 == 0)
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
              current_level <= 0;
            else
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + add_stage[((((gv1*COL_B)+gv2)*COL_A)+(gv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
              current_level <= current_level + 1;
        end

        always_ff @(posedge clk)
          if (srst)
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; // Reset output matrix element
          else if (valid_out_reg[COL_A])
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]; // Set output to the accumulated result
      end
    end

    // Binary reduction tree logic
    always_ff @(posedge clk)
      if (srst) begin
        valid_out_reg <= '0;
        next_add_stage <= '0;
      end else begin
        if (current_level < $clog2(COL_A)) begin
          valid_out_reg <= valid_out_reg;
          next_add_stage <= add_stage;
          current_level <= current_level + 1;
        else
          valid_out_reg <= valid_out_reg;
          next_add_stage <= '0;
        end
      end
  endgenerate

endmodule