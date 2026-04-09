module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                                       clk,
  input  logic                                       srst,
  input  logic                                       valid_in,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic                                       valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

genvar gv1;
genvar gv2;
genvar gv3;

localparam MODIFIED_COL_A = COL_A + (COL_A & 1 ? 0 : 1);
localparam HALF_MODIFIED_COL_A = MODIFIED_COL_A / 2;

always_ff @(posedge clk) begin
  if (srst)
    {valid_out, valid_out_reg} <= '0;
  else
    {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

  if (valid_out_reg[COL_A]) begin
    for (i = 1; i <= $clog2(COL_A); i++) begin
      if (valid_out_reg[COL_A]) begin
        for (j = 0; j < HALF_MODIFIED_COL_A; j++) begin
          add_stage[((j << 1) + ((j >> 1)))*OUTPUT_DATA_WIDTH] <= 
            add_stage[((j << 1)) | ((j << 1) + 1)] * 2;
        end
      end
    end

    matrix_c[COL_B : 0] = valid_out_reg[COL_B : 0];
  end
end

endmodule
