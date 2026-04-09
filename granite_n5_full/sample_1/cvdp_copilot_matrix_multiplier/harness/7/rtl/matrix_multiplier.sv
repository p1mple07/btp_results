module matrix_multiplier #(
  parameter ROW_A             = 4                                                  , // Number of rows in matrix A
  parameter COL_A             = 4                                                  , // Number of columns in matrix A
  parameter ROW_B             = 4                                                  , // Number of rows in matrix B
  parameter COL_B             = 4                                                  , // Number of columns in matrix B
  parameter INPUT_DATA_WIDTH  = 8                                                  , // Bit-width of input data
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)                // Bit-width of output data
) (
  input  logic clk                                                                    , // Clock signal for synchronization
  input  logic srst                                                                   , // Synchronous reset active high
  input  logic valid_in                                                              , // Valid signal for input matrices
  output logic valid_out                                                             , // Valid signal for output matrix
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a                     , // Flattened input matrix A
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b                     , // Flattened input matrix B
  output logic [ ((ROW_A*COL_B)*OUTPUT_DATA_WIDTH)-1:0] matrix_c                     // Flattened output matrix C
);

  // Constants declaration
  localparam int REGISTER_DEPTH = COL_A + 2;

  // Internal signals and registers declaration
  logic [ (REGISTER_DEPTH*(ROW_A*COL_A))-1:0 ] reg_mul_result;
  logic [ (REGISTER_DEPTH*(ROW_A*COL_B))-1:0 ] reg_acc_result;
  logic [ ((REGISTER_DEPTH-1)*(ROW_A*COL_B))-1:0 ] reg_shifted_acc_result;
  logic [ (ROW_A*COL_B)*OUTPUT_DATA_WIDTH-1:0 ] reg_final_result;
  logic [ (REGISTER_DEPTH-1)*(ROW_A*COL_B)*OUTPUT_DATA_WIDTH-1:0 ] reg_shifted_final_result;
  logic [ ((REGISTER_DEPTH-1)*OUTPUT_DATA_WIDTH)-1:0 ] reg_output_data;

  // Multiplication stage implementation
  always @(posedge clk) begin
    // Perform unsigned product and store in intermediate registers
    // Use multiplication operator '*' for the product.
    reg_mul_result <= {reg_mul_result[((REGISTER_DEPTH-1)*INPUT_DATA_WIDTH)-1:0], {((REGISTER_DEPTH-1)*INPUT_DATA_WIDTH)'{1'b0}};
  end

  // Accumulation stage implementation
  always @(posedge clk) begin
    // Calculate the sum of all the products over multiple cycles and store the result in the acc_result
    // Use addition operator '+' for the summation operation.
    if (valid_in) begin
      reg_acc_result <= {reg_acc_result[(REGISTER_DEPTH*OUTPUT_DATA_WIDTH)-1:0], {REGISTER_DEPTH*OUTPUT_DATA_WIDTH{'h0}}};
    end
  end

  // Output stage implementation
  always @(posedge clk) begin
    // Shift the accumulated result by one cycle and store the latest result in the shifted_acc_result
    // Use concatenation operator '{' and '}' to merge two registers
    // Use slicing operator '[(REGISTRY_DEPTH-1):0]' to get the last value of the acc_result
    reg_shifted_acc_result <= {reg_acc_result[((REGISTRY_DEPTH-1)*OUTPUT_DATA_WIDTH)-1:0], {((REGISTRY_DEPTH-1)*OUTPUT_DATA_WIDTH){1'b0}};
    // Output the final result of the matrix multiplication
    // Use concatenation operator '{' and '}' to merge two registers
    // Use slicing operator '[(REGISTRY_DEPTH-1)*OUTPUT_DATA_WIDTH]{1'b0}`;
    assign valid_out = (reg_shifted_acc_result[((REGISTRY_DEPTH*OUTPUT_DATA_WIDTH)-1:0]!= {((REGISTRY_DEPTH-1)*OUTPUT_DATA_WIDTH){1'b0}`.
    // Use conditional statements (if-else-if) to check if the product is zero or not.
    if (reg_mul_result == 0) begin
      // If the product of two numbers is zero, then there is no need to calculate the result of multiplication.
      valid_out = 0;
    end else begin
      // Otherwise, we need to calculate the result of multiplication.
      // Perform signed multiplication.
      assign reg_final_result = reg_mul_result;
    end

endmodule