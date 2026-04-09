module matrix_multiplier #(
  parameter ROW_A             = 4                                                   ,
  parameter COL_A             = 4                                                   ,
  parameter ROW_B             = 4                                                   ,
  parameter COL_B             = 4                                                   ,
  parameter INPUT_DATA_WIDTH  = 8                                                   ,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input clk,
  input srst,
  input valid_in,
  input wire [(ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input wire [(ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output reg valid_out,
  output reg [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

  // Intermediate registers
  reg [((ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1):0] matrix_a_reg [COL_A];
  reg [((ROW_B*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1):0] matrix_b_reg [COL_B];
  reg [((ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1):0] matrix_c_reg [COL_A*ROW_B];

  // Shift registers to match latency
  reg [((ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1):0] shift_reg [COL_A*ROW_B];

  // Sequential logic
  always @(posedge clk) begin
    if (srst) begin
      valid_out <= 1'b0;
      for (int i = 0; i < COL_A; i++) begin
        matrix_a_reg[i] <= 0;
        matrix_b_reg[i] <= 0;
        matrix_c_reg[i*ROW_B] <= 0;
      end
    end else if (valid_in) begin
      // Multiplication stage
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          matrix_a_reg[i] <= matrix_a[(i*COL_A + j)*INPUT_DATA_WIDTH-:INPUT_DATA_WIDTH];
          matrix_b_reg[j] <= matrix_b[(j*COL_B + i)*INPUT_DATA_WIDTH-:INPUT_DATA_WIDTH];
        end
      end

      // Accumulation stage
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          shift_reg[i*ROW_B + j] <= matrix_a_reg[i] * matrix_b_reg[j];
        end
      end

      // Output stage
      for (int i = 0; i < COL_A; i++) begin
        for (int j = 0; j < ROW_B; j++) begin
          matrix_c_reg[i*ROW_B + j] <= shift_reg[i*ROW_B + j];
        end
      end

      // Update valid_out signal after COL_A + 2 cycles
      if (COL_A == 1) begin
        valid_out <= matrix_c_reg[COL_A*ROW_B-1] && shift_reg[COL_A*ROW_B-1];
      end else begin
        valid_out <= matrix_c_reg[(COL_A-1)*ROW_B-1] && shift_reg[(COL_A-1)*ROW_B-1];
      end
    end
  end

  // Assign outputs
  assign matrix_c = matrix_c_reg;
  assign valid_out = valid_out;
endmodule
