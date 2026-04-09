
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

  // Intermediate registers to hold multiplication results
  logic [COL_A-1:0] multiply_register [ROW_A-1:0][COL_B-1:0];

  // Shift register to control the propagation of valid_in signal
  logic [COL_B-1:0] shift_reg [COL_A-1:0];

  // Accumulator for the final matrix C
  logic [COL_B-1:0] accumulator [ROW_A-1:0];

  // Sequential control
  integer seq_counter = 0;

  always @(posedge clk) begin
    if (srst) begin
      seq_counter <= 0;
      valid_out <= 0;
      multiply_register <= { { replicate(0, COL_B*OUTPUT_DATA_WIDTH) };
      accumulator <= { { replicate(0, ROW_A*COL_B) };
      matrix_c <= { { replicate(0, ROW_A*COL_B*OUTPUT_DATA_WIDTH) };
    end else if (valid_in) begin
      seq_counter <= seq_counter + 1;
      if (seq_counter < COL_A) begin
        // Multiplication stage
        foreach (multiply_register[i][j]) begin
          multiply_register[i][j] <= (matrix_a[((i-1)*COL_A + j-1)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH] * matrix_b[((j-1)*COL_B + COL_A-1)*INPUT_DATA_WIDTH +: INPUT_DATA_WIDTH]) << (OUTPUT_DATA_WIDTH - INPUT_DATA_WIDTH);
        end
      end

      // Accumulation stage
      if (seq_counter == COL_A) begin
        seq_counter <= 0;
        // Shift register for valid_in signal
        shift_reg <= valid_in;
        // Update accumulator
        foreach (accumulator[i]) begin
          accumulator[i] <= shift_reg[i];
        end
        // Shift register for next cycle
        shift_reg <= 0;
        valid_out <= 1;
      end
    end
  end

  // Output stage
  always @(posedge clk) begin
    if (srst) begin
      matrix_c <= 0;
    end else if (valid_out) begin
      foreach (matrix_c[i]) matrix_c[i] <= accumulator[i];
    end
  end
endmodule
