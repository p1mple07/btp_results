module matrix_multiplier #(
  parameter ROW_A             = 4                                                  , // Number of rows in matrix A
  parameter COL_A             = 4                                                  , // Number of columns in matrix A
  parameter ROW_B             = 4                                                  , // Number of rows in matrix B
  parameter COL_B             = 4                                                  , // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8                                                  , // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)                // Bit-width of output data
) (
  input  logic         clk                                                   , // Clock signal
  input  logic         srst                                                 , // Synchronous reset
  input  logic         valid_in                                             , // Valid signal for input matrices
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a                      , // Input matrix A in 1D form
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b                      , // Input matrix B in 1D form
  output logic         valid_out                                            , // Valid signal for output matrix
  output logic [ (ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c                        // Output matrix C in 1D form
);
  localparam int unsigned P = 2; // Number of pipeline stages
  localparam int unsigned T = $clog2(P); // Number of clock cycles between each stage

  // Define intermediate variables and wires for each pipeline stage
  logic [ ((ROW_A*COL_A*INPUT_DATA_WIDTH)-1)+(T*OUTPUT_DATA_WIDTH)-1:0] m_reg; // Register for multiplication stage
  logic [ ((ROW_A*COL_A*OUTPUT_DATA_WIDTH)-1)+(T*OUTPUT_DATA_WIDTH)-1:0] acc_reg; // Register for accumulation stage
  logic [ ((ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1):0] o_reg; // Register for output stage

  // Pipeline stages
  always @(posedge clk or negedge srst) begin
    if (!srst) begin
      // Reset internal registers and outputs to 0 on the next rising clock edge
      m_reg <= {((ROW_A*COL_A*INPUT_DATA_WIDTH)-1){1'bx}};
      acc_reg <= {((ROW_A*COL_A*OUTPUT_DATA_WIDTH)-1){1'bx}};
      o_reg <= {((ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1){1'bx}};
    end else if (valid_in && valid_out) begin
      // Multiply the current input matrices
      m_reg <= {{(ROW_A*COL_A*INPUT_DATA_WIDTH)-1{1'bx}}, matrix_a};
      // Accumulate the multiplication results across multiple cycles
      acc_reg <= {{(ROW_A*COL_A*OUTPUT_DATA_WIDTH)-1{1'bx}}, m_reg[((ROW_A*COL_A*OUTPUT_DATA_WIDTH)-1:(ROW_A*COL_A*INPUT_DATA_WIDTH)]};
      // Output the accumulated result
      o_reg <= {{(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1{1'bx}}, acc_reg[((ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0]};
    end
  end

  // Generate the final result for matrix_c
  assign matrix_c = o_reg[(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0];

endmodule