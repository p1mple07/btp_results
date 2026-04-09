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

  // Local parameters for binary reduction tree
  localparam MODIFIED_COL_A = $clog2(COL_A) + 1; // Nearest power of 2 >= COL_A
  localparam HALF_MODIFIED_COL_A = (MODIFIED_COL_A - 1) / 2;

  // Pipelined valid signal shift register
  logic [COL_A:0] valid_out_reg;

  // Intermediate multiplication results
  logic [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage;

  // Accumulated addition results using a binary reduction tree
  logic [HALF_MODIFIED_COL_A*MODIFIED_COL_A-1:0] add_stage;

  always_ff @(posedge clk) begin
    if (srst) begin
      valid_out <= '0;
      valid_out_reg <= '0;
      mult_stage <= '0;
      add_stage <= '0;
    end else begin
      valid_out <= valid_out_reg;
      mult_stage <= mult_stage;
      add_stage <= add_stage;
    end
  end

  // Multiplication stage (unchanged)
  generate
    genvar gv1, gv2;
    for (gv1 = 0; gv1 < ROW_A; gv1++) begin : row_a_gb
      for (gv2 = 0; gv2 < COL_B; gv2++) begin : col_b_gb
      // Multiplication logic remains unchanged
      end
    end
  endgenerate

  // Accumulation stage with binary reduction tree
  generate
    genvar gv3;
    for (gv3 = 0; gv3 < HALF_MODIFIED_COL_A; gv3 = gv3 / 2) begin : accum_gb
      always_ff @(posedge clk) begin
        if (srst) begin
          add_stage[(((gv1*COL_B)+gv2)*COL_A)+gv3*MODIFIED_COL_A-1:0] <= '0;
        end else begin
          // Parallel addition of pairs
          add_stage[(((gv1*COL_B)+gv2)*COL_A)+gv3*MODIFIED_COL_A-1:0] <=
          add_stage[(((gv1*COL_B)+gv2)*COL_A)+(gv3*MODIFIED_COL_A-1):MODIFIED_COL_A-1] +
          add_stage[(((gv1*COL_B)+gv2)*COL_A)+(gv3*MODIFIED_COL_A):MODIFIED_COL_A-1];
        end
      end
    end
    // Final addition to produce the accumulated result
    always_ff @(posedge clk) begin
      if (srst) begin
        add_stage[((gv1*COL_B)+COL_A-1)*MODIFIED_COL_A-1:0] <= '0;
      end else if (gv3 == HALF_MODIFIED_COL_A-1) begin
        add_stage[((gv1*COL_B)+COL_A-1)*MODIFIED_COL_A-1:0] <= mult_stage[((gv1*COL_B)+COL_A-1)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
      end else begin
        add_stage[((gv1*COL_B)+COL_A-1)*MODIFIED_COL_A-1:0] <= add_stage[((gv1*COL_B)+COL_A-2)*MODIFIED_COL_A-1:OUTPUT_DATA_WIDTH];
      end
    end
  endgenerate

  // Output stage adjusted for new latency
  always_ff @(posedge clk) begin
    if (srst) begin
      matrix_c <= '0;
    end else if (valid_out_reg[COL_A]) begin
      // Set output to the accumulated result
      matrix_c <= add_stage[COL_A-1*MODIFIED_COL_A-1:0];
    end
  end

endmodule
