module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter DATA_WIDTH = 8,
  parameter OUTPUT_DATA_WIDTH = DATA_WIDTH
) (
  input  logic clk,
  input  logic srst,
  input  logic valid_in,
  input  logic [1:0] rotation_angle,
  input  logic [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image, padded_image_reg, padded_image_reg2, padded_image_reg3;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image, transposed_image_reg, transposed_image_reg2, transposed_image_reg3;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated_image, rotated_image_reg, rotated_image_reg2, rotated_image_reg3;

  logic [5:0] valid_out_reg;

  always_ff @(posedge clk)
    if (srst)
      {valid_out, valid_out_reg} <= '0;
    else
      {valid_out, valid_out_reg} <= {valid_out_reg, valid_in};

  // Pad the input image to a square
  always_ff @(posedge clk) begin
    if (srst)
      padded_image <= '0;
    else
      begin
        for (int pad_row = 0; pad_row < IN_ROW; pad_row++)
          for (int pad_col = 0; pad_col < IN_COL; pad_col++)
            if ((pad_row < IN_ROW) && (pad_col < IN_COL))
              padded_image[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH];
            else
              padded_image[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] = '0;
      end
  end

  // Transpose the padded image
  always_ff @(posedge clk) begin
    if (srst)
      transposed_image <= '0;
    else
      begin
        for (int trans_row = 0; trans_row < OUT_ROW; trans_row++)
          for (int trans_col = 0; trans_col < OUT_COL; trans_col++)
            transposed_image[(trans_col * OUT_ROW + trans_row) * DATA_WIDTH +: DATA_WIDTH] =
              padded_image_reg[(trans_row * OUT_COL + trans_col) * DATA_WIDTH +: DATA_WIDTH];
      end
  end

  // Rotate with a latency buffer
  always_ff @(posedge clk) begin
    if (srst)
      rotated_image <= 32'd0;
    else
      begin
        for (int rot_row = 0; rot_row < OUT_ROW; rot_row++)
          for (int rot_col = 0; rot_col < OUT_COL; rot_col++)
            case (rotation_angle)
              'b00: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] =
                  transposed_image_reg[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

              'b01: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] =
                  padded_image_reg3[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

              'b10: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] =
                  transposed_image_reg[((OUT_Row-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];

              'b11: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <=
                  padded_image_reg3[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
            endcase
          end
      end
  end

  always_ff @(posedge clk)
    if (srst)
      image_out <= '0;
    else
      image_out <= rotated_image_reg;
  end

endmodule
