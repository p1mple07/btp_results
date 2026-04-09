module matrix_multiplier_sequential #(
  parameter ROW_A = 4,
  parameter COL_A = 4,
  parameter ROW_B = 4,
  parameter COL_B = 4,
  parameter INPUT_DATA_WIDTH = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic clk,
  input  logic srst,
  input  logic valid_in,
  input  logic valid_out,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0 ] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0 ] matrix_b,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

  // Reset signals
  reg reset;
  reg [num_cycles-1:0] time;

  // Reset initialization
  initial begin
    reset = 1'b1;
    time <= 0;
  end

  always_ff @(posedge clk or negedge srst) begin
    if (srst) begin
      reset <= 1'b0;
      matrix_a <= 0;
      matrix_b <= 0;
      matrix_c <= 0;
      valid_out <= 0;
    end else begin
      matrix_a <= matrix_a;
      matrix_b <= matrix_b;
      matrix_c <= matrix_c;
      valid_out <= 1;
    end
  end

  // Multiplication stage: compute product matrix
  always_comb begin
    if (valid_in && valid_out) begin
      time <= 0;
    end else
      time <= time + 1;
  end

  // Accumulation stage: sum over COL_A cycles
  always_comb begin
    if (time == COL_A) begin
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < COL_B; j++) begin
          for (int k = 0; k < COL_A; k++) begin
            matrix_c[(i*COL_B + j)*OUTPUT_DATA_WIDTH + k] += matrix_a[(i*COL_A + k)*INPUT_DATA_WIDTH + j*INPUT_DATA_WIDTH + k*INPUT_DATA_WIDTH];
          end
        end
      end
    end else
      matrix_c <= matrix_c;
  end

  // Output stage: propagate valid_out to output matrix
  always_comb begin
    if (valid_out && time == COL_A + 1) begin
      matrix_c <= matrix_c;
    end else
      matrix_c <= 0;
  end

endmodule
