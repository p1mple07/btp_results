module matrix_multiplier #(
  parameter ROW_A = 4,
  parameter COL_A = 4,
  parameter ROW_B = 4,
  parameter COL_B = 4,
  parameter INPUT_DATA_WIDTH = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c,
  input  logic srst
);
  logic clk;
  logic valid_in, valid_out;
  logic [3:0] stage;
  reg [COL_A*OUTPUT_DATA_WIDTH-1:0] matrix_c_acc;

  always @(posedge clk or posedge srst) begin
    if (srst) begin
      matrix_c_acc <= 0;
      valid_out <= 0;
    end else begin
      // Multiply stage: compute all products
      for (int i=0; i<ROW_A*COL_A*INPUT_DATA_WIDTH; i++) begin
        matrix_c_acc = matrix_c_acc + matrix_a[i] * matrix_b[i];
      end

      // Accumulate stage: add across COL_A cycles
      if (stage == 0) stage <= 1;
      else if (stage == 1) stage <= 2;
      else if (stage == 2) stage <= 3;
      else stage <= 0;

      // Output stage: output after COL_A + 2 cycles
      if (stage == 3) begin
        matrix_c_acc <= matrix_c_acc >> 1;
      end
    end
  end

  assign matrix_c = matrix_c_acc;

  assign valid_out = (stage == 3);

endmodule
