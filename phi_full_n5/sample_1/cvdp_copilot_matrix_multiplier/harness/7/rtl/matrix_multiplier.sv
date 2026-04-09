module matrix_multiplier #(
  parameter ROW_A             = 4,                                                  
  parameter COL_A             = 4,                                                  
  parameter ROW_B             = 4,                                                  
  parameter COL_B             = 4,                                                  
  parameter INPUT_DATA_WIDTH  = 8,                                                  
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)               
) (
  input  logic clk,                                                 
  input  logic srst,                                                 
  input  logic valid_in,                                             
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,            
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,            
  output logic valid_out,                                            
  output logic [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c             
);

  logic [COL_A-1:0][ROW_B-1:0][OUTPUT_DATA_WIDTH-1:0] prod_reg,                 // Intermediate product register
      acc_reg [COL_A-1:0][ROW_B-1:0][OUTPUT_DATA_WIDTH-1:0];                // Accumulation register

  reg [COL_A-1:0][ROW_B-1:0][OUTPUT_DATA_WIDTH-1:0] prod_stage_reg,               // Intermediate product register for stage
      acc_stage_reg [COL_A-1:0][ROW_B-1:0][OUTPUT_DATA_WIDTH-1:0];        // Accumulation register for stage

  always_ff @(posedge clk) begin
    if (srst) begin
      prod_reg <= {{(COL_A-1):0}};
      acc_reg <= {{(COL_A-1):0}};
      prod_stage_reg <= {{(COL_A-1):0}};
      acc_stage_reg <= {{(COL_A-1):0}};
    end else if (valid_in) begin
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          prod_reg[i][j] <= matrix_a[(i*COL_A+j)*INPUT_DATA_WIDTH-1:0] * matrix_b[(j*COL_B+i)*INPUT_DATA_WIDTH-1:0];
          prod_stage_reg[i][j] <= prod_reg[i][j];
        end
      end

      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          acc_reg[i][j] <= acc_stage_reg[i][j] + prod_stage_reg[i][j];
        end
      end

      // Shift accumulation registers to match latency
      for (int i = 1; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          acc_stage_reg[i][j] <= acc_stage_reg[i-1][j];
        end
      end

      // Shift intermediate product registers to match latency
      for (int i = 1; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          prod_stage_reg[i][j] <= prod_stage_reg[i-1][j];
        end
      end

      // Final accumulation and output
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          matrix_c[((i*ROW_B)+j)*OUTPUT_DATA_WIDTH-1:0] <= acc_reg[i][j];
        end
      end

      valid_out <= 1;
    end
  end

endmodule
