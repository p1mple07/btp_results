module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic                                    clk,
  input  logic                                    srst,
  input  logic                                    valid_in,
  input  logic [0:1] rotation_angle,
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic                                    valid_out,
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg;

  logic [5:0] valid_out_reg;

  @(posedge clk) if (srst) {
    {valid_out, valid_out_reg} <= '0;
  } else {
    {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};
  }

  @(posedge clk) padded_image <= '0;
  padded_image_reg <= padded_image;
  padded_image_reg2 <= padded_image_reg;
  padded_image_reg3 <= padded_image_reg2;

  @(posedge clk) if (srst) {
    {transposed_image, transposed_image_reg} <= '0;
  } else {
    for (int trans_row = 0; trans_row < OUT_ROW; trans_row++)
      for (int trans_col = 0; trans_col < OUT_COL; trans_col++)
      {case (rotation_angle)}
        // 90° Clockwise: Transpose + Reverse Rows
        2'b00: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

        // 180° Clockwise: Reverse Rows and Columns
        2'b01: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

        // 270° Clockwise: Transpose + Reverse Columns
        2'b10: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[((OUT_Row-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];

        // No Rotation (Pass-through)
        2'b11: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
      endfor
  }

  @(posedge clk) if (srst) {
    {rotated_image, rotated_image_reg} <= '0;
  } else {
    {rotated_image, rotated_image_reg} <= {rotated_image_reg, rotated_image};
  }

  always_ff @(posedge clk) if (srst) image_out <= '0;
  else {
    image_out <= rotated_image_reg;
  }

endmodule
