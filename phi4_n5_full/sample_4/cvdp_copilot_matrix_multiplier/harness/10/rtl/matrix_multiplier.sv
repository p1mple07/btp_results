module matrix_multiplier #(
  parameter ROW_A             = 4,                                   // Number of rows in matrix A
  parameter COL_A             = 4,                                   // Number of columns in matrix A
  parameter ROW_B             = 4,                                   // Number of rows in matrix B
  parameter COL_B             = 4,                                   // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8,                                   // Bit-width of input data
  // OUTPUT_DATA_WIDTH is calculated as (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
  // to handle potential overflow during accumulation.
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                                       clk,      // Clock input
  input  logic                                       srst,     // Active-high Synchronous reset
  input  logic                                       valid_in, // Indicates valid input matrices
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a, // Input matrix A (flattened)
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b, // Input matrix B (flattened)
  output logic                                       valid_out, // Indicates valid output matrix
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c  // Output matrix C (flattened)
);

  //-------------------------------------------------------------------------
  // Local parameters for the reduction tree
  //-------------------------------------------------------------------------
  // MODIFIED_COL_A is the smallest power-of-two >= COL_A.
  localparam MODIFIED_COL_A = (COL_A < 1) ? 1 : (1 << $clog2(COL_A));
  // HALF_MODIFIED_COL_A is half of MODIFIED_COL_A (used for clarity; not used directly below)
  localparam HALF_MODIFIED_COL_A = MODIFIED_COL_A >> 1;
  // NUM_RED_STAGES is the number of stages in the binary reduction tree.
  // For COL_A > 1, this equals $clog2(MODIFIED_COL_A) (which is equal to $clog2(COL_A)).
  localparam NUM_RED_STAGES = $clog2(MODIFIED_COL_A);

  //-------------------------------------------------------------------------
  // Global registers
  //-------------------------------------------------------------------------
  // valid_out_reg is a shift register that delays valid_in by (NUM_RED_STAGES + 2) cycles.
  // Its width is set so that after NUM_RED_STAGES+2 cycles, the MSB reflects valid_in.
  logic [NUM_RED_STAGES+1:0] valid_out_reg;
  logic valid_out;

  // mult_stage holds the multiplication results.
  // Its size is based on MODIFIED_COL_A (which pads COL_A to a power of two).
  logic [(ROW_A*COL_B*MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] mult_stage;

  //-------------------------------------------------------------------------
  // Multiplication Stage
  //-------------------------------------------------------------------------
  // For each element of the output (indexed by row in A and col in B),
  // compute the product for each column of A. For indices beyond COL_A,
  // assign 0 so that the reduction tree works correctly.
  genvar gv1, gv2, gv3;
  generate
    for (gv1 = 0; gv1 < ROW_A; gv1++) begin : row_a_gb_mul
      for (gv2 = 0; gv2 < COL_B; gv2++) begin : col_b_gb_mul
        for (gv3 = 0; gv3 < COL_A; gv3++) begin : col_a_gb_mul
          always_ff @(posedge clk) begin
            if (srst)
              mult_stage[(((gv1*COL_B)+gv2)*MODIFIED_COL_A + gv3)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= '0;
            else begin
              if (gv3 < COL_A)
                mult_stage[(((gv1*COL_B)+gv2)*MODIFIED_COL_A + gv3)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= 
                  matrix_a[((gv1*COL_A)+gv3)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] *
                  matrix_b[((gv3*COL_B)+gv2)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH];
              else
                mult_stage[(((gv1*COL_B)+gv2)*MODIFIED_COL_A + gv3)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= '0;
            end
          end
        end
      end
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Valid Signal Propagation
  //-------------------------------------------------------------------------
  // Shift valid_in through valid_out_reg so that valid_out is asserted
  // exactly $clog2(COL_A) + 2 cycles after valid_in.
  always_ff @(posedge clk) begin
    if (srst) begin
      valid_out     <= 1'b0;
      valid_out_reg <= '0;
    end else begin
      valid_out_reg <= { valid_out_reg, valid_in };
      valid_out     <= valid_out_reg[NUM_RED_STAGES+1];
    end
  end

  //-------------------------------------------------------------------------
  // Accumulation and Output Stage
  //-------------------------------------------------------------------------
  // Use conditional generation to handle the COL_A = 1 edge case.
  generate
    if (COL_A == 1) begin : bypass_reduction_tree
      // When COL_A == 1, there is only one multiplication per output element.
      // Bypass the reduction tree and directly assign the result.
      for (gv1 = 0; gv1 < ROW_A; gv1++) begin : row_a_gb_out
        for (gv2 = 0; gv2 < COL_B; gv2++) begin : col_b_gb_out
          always_ff @(posedge clk) begin
            if (srst)
              matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= '0;
            else if (valid_out_reg[1]) // For COL_A==1, valid_out_reg is 2 bits wide.
              matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= 
                mult_stage[(((gv1*COL_B)+gv2)*MODIFIED_COL_A + 0)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
          end
        end
      end
    end
    else begin : use_reduction_tree
      // For COL_A > 1, use a binary reduction tree to accumulate the multiplication results.
      for (gv1 = 0; gv1 < ROW_A; gv1++) begin : row_a_gb_red
        for (gv2 = 0; gv2 < COL_B; gv2++) begin : col_b_gb_red
          // Declare an array to hold the reduction tree stages for this output element.
          // Each stage holds MODIFIED_COL_A partial sums.
          logic [(MODIFIED_COL_A*OUTPUT_DATA_WIDTH)-1:0] red_tree_stage [0:NUM_RED_STAGES-1];

          // Stage 0: Load multiplication results (with padding).
          integer i;
          always_ff @(posedge clk) begin
            if (srst)
              red_tree_stage[0] <= '0;
            else begin
              for (i = 0; i < MODIFIED_COL_A; i++) begin
                if (i < COL_A)
                  red_tree_stage[0][i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= 
                    mult_stage[(((gv1*COL_B)+gv2)*MODIFIED_COL_A + i)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
                else
                  red_tree_stage[0][i*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= '0;
              end
            end
          end

          // Stages 1 to NUM_RED_STAGES-1: Perform the binary reduction.
          integer k;
          generate
            for (k = 1; k < NUM_RED_STAGES; k=k+1) begin : stage_k
              always_ff @(posedge clk) begin
                if (srst)
                  red_tree_stage[k] <= '0;
                else begin
                  integer j;
                  for (j = 0; j < (MODIFIED_COL_A >> k); j++) begin
                    red_tree_stage[k][j*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= 
                      red_tree_stage[k-1][(2*j)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] +
                      red_tree_stage[k-1][(2*j+1)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
                  end
                end
              end
            end
          endgenerate

          // Output Stage: Transfer the final accumulated result to matrix_c.
          always_ff @(posedge clk) begin
            if (srst)
              matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= '0;
            else if (valid_out_reg[NUM_RED_STAGES+1])
              matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH] <= 
                red_tree_stage[NUM_RED_STAGES-1][0*OUTPUT_DATA_WIDTH +: OUTPUT_DATA_WIDTH];
          end
        end
      end
    end
  endgenerate

endmodule