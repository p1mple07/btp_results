module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
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

always_ff @(posedge clk) begin
  if (srst)
    begin
      valid_out <= '0;
      mult_stage <= '0;
      add_stage <= '0;
    end
  else
    begin
      // First, perform multiplication stage (already done earlier)
      // We assume mult_stage is already populated.

      // Now, accumulate using binary reduction tree.
      if (COL_A == 1)
        begin
          // Special case: COL_A = 1, no reduction needed.
          matrix_c[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH] = mult_stage[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH];
        end
        else
        begin
          // Binary reduction tree.
          let n = $clog2(COL_A);
          for (gv1 = 0; gv1 < n; gv1 += 2) begin
            for (gv2 = 0; gv2 < COL_A; gv2 += 2) begin
              let idx = ((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH + : (gv2+1)*OUTPUT_DATA_WIDTH;
              add_stage[idx] = mult_stage[((gv1*COL_B)+gv2)*OUTPUT_DATA_WIDTH+:OUT_PUT_DATA_WIDTH] + mult_stage[((gv1*COL_B)+(gv2+1))*OUTPUT_DATA_WIDTH+:OUT_PUT_DATA_WIDTH];
            end
          end
        end

      // Output stage: assert valid_out when valid_out_reg[COL_A] is true, which is after n cycles.
      // The valid_out_reg is updated from the accumulation.

      // Additional output logic.
    end
end

always_ff @(posedge clk)
  if (srst)
    begin
      valid_out <= '0;
      valid_out_reg <= '0;
      mult_stage <= '0;
      add_stage <= '0;
    end
  else
    begin
      // Update valid_out_reg based on valid_out.
      valid_out_reg[COL_A] = valid_out;
    end
end

endmodule
