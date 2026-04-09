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
  genvar lv1;
  genvar lv2;
  genvar lv3;
  parameter MODIFIED_COL_A = $nextpower2(COL_A);
  parameter HALF_MODIFIED_COL_A = $clog2(MODIFIED_COL_A);
  
  generate
    logic [                                  COL_A:0] valid_out_reg; // Pipeline valid signal shift register
    logic [(ROW_A*COL_B*MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage   ; // Intermediate multiplication results
    logic [(ROW_A*COL_B*MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] add_stage    ; // Accumulated addition results

    always_ff @(posedge clk)
      if (srst)
        {valid_out, valid_out_reg} <= '0;
      else
        {valid_out, valid_out_reg} <= {valid_out_reg, valid_in}; 

    for (gv1 = 0 ; gv1 < ROW_A ; gv1++) begin: row_a_gb
      for (gv2 = 0 ; gv2 < COL_B ; gv2++) begin: col_b_gb
        for (gv3 = 0 ; gv3 < COL_A ; gv3++) begin: col_a_gb
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
              add_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((gv1*COL_B)+gv2)*COL_A)+gv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end

        always_ff @(posedge clk)
          if (srst)
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= '0; // Reset output matrix element
          else if (valid_out_reg[COL_A])
            matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((((gv1*COL_B)+gv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH]; // Set output to the accumulated result
      end
    end

    // Binary reduction tree implementation
    integer lv1, lv2, lv3;
    always_ff @(posedge clk) begin
      if (srst) begin
        lv1 <= 0;
        lv2 <= 0;
        lv3 <= 0;
      end else begin
        lv1 <= gv1;
        lv2 <= gv2;
        lv3 <= gv3;
      end
    end

    always_ff @(posedge clk)
      if (srst)
        valid_out_reg <= '0;
      else
        valid_out_reg <= valid_in;
      end

    // Reduction tree accumulation
    always_ff @(posedge clk) begin
      if (srst || valid_out_reg) begin
        mult_stage[0:0] <= '0;
        add_stage[0:0] <= '0;
      end else begin
        lv1 <= gv1;
        lv2 <= gv2;
        lv3 <= gv3;
        if (lv3 < MODIFIED_COL_A) begin
          mult_stage[((((lv1*COL_B)+lv2)*COL_A)+lv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= matrix_a[((lv1*COL_A)+lv3)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH] * matrix_b[((lv3*COL_B)+lv2)*INPUT_DATA_WIDTH+:INPUT_DATA_WIDTH];
        end
        if (lv3 < HALF_MODIFIED_COL_A) begin
          add_stage[((((lv1*COL_B)+lv2)*COL_A)+lv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((lv1*COL_B)+lv2)*COL_A)+lv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end else begin
          add_stage[((((lv1*COL_B)+lv2)*COL_A)+lv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= mult_stage[((((lv1*COL_B)+lv2)*COL_A)+lv3)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] + add_stage[((((lv1*COL_B)+lv2)*COL_A)+(lv3-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end
      end
    end

    // Final accumulation
    always_ff @(posedgeclk) begin
      if (srst || valid_out_reg) begin
        add_stage[0:0] <= '0;
        matrix_c[0:0] <= '0;
      end else if (lv3 == 0) begin
        matrix_c[((lv1*COL_B)+lv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] <= add_stage[((((lv1*COL_B)+lv2)*COL_A)+(COL_A-1))*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
      end
    end
  endgenerate

endmodule